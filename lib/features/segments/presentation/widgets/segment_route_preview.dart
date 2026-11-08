import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Rute lengkap yang samar, dengan potongan terpilih yang tebal.
class SegmentRoutePreview extends StatelessWidget {
  final List<(double lat, double lon)> points;
  final int startIndex;
  final int endIndex;

  const SegmentRoutePreview({
    super.key,
    required this.points,
    required this.startIndex,
    required this.endIndex,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _PreviewPainter(
      points,
      startIndex,
      endIndex,
      route: FN.paperLine,
      selected: FN.signal,
      dot: FN.ink,
    ),
    size: Size.infinite,
  );
}

class _PreviewPainter extends CustomPainter {
  /// Batas titik yang digambar, karena ini dilukis ulang tiap slider bergeser.
  static const int _maxPoints = 500;

  final List<(double, double)> points;
  final int start, end;
  final Color route, selected, dot;

  _PreviewPainter(
    this.points,
    this.start,
    this.end, {
    required this.route,
    required this.selected,
    required this.dot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    var minLat = double.infinity, maxLat = -double.infinity;
    var minLon = double.infinity, maxLon = -double.infinity;
    for (final (lat, lon) in points) {
      minLat = math.min(minLat, lat);
      maxLat = math.max(maxLat, lat);
      minLon = math.min(minLon, lon);
      maxLon = math.max(maxLon, lon);
    }
    final kx = math.cos((minLat + maxLat) / 2 * math.pi / 180).abs();
    final w = math.max((maxLon - minLon) * kx, 1e-9);
    final h = math.max(maxLat - minLat, 1e-9);
    const pad = 14.0;
    final scale = math.min(
      (size.width - pad * 2) / w,
      (size.height - pad * 2) / h,
    );
    final dx = (size.width - w * scale) / 2;
    final dy = (size.height - h * scale) / 2;
    Offset at(int i) {
      final (lat, lon) = points[i];
      return Offset(
        dx + (lon - minLon) * kx * scale,
        size.height - dy - (lat - minLat) * scale,
      );
    }

    Path line(int from, int to) {
      final stride = math.max(1, (to - from) ~/ _maxPoints);
      final first = at(from);
      final p = Path()..moveTo(first.dx, first.dy);
      for (var i = from + stride; i < to; i += stride) {
        final o = at(i);
        p.lineTo(o.dx, o.dy);
      }
      final last = at(to);
      return p..lineTo(last.dx, last.dy);
    }

    Paint stroke(Color c, double width) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(line(0, points.length - 1), stroke(route, 2));
    if (end <= start) return;
    canvas.drawPath(line(start, end), stroke(selected, 3.5));
    canvas.drawCircle(at(start), 5, Paint()..color = selected);
    canvas.drawCircle(at(end), 5, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(_PreviewPainter old) =>
      old.start != start ||
      old.end != end ||
      !identical(old.points, points) ||
      old.selected != selected;
}
