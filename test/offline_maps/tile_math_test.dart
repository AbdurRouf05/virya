import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/offline_maps/offline_region.dart';
import 'package:virya/core/offline_maps/tile_math.dart';

void main() {
  group('tile index', () {
    test('z0 is a single tile', () {
      expect(lonToTileX(-180, 0), 0);
      expect(lonToTileX(180, 0), 0);
      expect(latToTileY(85, 0), 0);
      expect(latToTileY(-85, 0), 0);
    });

    test('known tile for Bandung at z14', () {
      // 107.6191, -6.9175 → z14 x=13089 y=8507 (OSM wiki formula).
      expect(lonToTileX(107.6191, 14), 13089);
      expect(latToTileY(-6.9175, 14), 8507);
    });

    test('clamps out-of-range input to valid indices', () {
      expect(lonToTileX(200, 3), 7);
      expect(latToTileY(-90, 3), 7);
      expect(latToTileY(90, 3), 0);
    });

    test('isValidTile', () {
      expect(isValidTile(0, 0, 0), isTrue);
      expect(isValidTile(2, 3, 3), isTrue);
      expect(isValidTile(2, 4, 0), isFalse);
      expect(isValidTile(15, 0, 0, maxZoom: 14), isFalse);
      expect(isValidTile(1, -1, 0), isFalse);
    });
  });

  group('ranges', () {
    const world = GeoBounds(minLon: -180, minLat: -85, maxLon: 180, maxLat: 85);

    test('whole world z0..2 = 1 + 4 + 16', () {
      expect(countTiles(world, 0, 2), 21);
      final r = tileRanges(world, 2, 2).single;
      expect(r, const TileRange(2, 0, 3, 0, 3));
    });

    test('north maps to smaller y', () {
      const b = GeoBounds(minLon: 107.5, minLat: -7.0, maxLon: 107.7, maxLat: -6.8);
      final r = tileRanges(b, 12, 12).single;
      expect(r.minY, lessThanOrEqualTo(r.maxY));
      expect(r.minX, lessThanOrEqualTo(r.maxX));
      expect(r.count, (r.maxX - r.minX + 1) * (r.maxY - r.minY + 1));
    });

    test('tilesIn enumerates exactly countTiles, low zoom first', () {
      final b = boundsAround(-6.9, 107.6, 5);
      final ranges = tileRanges(b, 8, 12);
      final all = tilesIn(ranges).toList();
      expect(all.length, countTiles(b, 8, 12));
      expect(all.first.$1, 8);
      expect(all.last.$1, 12);
      expect(all.toSet().length, all.length);
    });

    test('tile count grows ~4x per zoom for a fixed area', () {
      final b = boundsAround(-6.9, 107.6, 25);
      final c13 = countTiles(b, 13, 13);
      final c14 = countTiles(b, 14, 14);
      expect(c14 / c13, inInclusiveRange(3.0, 5.0));
    });
  });

  group('boundsAround', () {
    test('25 km box is ~50 km across at the equator', () {
      final b = boundsAround(0, 100, 25);
      expect((b.maxLat - b.minLat) * 111.32, closeTo(50, 0.5));
      expect((b.maxLon - b.minLon) * 111.32, closeTo(50, 0.5));
    });

    test('longitude span widens with latitude', () {
      final eq = boundsAround(0, 10, 10);
      final north = boundsAround(60, 10, 10);
      expect(north.maxLon - north.minLon,
          closeTo(2 * (eq.maxLon - eq.minLon), 0.01));
    });

    test('25 km around Bandung z5..14 stays well under the 30k cap', () {
      final n = countTiles(boundsAround(-6.9, 107.6, 25), 5, 14);
      expect(n, greaterThan(400));
      expect(n, lessThan(2000));
    });
  });

  test('estimateBytes', () {
    expect(estimateBytes(0), 0);
    expect(estimateBytes(100), 100 * avgTileBytes);
    expect(estimateBytes(10, perTile: 1000), 10000);
  });

  test('orphanTiles keeps tiles shared with another region', () {
    OfflineRegion region(String id, GeoBounds b) => OfflineRegion(
        id: id, name: id, bounds: b, minZoom: 10, maxZoom: 12,
        tileCount: 0, sizeBytes: 0, createdAt: DateTime.utc(2026));
    final a = region('a', boundsAround(-6.9, 107.6, 10));
    final inner = region('b', boundsAround(-6.9, 107.6, 3));
    final orphans = orphanTiles(a, [inner]).toList();
    final innerTiles = tilesIn(inner.ranges).toSet();
    expect(orphans, isNotEmpty);
    expect(orphans.any(innerTiles.contains), isFalse);
    expect(orphans.length + innerTiles.length, countTiles(a.bounds, 10, 12));
    expect(orphanTiles(a, const []).length, countTiles(a.bounds, 10, 12));
  });

  test('OfflineRegion json round-trip', () {
    final r = OfflineRegion(
        id: 'x', name: 'Lembang', bounds: boundsAround(-6.8, 107.6, 10),
        minZoom: 5, maxZoom: 14, tileCount: 123, sizeBytes: 456,
        createdAt: DateTime.utc(2026, 11, 8), complete: true);
    final back = OfflineRegion.fromJson(r.toJson());
    expect(back.name, 'Lembang');
    expect(back.bounds.minLat, r.bounds.minLat);
    expect(back.tileCount, 123);
    expect(back.complete, isTrue);
    expect(back.createdAt, r.createdAt);
  });
}
