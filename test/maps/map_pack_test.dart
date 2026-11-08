import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:virya/core/offline_maps/local_tile_server.dart';
import 'package:virya/core/offline_maps/map_pack.dart';
import 'package:virya/core/offline_maps/map_pack_repository.dart';

/// Minimal valid PMTiles v3 header (+ padding).
Uint8List fakePmtiles({int tileType = 1, int minZ = 0, int maxZ = 15, int pad = 512}) {
  final b = ByteData(127 + pad);
  const magic = 'PMTiles';
  for (var i = 0; i < magic.length; i++) {
    b.setUint8(i, magic.codeUnitAt(i));
  }
  b.setUint8(7, 3);
  b.setUint8(99, tileType);
  b.setUint8(100, minZ);
  b.setUint8(101, maxZ);
  b.setInt32(102, (105.0 * 1e7).round(), Endian.little);
  b.setInt32(106, (-8.9 * 1e7).round(), Endian.little);
  b.setInt32(110, (114.7 * 1e7).round(), Endian.little);
  b.setInt32(114, (-5.8 * 1e7).round(), Endian.little);
  return b.buffer.asUint8List();
}

void main() {
  group('PmtilesHeader', () {
    test('parses fields', () {
      final h = PmtilesHeader.parse(fakePmtiles(tileType: 1, minZ: 2, maxZ: 14))!;
      expect(h.version, 3);
      expect(h.tileType, PmTileType.mvt);
      expect(h.minZoom, 2);
      expect(h.maxZoom, 14);
      expect(h.minLon, closeTo(105.0, 1e-6));
      expect(h.minLat, closeTo(-8.9, 1e-6));
      expect(h.maxLon, closeTo(114.7, 1e-6));
      expect(h.maxLat, closeTo(-5.8, 1e-6));
    });
    test('rejects non-PMTiles / short data', () {
      expect(PmtilesHeader.parse(Uint8List(10)), isNull);
      expect(PmtilesHeader.parse(Uint8List(200)), isNull);
      final v2 = fakePmtiles()..[7] = 2;
      expect(PmtilesHeader.parse(v2), isNull);
    });
  });

  group('detectPackType', () {
    final mvt = PmtilesHeader.parse(fakePmtiles(tileType: 1));
    final png = PmtilesHeader.parse(fakePmtiles(tileType: 2));
    final webp = PmtilesHeader.parse(fakePmtiles(tileType: 4));
    test('by filename', () {
      expect(detectPackType('jawa.dem.pmtiles', null), MapPackType.dem);
      expect(detectPackType('jawa-terrain.pmtiles', mvt), MapPackType.dem);
      expect(detectPackType('JAWA.DEM.PMTILES', null), MapPackType.dem);
    });
    test('by header tile type', () {
      expect(detectPackType('jawa.pmtiles', mvt), MapPackType.basemap);
      expect(detectPackType('relief.pmtiles', png), MapPackType.dem);
      expect(detectPackType('relief.pmtiles', webp), MapPackType.dem);
      expect(detectPackType('jawa.pmtiles', null), MapPackType.unknown);
      expect(detectPackType('demo.mbtiles', mvt), MapPackType.unknown);
    });
    test('"demak" is not a DEM', () {
      expect(detectPackType('demak.pmtiles', mvt), MapPackType.basemap);
    });
  });

  test('formatBytes', () {
    expect(formatBytes(512), '512 B');
    expect(formatBytes(1536), '1.5 KB');
    expect(formatBytes(1024 * 1024 * 1500), '1.5 GB');
  });

  group('MapPackRepository', () {
    late Directory tmp;
    late Map<String, String> settings;
    late MapPackRepository repo;
    late LocalTileServer server;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('virya_packs_');
      settings = {};
      server = LocalTileServer(packsDir: () async => tmp);
      repo = MapPackRepository(
        getSetting: (k) async => settings[k],
        setSetting: (k, v) async => settings[k] = v,
        mapsDir: () async => tmp,
        server: server,
      );
    });
    tearDown(() async {
      await server.stop();
      await tmp.delete(recursive: true);
    });

    test('import with progress, auto-activate, list, delete', () async {
      final bytes = fakePmtiles(pad: 100000);
      final progress = <double>[];
      Stream<List<int>> chunks(Uint8List b) async* {
        for (var i = 0; i < b.length; i += 8192) {
          yield b.sublist(i, (i + 8192).clamp(0, b.length));
        }
      }

      final pack = await repo.importStream('jawa.pmtiles', chunks(bytes),
          totalBytes: bytes.length, onProgress: progress.add);
      expect(pack.type, MapPackType.basemap);
      expect(progress.last, 1.0);
      expect(settings[MapSettingKeys.basemap], 'jawa.pmtiles');

      await repo.importStream('jawa.dem.pmtiles',
          Stream.value(fakePmtiles(tileType: 2)));
      expect(settings[MapSettingKeys.dem], 'jawa.dem.pmtiles');

      final st = await repo.loadState();
      expect(st.packs.map((e) => e.fileName),
          ['jawa.dem.pmtiles', 'jawa.pmtiles']);
      expect(st.onlineFallback, isTrue);

      final cfg = await repo.buildConfig();
      expect(cfg.basemapUrl, startsWith('pmtiles://http://127.0.0.1:'));
      expect(cfg.basemapUrl, endsWith('/packs/jawa.pmtiles'));
      expect(cfg.demUrl, endsWith('/packs/jawa.dem.pmtiles'));
      expect(cfg.onlineBasemap, isFalse);
      expect(cfg.pageUrl.path, '/app/map.html');

      await repo.delete(st.packs.last);
      expect(settings[MapSettingKeys.basemap], '');
      expect(File(p.join(tmp.path, 'jawa.pmtiles')).existsSync(), isFalse);
    });

    test('rejects invalid files and leaves nothing behind', () async {
      await expectLater(
          repo.importStream('x.pmtiles', Stream.value(List.filled(300, 7))),
          throwsFormatException);
      await expectLater(
          repo.importStream('x.zip', Stream.value(fakePmtiles())),
          throwsFormatException);
      expect(tmp.listSync(), isEmpty);
    });

    test('online fallback setting persists', () async {
      await repo.setOnlineFallback(false);
      expect((await repo.loadState()).onlineFallback, isFalse);
      final cfg = await repo.buildConfig();
      expect(cfg.basemapUrl, isNull);
      expect(cfg.onlineBasemap, isFalse);
    });
  });
}
