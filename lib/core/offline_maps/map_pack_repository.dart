import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/offline_maps/local_tile_server.dart';
import 'package:virya/core/offline_maps/map_pack.dart';
import 'package:virya/core/offline_maps/map_storage.dart';

/// Setting keys.
class MapSettingKeys {
  static const basemap = 'map_basemap';
  static const dem = 'map_dem';
  static const onlineFallback = 'map_online_fallback';
}

/// Everything the WebView needs to build its style.
class MapConfig {
  final Uri pageUrl;
  final String? basemapUrl; // pmtiles://http://127.0.0.1:port/packs/x.pmtiles
  final String? demUrl;

  /// No PMTiles basemap → draw OpenFreeMap tiles through the local caching
  /// proxy ([tilesUrl]); works offline for cached / downloaded areas.
  final bool onlineBasemap;
  final String? tilesUrl; // http://127.0.0.1:port/tiles/{z}/{x}/{y}.pbf

  const MapConfig({
    required this.pageUrl,
    this.basemapUrl,
    this.demUrl,
    this.onlineBasemap = false,
    this.tilesUrl,
  });

  bool get hasDem => demUrl != null;

  Map<String, Object?> toJson() => {
    'basemapUrl': basemapUrl,
    'demUrl': demUrl,
    'online': onlineBasemap,
    'tilesUrl': tilesUrl,
  };
}

class MapPacksState {
  final List<MapPack> packs;
  final String? activeBasemap;
  final String? activeDem;
  final bool onlineFallback;
  const MapPacksState({
    required this.packs,
    this.activeBasemap,
    this.activeDem,
    this.onlineFallback = true,
  });
}

typedef GetSetting = Future<String?> Function(String key);
typedef SetSetting = Future<void> Function(String key, String value);

class MapPackRepository {
  MapPackRepository({
    required GetSetting getSetting,
    required SetSetting setSetting,
    Future<Directory> Function()? mapsDir,
    LocalTileServer? server,
  }) : _get = getSetting,
       _set = setSetting,
       _dir = mapsDir ?? defaultMapsDir,
       _server = server ?? LocalTileServer.instance;

  final GetSetting _get;
  final SetSetting _set;
  final Future<Directory> Function() _dir;
  final LocalTileServer _server;

  Future<List<MapPack>> listPacks() async {
    final dir = await _dir();
    final out = <MapPack>[];
    await for (final e in dir.list(followLinks: false)) {
      if (e is! File) continue;
      final name = p.basename(e.path);
      if (!name.toLowerCase().endsWith('.pmtiles')) continue;
      final header = await readHeader(e);
      out.add(
        MapPack(
          fileName: name,
          path: e.path,
          sizeBytes: await e.length(),
          type: detectPackType(name, header),
          header: header,
        ),
      );
    }
    out.sort((a, b) => a.fileName.compareTo(b.fileName));
    return out;
  }

  static Future<PmtilesHeader?> readHeader(File f) async {
    RandomAccessFile? raf;
    try {
      raf = await f.open();
      final bytes = await raf.read(PmtilesHeader.length);
      return PmtilesHeader.parse(Uint8List.fromList(bytes));
    } catch (_) {
      return null;
    } finally {
      await raf?.close();
    }
  }

  /// Copies [data] into `maps/` as [fileName]. Throws [FormatException] when
  /// the result is not a PMTiles v3 archive.
  Future<MapPack> importStream(
    String fileName,
    Stream<List<int>> data, {
    int? totalBytes,
    void Function(double progress)? onProgress,
  }) async {
    var name = p.basename(fileName).replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (name.startsWith('.')) name = 'pack$name';
    if (!name.toLowerCase().endsWith('.pmtiles')) {
      throw const FormatException('File harus berekstensi .pmtiles');
    }
    final dir = await _dir();
    final dest = File(p.join(dir.path, name));
    final tmp = File('${dest.path}.part');
    final sink = tmp.openWrite();
    var done = 0;
    try {
      await for (final chunk in data) {
        sink.add(chunk);
        done += chunk.length;
        if (totalBytes != null && totalBytes > 0) {
          onProgress?.call((done / totalBytes).clamp(0.0, 1.0));
        }
      }
      await sink.flush();
      await sink.close();
    } catch (_) {
      await sink.close().catchError((_) {});
      if (await tmp.exists()) await tmp.delete();
      rethrow;
    }
    final header = await readHeader(tmp);
    if (header == null) {
      await tmp.delete();
      throw const FormatException('Bukan arsip PMTiles v3 yang valid');
    }
    if (await dest.exists()) await dest.delete();
    await tmp.rename(dest.path);
    final pack = MapPack(
      fileName: name,
      path: dest.path,
      sizeBytes: done,
      type: detectPackType(name, header),
      header: header,
    );
    // First pack of its kind becomes active automatically.
    if (pack.type == MapPackType.basemap &&
        (await _get(MapSettingKeys.basemap) ?? '').isEmpty) {
      await setActiveBasemap(name);
    } else if (pack.type == MapPackType.dem &&
        (await _get(MapSettingKeys.dem) ?? '').isEmpty) {
      await setActiveDem(name);
    }
    return pack;
  }

