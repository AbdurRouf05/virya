import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<Directory> _docsSub(List<String> parts) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.joinAll([docs.path, ...parts]));
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

/// `<app documents>/maps` — where imported PMTiles packs live.
Future<Directory> defaultMapsDir() => _docsSub(['maps']);

/// `<app documents>/tile_cache` — LRU cache of tiles seen online.
Future<Directory> defaultTileCacheDir() => _docsSub(['tile_cache']);

/// `<app documents>/offline_regions` — region metadata (`regions.json`).
Future<Directory> defaultRegionsDir() => _docsSub(['offline_regions']);

/// `<app documents>/offline_regions/tiles` — tiles of downloaded regions.
Future<Directory> defaultRegionTilesDir() =>
    _docsSub(['offline_regions', 'tiles']);
