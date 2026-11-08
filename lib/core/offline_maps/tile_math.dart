/// Pure slippy-map tile math (Web Mercator, XYZ scheme). No I/O.
library;

import 'dart:math' as math;

/// Web Mercator latitude limit.
const double maxMercatorLat = 85.0511287798;

/// Rough average size of one OpenMapTiles vector tile, used for estimates.
const int avgTileBytes = 30 * 1024;

/// Geographic bounding box in degrees.
class GeoBounds {
  final double minLon, minLat, maxLon, maxLat;
  const GeoBounds({
    required this.minLon,
    required this.minLat,
    required this.maxLon,
    required this.maxLat,
  });

  Map<String, Object?> toJson() => {
    'minLon': minLon,
    'minLat': minLat,
    'maxLon': maxLon,
    'maxLat': maxLat,
  };

  static GeoBounds fromJson(Map<String, Object?> j) => GeoBounds(
    minLon: (j['minLon'] as num).toDouble(),
    minLat: (j['minLat'] as num).toDouble(),
    maxLon: (j['maxLon'] as num).toDouble(),
    maxLat: (j['maxLat'] as num).toDouble(),
  );
}

/// Inclusive tile index range at one zoom level.
class TileRange {
  final int z, minX, maxX, minY, maxY;
  const TileRange(this.z, this.minX, this.maxX, this.minY, this.maxY);

  int get count => (maxX - minX + 1) * (maxY - minY + 1);

  bool contains(int x, int y) =>
      x >= minX && x <= maxX && y >= minY && y <= maxY;

  @override
  bool operator ==(Object other) =>
      other is TileRange &&
      other.z == z &&
      other.minX == minX &&
      other.maxX == maxX &&
      other.minY == minY &&
      other.maxY == maxY;
  @override
  int get hashCode => Object.hash(z, minX, maxX, minY, maxY);
  @override
  String toString() => 'TileRange(z$z x$minX-$maxX y$minY-$maxY)';
}

int _clampIndex(int v, int z) => v.clamp(0, (1 << z) - 1);

int lonToTileX(double lon, int z) {
  final l = lon.clamp(-180.0, 180.0);
  return _clampIndex(((l + 180.0) / 360.0 * (1 << z)).floor(), z);
}

int latToTileY(double lat, int z) {
  final l = lat.clamp(-maxMercatorLat, maxMercatorLat) * math.pi / 180.0;
  final y = (1 - math.log(math.tan(l) + 1 / math.cos(l)) / math.pi) / 2;
  return _clampIndex((y * (1 << z)).floor(), z);
}

/// True when z/x/y addresses an existing tile.
bool isValidTile(int z, int x, int y, {int maxZoom = 22}) =>
    z >= 0 && z <= maxZoom && x >= 0 && y >= 0 && x < (1 << z) && y < (1 << z);

/// One [TileRange] per zoom in [minZoom]..[maxZoom] covering [b].
List<TileRange> tileRanges(GeoBounds b, int minZoom, int maxZoom) => [
  for (var z = minZoom; z <= maxZoom; z++)
    TileRange(
      z,
      lonToTileX(b.minLon, z),
      lonToTileX(b.maxLon, z),
      latToTileY(b.maxLat, z), // north = smaller y
      latToTileY(b.minLat, z),
    ),
];

int countTiles(GeoBounds b, int minZoom, int maxZoom) =>
    tileRanges(b, minZoom, maxZoom).fold(0, (s, r) => s + r.count);

/// Every (z, x, y) inside [ranges], low zooms first.
Iterable<(int, int, int)> tilesIn(List<TileRange> ranges) sync* {
  for (final r in ranges) {
    for (var x = r.minX; x <= r.maxX; x++) {
      for (var y = r.minY; y <= r.maxY; y++) {
        yield (r.z, x, y);
      }
    }
  }
}

/// Square box of half-width [radiusKm] around a point.
GeoBounds boundsAround(double lat, double lon, double radiusKm) {
  const kmPerDegLat = 111.32;
  final dLat = radiusKm / kmPerDegLat;
  final cosLat = math.cos(lat * math.pi / 180.0).abs().clamp(0.01, 1.0);
  final dLon = (radiusKm / (kmPerDegLat * cosLat)).clamp(0.0, 180.0);
  return GeoBounds(
    minLon: (lon - dLon).clamp(-180.0, 180.0),
    minLat: (lat - dLat).clamp(-maxMercatorLat, maxMercatorLat),
    maxLon: (lon + dLon).clamp(-180.0, 180.0),
    maxLat: (lat + dLat).clamp(-maxMercatorLat, maxMercatorLat),
  );
}

int estimateBytes(int tileCount, {int perTile = avgTileBytes}) =>
    tileCount * perTile;
