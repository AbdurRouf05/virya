import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stravo/app/theme/field_notes.dart';

/// Lightweight route sketch (equirectangular, aspect-correct) with start dot
/// and finish square. Optional per-point colors.
class RouteThumbnail extends StatelessWidget {
  final List<(double lat, double lon)> points;
  final Color color;
  final double strokeWidth;
  final List<Color>? colors;
  final EdgeInsets padding;

  const RouteThumbnail({
    super.key,
    required this.points,
    this.color = FN.ink,
    this.strokeWidth = 1.6,
    this.colors,
    this.padding = const EdgeInsets.all(6),
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: RoutePainter(points,
            color: color,
            strokeWidth: strokeWidth,
            colors: colors,
            padding: padding),
        size: Size.infinite,
      ),
    );
  }
}

class RoutePainter extends CustomPainter {
  final List<(double, double)> points;
  final Color color;
  final double strokeWidth;
  final List<Color>? colors;
  final EdgeInsets padding;

  RoutePainter(this.points,
      {required this.color,
      required this.strokeWidth,
      this.colors,
      this.padding = const EdgeInsets.all(6)});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    var minLat = 90.0, maxLat = -90.0, minLon = 180.0, maxLon = -180.0;
    for (final (la, lo) in points) {
      minLat = math.min(minLat, la);
      maxLat = math.max(maxLat, la);
      minLon = math.min(minLon, lo);
      maxLon = math.max(maxLon, lo);
    }
    final k = math.cos((minLat + maxLat) / 2 * math.pi / 180);
    final w = math.max((maxLon - minLon) * k, 1e-9);
    final h = math.max(maxLat - minLat, 1e-9);
    final area = padding.deflateRect(Offset.zero & size);
    final scale = math.min(area.width / w, area.height / h);
    final ox = area.left + (area.width - w * scale) / 2;
    final oy = area.top + (area.height - h * scale) / 2;
    Offset map((double, double) p) => Offset(
        ox + (p.$2 - minLon) * k * scale, oy + (maxLat - p.$1) * scale);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (colors != null && colors!.length == points.length) {
      for (var i = 1; i < points.length; i++) {
        paint.color = colors![i];
        canvas.drawLine(map(points[i - 1]), map(points[i]), paint);
      }
    } else {
      final path = Path();
      final s = map(points.first);
      path.moveTo(s.dx, s.dy);
      for (var i = 1; i < points.length; i++) {
        final p = map(points[i]);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
    final start = map(points.first), end = map(points.last);
    final r = strokeWidth * 1.8 + 1;
    canvas.drawCircle(start, r, Paint()..color = FN.signal);
    canvas.drawRect(
        Rect.fromCenter(center: end, width: r * 2, height: r * 2),
        Paint()..color = color == FN.signal ? FN.ink : color);
  }

  @override
  bool shouldRepaint(RoutePainter old) =>
      !identical(old.points, points) ||
      old.color != color ||
      !identical(old.colors, colors);
}

/// Evenly down-sample a list to at most [max] items (keeps last).
List<T> downsample<T>(List<T> items, int max) {
  if (items.length <= max) return items;
  final step = items.length / max;
  final out = <T>[for (var i = 0; i < max; i++) items[(i * step).floor()]];
  out[out.length - 1] = items.last;
  return out;
}