  Future<void> delete(MapPack pack) async {
    final f = File(pack.path);
    if (await f.exists()) await f.delete();
    if (await _get(MapSettingKeys.basemap) == pack.fileName) {
      await setActiveBasemap(null);
    }
    if (await _get(MapSettingKeys.dem) == pack.fileName) {
      await setActiveDem(null);
    }
  }

  Future<void> setActiveBasemap(String? name) =>
      _set(MapSettingKeys.basemap, name ?? '');
  Future<void> setActiveDem(String? name) =>
      _set(MapSettingKeys.dem, name ?? '');
  Future<void> setOnlineFallback(bool v) =>
      _set(MapSettingKeys.onlineFallback, v ? 'true' : 'false');

  Future<MapPacksState> loadState() async {
    final packs = await listPacks();
    final names = packs.map((e) => e.fileName).toSet();
    String? valid(String? n) =>
        (n != null && n.isNotEmpty && names.contains(n)) ? n : null;
    return MapPacksState(
      packs: packs,
      activeBasemap: valid(await _get(MapSettingKeys.basemap)),
      activeDem: valid(await _get(MapSettingKeys.dem)),
      onlineFallback: (await _get(MapSettingKeys.onlineFallback)) != 'false',
    );
  }

  /// Resolves active packs (falls back to the first installed one of each
  /// type) and starts the local server. Without a PMTiles basemap the map
  /// uses the online/cached tile proxy; [MapPacksState.onlineFallback] only
  /// decides whether the proxy may fetch new tiles from the internet.
  Future<MapConfig> buildConfig() async {
    final base = await _server.start();
    final st = await loadState();
    String? pick(String? active, MapPackType t) {
      if (active != null) return active;
      for (final pk in st.packs) {
        if (pk.type == t) return pk.fileName;
      }
      return null;
    }

    final bm = pick(st.activeBasemap, MapPackType.basemap);
    final dem = pick(st.activeDem, MapPackType.dem);
    String url(String n) => 'pmtiles://$base/packs/${Uri.encodeComponent(n)}';
    final proxy = _server.tiles;
    proxy?.onlineEnabled = st.onlineFallback;
    final online = bm == null && proxy != null;
    return MapConfig(
      pageUrl: base.replace(path: '/app/map.html'),
      basemapUrl: bm == null ? null : url(bm),
      demUrl: dem == null ? null : url(dem),
      onlineBasemap: online,
      tilesUrl: online ? '$base/tiles/{z}/{x}/{y}.pbf' : null,
    );
  }

  /// Quick DNS check used for the status line.
  static Future<bool> isOnline() async {
    try {
      final r = await InternetAddress.lookup(
        'tiles.openfreemap.org',
      ).timeout(const Duration(seconds: 2));
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

final mapPackRepositoryProvider = Provider<MapPackRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MapPackRepository(
    getSetting: db.getSetting,
    setSetting: db.setSetting,
  );
});

final mapPacksStateProvider = FutureProvider<MapPacksState>(
  (ref) => ref.watch(mapPackRepositoryProvider).loadState(),
);

/// Invalidate after changing packs so open maps rebuild their style.
final mapConfigProvider = FutureProvider<MapConfig>(
  (ref) => ref.watch(mapPackRepositoryProvider).buildConfig(),
);
