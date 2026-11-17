import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:virya/core/offline_maps/online_tile_source.dart';
import 'package:virya/core/offline_maps/tile_math.dart';
import 'package:virya/core/offline_maps/tile_store.dart';

/// Resolves a tile for the map: downloaded regions → cache → online
/// (stored in the cache). Returns null when nothing is available, which the
/// server answers with 204 so MapLibre draws an empty tile.
class TileProxy {
  TileProxy({required this.regions, required this.cache, required this.source});

  final TileStore regions;
  final TileStore cache;
  final OnlineTileSource source;
  final Map<String, Future<Uint8List?>> _inflight = {};

  /// When false, misses are not fetched online (cache/regions only).
  bool onlineEnabled = true;

  Future<Uint8List?> tile(int z, int x, int y) {
    if (!isValidTile(z, x, y, maxZoom: OnlineTileSource.maxZoom)) {
      return Future.value(null);
    }
    final key = '$z/$x/$y';
    return _inflight[key] ??= _resolve(z, x, y).whenComplete(() {
      // Block body on purpose: returning the removed Future would make
      // whenComplete wait on itself and never finish.
      _inflight.remove(key);
    });
  }

  Future<Uint8List?> _resolve(int z, int x, int y) async {
    final local = await regions.read(z, x, y) ?? await cache.read(z, x, y);
    if (local != null) return local;
    if (!onlineEnabled) return null;
    try {
      final bytes = await source.fetch(z, x, y);
      if (bytes != null) await cache.write(z, x, y, bytes);
      return bytes;
    } on TileFetchException {
      return null; // offline
    } catch (e) {
      debugPrint('TileProxy $z/$x/$y: $e');
      return null;
    }
  }
}
