import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:virya/app/theme/field_notes.dart';

/// Procedural topographic contour lines (value-noise + marching squares).
/// Paths are in grid units; cached per (seed, cols, rows).
class ContourField {
  final int cols, rows;
  final List<Path> levels; // index contours: every 5th
  ContourField._(this.cols, this.rows, this.levels);

  static final _cache = <String, ContourField>{};

  static ContourField of(int seed, {double aspect = 1, int cols = 48}) {
    final rows = math.max(4, (cols * aspect).round());
    final key = '$seed:$cols:$rows';
    final hit = _cache[key];
    if (hit != null) return hit;
    if (_cache.length > 24) _cache.remove(_cache.keys.first);
    return _cache[key] = _build(seed, cols, rows);
  }

  static ContourField _build(int seed, int cols, int rows) {
    final v = Float64List((cols + 1) * (rows + 1));
    var lo = double.infinity, hi = -double.infinity;
    for (var j = 0; j <= rows; j++) {
      for (var i = 0; i <= cols; i++) {
        final x = i / cols, y = j / cols;
        final n = _noise(x * 2.3, y * 2.3, seed) +
            0.5 * _noise(x * 5.1, y * 5.1, seed + 17) +
            0.22 * _noise(x * 10.7, y * 10.7, seed + 41);
        v[j * (cols + 1) + i] = n;
        lo = math.min(lo, n);
        hi = math.max(hi, n);
      }
    }
    const nLevels = 14;
    final paths = <Path>[];
    for (var k = 0; k < nLevels; k++) {
      final level = lo + (k + 0.5) * (hi - lo) / nLevels;
      final p = Path();
      for (var j = 0; j < rows; j++) {
        for (var i = 0; i < cols; i++) {
          final a = v[j * (cols + 1) + i];
          final b = v[j * (cols + 1) + i + 1];
          final c = v[(j + 1) * (cols + 1) + i + 1];
          final d = v[(j + 1) * (cols + 1) + i];
          final idx = (a > level ? 8 : 0) |
              (b > level ? 4 : 0) |
              (c > level ? 2 : 0) |
              (d > level ? 1 : 0);
          if (idx == 0 || idx == 15) continue;
          double t(double p0, double p1) =>
              (p1 - p0).abs() < 1e-12 ? .5 : (level - p0) / (p1 - p0);
          Offset top() => Offset(i + t(a, b), j.toDouble());
          Offset right() => Offset(i + 1.0, j + t(b, c));
          Offset bottom() => Offset(i + t(d, c), j + 1.0);
          Offset left() => Offset(i.toDouble(), j + t(a, d));
          void seg(Offset p0, Offset p1) {
            p.moveTo(p0.dx, p0.dy);
            p.lineTo(p1.dx, p1.dy);
          }

          switch (idx) {
            case 1 || 14:
              seg(left(), bottom());
            case 2 || 13:
              seg(bottom(), right());
            case 3 || 12:
              seg(left(), right());
            case 4 || 11:
              seg(top(), right());
            case 5:
              seg(left(), top());
              seg(bottom(), right());
            case 6 || 9:
              seg(top(), bottom());
            case 7 || 8:
              seg(left(), top());
            case 10:
              seg(top(), right());
              seg(left(), bottom());
          }
        }
      }
      paths.add(p);
    }
    return ContourField._(cols, rows, paths);
  }

  final _scaled = <Size, List<Path>>{};

  /// Paths scaled to [size].
  List<Path> pathsFor(Size size) {
    final hit = _scaled[size];
    if (hit != null) return hit;
    if (_scaled.length > 6) _scaled.remove(_scaled.keys.first);
    final m = Float64List(16)
      ..[0] = size.width / cols
      ..[5] = size.height / rows
      ..[10] = 1
      ..[15] = 1;
    return _scaled[size] = [for (final p in levels) p.transform(m)];
  }

  static double _hash(int x, int y, int seed) {
    var h = (x * 374761393 + y * 668265263 + seed * 1442695041) & 0x7FFFFFFF;
    h = ((h ^ (h >> 13)) * 1274126177) & 0x7FFFFFFF;
    h = h ^ (h >> 16);
    return (h & 0xFFFF) / 0xFFFF;
  }

  static double _noise(double x, double y, int seed) {
    final xi = x.floor(), yi = y.floor();
    final xf = x - xi, yf = y - yi;
    final u = xf * xf * (3 - 2 * xf), w = yf * yf * (3 - 2 * yf);
    final a = _hash(xi, yi, seed), b = _hash(xi + 1, yi, seed);
    final c = _hash(xi, yi + 1, seed), d = _hash(xi + 1, yi + 1, seed);
    return a + (b - a) * u + (c - a) * w + (a - b - c + d) * u * w;
  }
}

/// Contour texture filling [rect]. [color] defaults to `FN.paperLine`.
void paintContours(
  Canvas canvas,
  Rect rect, {
  required int seed,
  Color? color,
  double width = 0.7,
  Color? indexColor,
  int cols = 48,
}) {
  final c = color ?? FN.paperLine;
  final field = ContourField.of(seed, aspect: rect.height / rect.width, cols: cols);
  final paths = field.pathsFor(rect.size);
  final thin = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..color = c;
  final bold = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width * 1.9
    ..color = indexColor ?? c;
  canvas.save();
  canvas.clipRect(rect);
  canvas.translate(rect.left, rect.top);
  for (var k = 0; k < paths.length; k++) {
    canvas.drawPath(paths[k], k % 5 == 2 ? bold : thin);
  }
  canvas.restore();
}
