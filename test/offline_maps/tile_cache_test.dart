import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/offline_maps/cache_eviction.dart';
import 'package:virya/core/offline_maps/offline_region.dart';
import 'package:virya/core/offline_maps/online_tile_source.dart';
import 'package:virya/core/offline_maps/region_downloader.dart';
import 'package:virya/core/offline_maps/region_repository.dart';
import 'package:virya/core/offline_maps/tile_math.dart';
import 'package:virya/core/offline_maps/tile_proxy.dart';
import 'package:virya/core/offline_maps/tile_store.dart';

/// Offline-only fake upstream: serves 100-byte tiles, can be switched off.
class FakeSource extends OnlineTileSource {
  int calls = 0;
  bool offline = false;
  @override
  Future<Uint8List?> fetch(int z, int x, int y) async {
    calls++;
    if (offline) throw const TileFetchException('offline');
    return Uint8List(100);
  }
}

void main() {
  group('pickEvictions', () {
    final t0 = DateTime(2026);
    CacheEntry e(String p, int size, int minute) =>
        CacheEntry(p, size, t0.add(Duration(minutes: minute)));

    test('nothing when under target', () {
      expect(pickEvictions([e('a', 10, 0), e('b', 10, 1)], 20), isEmpty);
    });

    test('least recently used first, stops at target', () {
      final out = pickEvictions(
          [e('new', 40, 9), e('old', 40, 1), e('mid', 40, 5)], 60);
      expect(out.map((x) => x.path), ['old', 'mid']);
    });

    test('evicts everything when target is 0', () {
      expect(pickEvictions([e('a', 1, 0), e('b', 1, 1)], 0).length, 2);
    });
  });

  group('TileStore / proxy / downloader (temp dir)', () {
    late Directory tmp;
    late TileStore cache, regionTiles;
    late FakeSource source;

    Future<Directory> sub(String n) async =>
        Directory('${tmp.path}/$n').create(recursive: true);

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('virya_tiles_');
      cache = TileStore(() => sub('cache'), maxBytes: 1000);
      regionTiles = TileStore(() => sub('regions'));
      source = FakeSource();
    });

    tearDown(() async {
      source.close();
      await tmp.delete(recursive: true);
    });

    test('LRU cap evicts down to 90% of maxBytes', () async {
      for (var i = 0; i < 15; i++) {
        await cache.write(10, i, 0, Uint8List(100));
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      // Eviction runs async after the write that crossed the cap.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(await cache.sizeBytes(), lessThanOrEqualTo(1000));
      expect(await cache.read(10, 14, 0), isNotNull); // newest kept
      await cache.clear();
      expect(await cache.sizeBytes(), 0);
    });

    test('proxy: fetch once, then served from cache even offline', () async {
      final proxy = TileProxy(regions: regionTiles, cache: cache, source: source);
      expect((await proxy.tile(3, 1, 1))!.length, 100);
      source.offline = true;
      expect(await proxy.tile(3, 1, 1), isNotNull);
      expect(await proxy.tile(3, 2, 2), isNull);
      expect(await proxy.tile(20, 0, 0), isNull); // beyond z14
      proxy.onlineEnabled = false;
      source.offline = false;
      expect(await proxy.tile(3, 3, 3), isNull);
      expect(source.calls, 2);
    });

    test('downloader fills region store; delete keeps shared tiles', () async {
      final repo = RegionRepository(metaDir: () => sub('meta'), tiles: regionTiles);
      OfflineRegion region(String id, double km) => OfflineRegion(
          id: id, name: id, bounds: boundsAround(-6.9, 107.6, km),
          minZoom: 10, maxZoom: 11, tileCount: 0, sizeBytes: 0,
          createdAt: DateTime.utc(2026));
      final dl = RegionDownloader(
          regions: regionTiles, cache: cache, source: source,
          interval: Duration.zero);
      final big = region('big', 10), small = region('small', 2);
      final res = await dl.run(big);
      expect(res.done, res.total);
      expect(res.failed, 0);
      expect(res.bytes, res.total * 100);
      await repo.save(big);
      await repo.save(small);
      expect((await repo.list()).length, 2);

      await repo.delete('big');
      expect((await repo.list()).single.id, 'small');
      for (final (z, x, y) in tilesIn(small.ranges)) {
        expect(await regionTiles.length(z, x, y), 100);
      }
      expect(await regionTiles.sizeBytes(),
          countTiles(small.bounds, 10, 11) * 100);
    });

    test('downloader aborts when the network is gone', () async {
      source.offline = true;
      final dl = RegionDownloader(
          regions: regionTiles, cache: cache, source: source,
          interval: Duration.zero);
      final r = OfflineRegion(
          id: 'x', name: 'x', bounds: boundsAround(-6.9, 107.6, 30),
          minZoom: 12, maxZoom: 12, tileCount: 0, sizeBytes: 0,
          createdAt: DateTime.utc(2026));
      await expectLater(dl.run(r), throwsA(isA<TileFetchException>()));
    }, timeout: const Timeout(Duration(seconds: 60)));
  });
}
