import 'dart:io';

import 'package:virya/core/offline_maps/map_storage.dart';
import 'package:virya/core/offline_maps/online_tile_source.dart';
import 'package:virya/core/offline_maps/region_downloader.dart';
import 'package:virya/core/offline_maps/region_repository.dart';
import 'package:virya/core/offline_maps/tile_proxy.dart';
import 'package:virya/core/offline_maps/tile_store.dart';

/// Wiring for the hybrid online map: OpenFreeMap tiles, an LRU cache of
/// tiles seen online, and downloaded regions. One app-wide instance.
class OfflineTiles {
  OfflineTiles({
    Future<Directory> Function()? cacheDir,
    Future<Directory> Function()? regionsDir,
    Future<Directory> Function()? regionTilesDir,
    OnlineTileSource? source,
    int cacheMaxBytes = defaultCacheMaxBytes,
  }) : cache = TileStore(
         cacheDir ?? defaultTileCacheDir,
         maxBytes: cacheMaxBytes,
       ),
       regionTiles = TileStore(regionTilesDir ?? defaultRegionTilesDir),
       source = source ?? OnlineTileSource() {
    proxy = TileProxy(regions: regionTiles, cache: cache, source: this.source);
    regions = RegionRepository(
      metaDir: regionsDir ?? defaultRegionsDir,
      tiles: regionTiles,
    );
  }

  static final OfflineTiles instance = OfflineTiles();

  static const defaultCacheMaxBytes = 500 * 1024 * 1024;

  /// Region download zoom range (OpenFreeMap tops out at z14; the map
  /// overzooms beyond that).
  static const regionMinZoom = 5;
  static const regionMaxZoom = OnlineTileSource.maxZoom;

  final TileStore cache;
  final TileStore regionTiles;
  final OnlineTileSource source;
  late final TileProxy proxy;
  late final RegionRepository regions;

  RegionDownloader downloader() =>
      RegionDownloader(regions: regionTiles, cache: cache, source: source);
}
