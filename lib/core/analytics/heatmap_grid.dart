import 'dart:math' as math;
import 'dart:typed_data';

/// One occupied pixel of the heatmap at the grid's base zoom.
class HeatCell {
  final int x, y; // global Web Mercator pixel (256 px tiles)
  final int count; // number of tracks passing this pixel
  const HeatCell(this.x, this.y, this.count);
}

/// Personal heatmap accumulator: rasterises many tracks into Web Mercator
/// pixels at [zoom]. Each track counts at most once per pixel, so the
/// density means "how many activities went here".
class HeatmapGrid {
  final int zoom;
  final Map<int, int> _counts = {};
  int _tracks = 0;
  int _max = 0;

  HeatmapGrid({this.zoom = 14}) : assert(zoom >= 0 && zoom <= 20);

  int get worldSize => 256 << zoom;
  int get trackCount => _tracks;
  int get maxCount => _max;
  int get cellCount => _counts.length;

  static const int _shift = 1 << 29; // key = x * 2^29 + y (zoom ≤ 20)

  /// Fractional global pixel for lat/lon at this grid's zoom.
  (double, double) project(double lat, double lon) {
    final size = worldSize.toDouble();
    final x = (lon + 180) / 360 * size;
    final la = lat.clamp(-85.05112878, 85.05112878) * math.pi / 180;
    final y = (1 - math.log(math.tan(la) + 1 / math.cos(la)) / math.pi) /
        2 *
        size;
    return (x, y);
  }

  /// Add one track. Segments longer than [maxJumpPx] are treated as gaps.
  void addTrack(Iterable<(double, double)> latLon, {double maxJumpPx = 512}) {
    final seen = <int>{};
    final limit = worldSize - 1;
    double? px, py;
    void mark(double x, double y) {
      final ix = x.floor().clamp(0, limit), iy = y.floor().clamp(0, limit);
      seen.add(ix * _shift + iy);
    }

    for (final (lat, lon) in latLon) {
      if (lat.isNaN || lon.isNaN) continue;
      final (x, y) = project(lat, lon);
      if (px == null || py == null) {
        mark(x, y);
      } else {
        final dx = x - px, dy = y - py;
        final len = math.sqrt(dx * dx + dy * dy);
        if (len <= maxJumpPx) {
          final steps = len.ceil();
          for (var k = 1; k <= steps; k++) {
            mark(px + dx * k / steps, py + dy * k / steps);
          }
        }
        mark(x, y);
      }
      px = x;
      py = y;
    }
    if (seen.isEmpty) return;
    _tracks++;
    for (final key in seen) {
      final c = (_counts[key] ?? 0) + 1;
      _counts[key] = c;
      if (c > _max) _max = c;
    }
  }

  int countAtPixel(int x, int y) => _counts[x * _shift + y] ?? 0;

  Iterable<HeatCell> get cells => _counts.entries
      .map((e) => HeatCell(e.key ~/ _shift, e.key % _shift, e.value));

  /// Center lat/lon of a global pixel at this grid's zoom.
  (double, double) pixelToLatLon(double x, double y) {
    final size = worldSize.toDouble();
    final lon = x / size * 360 - 180;
    final n = math.pi - 2 * math.pi * y / size;
    final lat = 180 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
    return (lat, lon);
  }

  /// 256×256 density for tile (z, tx, ty) with z ≤ [zoom]; base pixels are
  /// summed into each output pixel. Row-major, index = py * 256 + px.
  Uint32List tileDensity(int z, int tx, int ty) {
    assert(z <= zoom);
    final out = Uint32List(256 * 256);
    final shift = zoom - z;
    _counts.forEach((key, c) {
      final x = (key ~/ _shift) >> shift, y = (key % _shift) >> shift;
      if (x >> 8 != tx || y >> 8 != ty) return;
      out[(y & 255) * 256 + (x & 255)] += c;
    });
    return out;
  }

  void clear() {
    _counts.clear();
    _tracks = 0;
    _max = 0;
  }
}
