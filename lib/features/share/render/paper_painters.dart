import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:stravo/app/theme/field_notes.dart';

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

/// Contour texture filling [rect].
void paintContours(
  Canvas canvas,
  Rect rect, {
  required int seed,
  Color color = FN.paperLine,
  double width = 0.7,
  Color? indexColor,
  int cols = 48,
}) {
  final field = ContourField.of(seed, aspect: rect.height / rect.width, cols: cols);
  final paths = field.pathsFor(rect.size);
  final thin = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..color = color;
  final bold = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width * 1.9
    ..color = indexColor ?? color;
  canvas.save();
  canvas.clipRect(rect);
  canvas.translate(rect.left, rect.top);
  for (var k = 0; k < paths.length; k++) {
    canvas.drawPath(paths[k], k % 5 == 2 ? bold : thin);
  }
  canvas.restore();
}

final _grainCache = <String, (Float32List, Float32List)>{};

/// Paper grain: deterministic dark + light specks.
void paintGrain(
  Canvas canvas,
  Rect rect, {
  required int seed,
  double density = 0.05,
  Color dark = const Color(0x22141414),
  Color light = const Color(0x33FFFFFF),
  double dot = 0.7,
}) {
  final n = (rect.width * rect.height * density).round().clamp(0, 60000);
  final key = '$seed:${rect.width.round()}:${rect.height.round()}:$n';
  var pts = _grainCache[key];
  if (pts == null) {
    if (_grainCache.length > 8) _grainCache.remove(_grainCache.keys.first);
    final r = math.Random(seed);
    Float32List gen(int count) {
      final l = Float32List(count * 2);
      for (var i = 0; i < count; i++) {
        l[i * 2] = r.nextDouble() * rect.width;
        l[i * 2 + 1] = r.nextDouble() * rect.height;
      }
      return l;
    }

    pts = _grainCache[key] = (gen(n), gen(n ~/ 2));
  }
  canvas.save();
  canvas.translate(rect.left, rect.top);
  final p = Paint()
    ..strokeWidth = dot
    ..strokeCap = StrokeCap.round;
  canvas.drawRawPoints(PointMode.points, pts.$1, p..color = dark);
  canvas.drawRawPoints(PointMode.points, pts.$2, p..color = light);
  canvas.restore();
}

/// Ink route with optional ink-bleed halo.
void paintRoute(
  Canvas canvas,
  List<Offset> pts, {
  required Color color,
  double width = 2.4,
  bool bleed = true,
  Color? outline,
  double outlineWidth = 0,
  Shadow? shadow,
}) {
  if (pts.length < 2) return;
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (var i = 1; i < pts.length; i++) {
    path.lineTo(pts[i].dx, pts[i].dy);
  }
  Paint stroke(Color c, double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = c;
  if (shadow != null) {
    canvas.drawPath(
        path.shift(shadow.offset),
        stroke(shadow.color, width + outlineWidth * 2)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma));
  }
  if (outline != null && outlineWidth > 0) {
    canvas.drawPath(path, stroke(outline, width + outlineWidth * 2));
  }
  if (bleed) {
    canvas.drawPath(
        path,
        stroke(color.withValues(alpha: color.a * 0.28), width * 2.2)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 0.9));
  }
  canvas.drawPath(path, stroke(color, width));
}

/// Start ring and finish block.
void paintStartFinish(
  Canvas canvas,
  Offset start,
  Offset finish, {
  required Color color,
  double size = 6,
  Color? fill,
}) {
  final ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.4
    ..color = color;
  if (fill != null) {
    canvas.drawCircle(start, size, Paint()..color = fill);
  }
  canvas.drawCircle(start, size, ring);
  canvas.drawCircle(start, size * 0.35, Paint()..color = color);
  final r = Rect.fromCenter(center: finish, width: size * 1.5, height: size * 1.5);
  canvas.save();
  canvas.translate(finish.dx, finish.dy);
  canvas.rotate(math.pi / 4);
  canvas.translate(-finish.dx, -finish.dy);
  if (fill != null) canvas.drawRect(r.inflate(size * 0.3), Paint()..color = fill);
  canvas.drawRect(r, Paint()..color = color);
  canvas.restore();
}

/// Elevation silhouette, optionally colored by grade, with hatching.
/// Returns the top-edge points (for annotation).
List<Offset> paintElevation(
  Canvas canvas,
  Rect rect, {
  required List<double> dist,
  required List<double> ele,
  List<double>? grade,
  bool byGrade = true,
  Color fill = FN.ink,
  Color edge = FN.ink,
  double edgeWidth = 1.4,
  bool hatch = true,
  Color hatchColor = const Color(0x33141414),
  double headroom = 0.08,
}) {
  final n = math.min(dist.length, ele.length);
  if (n < 2) return const [];
  final total = math.max(dist[n - 1] - dist[0], 1e-6);
  var lo = ele[0], hi = ele[0];
  for (var i = 1; i < n; i++) {
    lo = math.min(lo, ele[i]);
    hi = math.max(hi, ele[i]);
  }
  final span = math.max(hi - lo, 20.0);
  final h = rect.height * (1 - headroom);
  final pts = <Offset>[
    for (var i = 0; i < n; i++)
      Offset(rect.left + (dist[i] - dist[0]) / total * rect.width,
          rect.bottom - (ele[i] - lo) / span * h * 0.94 - rect.height * 0.04),
  ];
  final whole = Path()..moveTo(rect.left, rect.bottom);
  for (final p in pts) {
    whole.lineTo(p.dx, p.dy);
  }
  whole
    ..lineTo(rect.right, rect.bottom)
    ..close();

  if (byGrade && grade != null && grade.length >= n) {
    var i = 1;
    while (i < n) {
      final c = FN.grade(grade[i]);
      final seg = Path()
        ..moveTo(pts[i - 1].dx, rect.bottom)
        ..lineTo(pts[i - 1].dx, pts[i - 1].dy);
      var j = i;
      while (j < n && FN.grade(grade[j]) == c) {
        seg.lineTo(pts[j].dx, pts[j].dy);
        j++;
      }
      final last = pts[j - 1];
      seg
        ..lineTo(last.dx, rect.bottom)
        ..close();
      canvas.drawPath(seg, Paint()..color = c);
      i = j;
    }
  } else {
    canvas.drawPath(whole, Paint()..color = fill);
  }
  if (hatch) {
    canvas.save();
    canvas.clipPath(whole);
    final hp = Paint()
      ..color = hatchColor
      ..strokeWidth = 0.8;
    for (var x = rect.left - rect.height; x < rect.right; x += 4) {
      canvas.drawLine(Offset(x, rect.bottom), Offset(x + rect.height, rect.top), hp);
    }
    canvas.restore();
  }
  final top = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (final p in pts.skip(1)) {
    top.lineTo(p.dx, p.dy);
  }
  canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = edgeWidth
        ..strokeJoin = StrokeJoin.round
        ..color = edge);
  canvas.drawLine(rect.bottomLeft, rect.bottomRight,
      Paint()
        ..color = edge
        ..strokeWidth = 1);
  return pts;
}

/// Mono text helper for painters.
TextPainter monoText(
  String s, {
  double size = 9,
  Color color = FN.ink,
  FontWeight weight = FontWeight.w500,
  double spacing = 1.2,
  String family = FN.mono,
  double? height,
  List<Shadow>? shadows,
}) =>
    TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: family,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: color,
          height: height,
          shadows: shadows,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
