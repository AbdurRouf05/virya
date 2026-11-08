import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:virya/core/offline_maps/offline_region.dart';
import 'package:virya/core/offline_maps/tile_store.dart';

/// Region metadata in `regions.json`; tiles in a shared [TileStore].
class RegionRepository {
  RegionRepository({
    required Future<Directory> Function() metaDir,
    required this.tiles,
  }) : _metaDir = metaDir;

  final Future<Directory> Function() _metaDir;
  final TileStore tiles;

  Future<File> _file() async =>
      File(p.join((await _metaDir()).path, 'regions.json'));

  Future<List<OfflineRegion>> list() async {
    final f = await _file();
    if (!await f.exists()) return [];
    try {
      final raw = jsonDecode(await f.readAsString());
      if (raw is! List) return [];
      final out = [
        for (final e in raw)
          if (e is Map) OfflineRegion.fromJson(e.cast<String, Object?>()),
      ];
      out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return out;
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(List<OfflineRegion> regions) async {
    final f = await _file();
    final tmp = File('${f.path}.part');
    await tmp.writeAsString(jsonEncode([for (final r in regions) r.toJson()]));
    await tmp.rename(f.path);
  }

  /// Inserts or replaces by id.
  Future<void> save(OfflineRegion region) async {
    final all = await list();
    final i = all.indexWhere((r) => r.id == region.id);
    if (i < 0) {
      all.add(region);
    } else {
      all[i] = region;
    }
    await _write(all);
  }

  /// Removes metadata and the tiles no other region still needs.
  Future<void> delete(String id) async {
    final all = await list();
    final i = all.indexWhere((r) => r.id == id);
    if (i < 0) return;
    final removed = all.removeAt(i);
    await _write(all);
    for (final (z, x, y) in orphanTiles(removed, all)) {
      await tiles.delete(z, x, y);
    }
  }

  Future<int> totalBytes() => tiles.sizeBytes();
}
