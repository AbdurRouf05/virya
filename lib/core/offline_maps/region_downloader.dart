import 'dart:async';

import 'package:virya/core/offline_maps/offline_region.dart';
import 'package:virya/core/offline_maps/online_tile_source.dart';
import 'package:virya/core/offline_maps/tile_math.dart';
import 'package:virya/core/offline_maps/tile_store.dart';

class RegionDownloadProgress {
  final int done;
  final int total;
  final int failed;
  final int bytes;
  const RegionDownloadProgress(this.done, this.total, this.failed, this.bytes);

  double get fraction => total == 0 ? 1 : done / total;
}

/// Spaces calls at least [interval] apart (shared by all workers).
class RateLimiter {
  RateLimiter(this.interval);
  final Duration interval;
  DateTime _next = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> wait() async {
    final now = DateTime.now();
    final slot = _next.isAfter(now) ? _next : now;
    _next = slot.add(interval);
    final d = slot.difference(now);
    if (d > Duration.zero) await Future<void>.delayed(d);
  }
}

/// Downloads every tile of a region into the region store, politely:
/// few parallel workers, a global request rate cap and a tile cap.
class RegionDownloader {
  RegionDownloader({
    required this.regions,
    required this.cache,
    required this.source,
    this.workers = 2,
    Duration interval = const Duration(milliseconds: 125), // ≤ 8 req/s
  }) : _limiter = RateLimiter(interval);

  static const maxTiles = 30000;
  static const maxConsecutiveFailures = 12;

  final TileStore regions;
  final TileStore cache;
  final OnlineTileSource source;
  final int workers;
  final RateLimiter _limiter;

  /// Runs until done, [isCancelled] returns true, or the network is gone
  /// (throws [TileFetchException]).
  Future<RegionDownloadProgress> run(
    OfflineRegion region, {
    void Function(RegionDownloadProgress p)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final total = countTiles(region.bounds, region.minZoom, region.maxZoom);
    if (total > maxTiles) {
      throw StateError('Terlalu banyak ubin ($total > $maxTiles)');
    }
    final it = tilesIn(region.ranges).iterator;
    var done = 0, failed = 0, bytes = 0, streak = 0;
    Object? fatal;
    void report() =>
        onProgress?.call(RegionDownloadProgress(done, total, failed, bytes));

    Future<void> worker() async {
      while (fatal == null &&
          !(isCancelled?.call() ?? false) &&
          it.moveNext()) {
        final (z, x, y) = it.current;
        try {
          final n = await _one(z, x, y);
          bytes += n;
          streak = 0;
        } on TileFetchException catch (e) {
          failed++;
          if (++streak >= maxConsecutiveFailures) fatal = e;
        }
        done++;
        report();
      }
    }

    report();
    await Future.wait([for (var i = 0; i < workers; i++) worker()]);
    final f = fatal;
    if (f != null) throw f;
    return RegionDownloadProgress(done, total, failed, bytes);
  }

  /// Returns the stored size of the tile (0 for empty tiles).
  Future<int> _one(int z, int x, int y) async {
    final have = await regions.length(z, x, y);
    if (have != null) return have;
    final cached = await cache.read(z, x, y);
    if (cached != null) {
      await regions.write(z, x, y, cached);
      return cached.length;
    }
    for (var attempt = 0; ; attempt++) {
      await _limiter.wait();
      try {
        final data = await source.fetch(z, x, y);
        if (data == null) return 0;
        await regions.write(z, x, y, data);
        return data.length;
      } on TileFetchException {
        if (attempt >= 1) rethrow;
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
  }
}
