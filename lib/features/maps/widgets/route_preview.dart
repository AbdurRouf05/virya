import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/features/maps/domain/route_geometry.dart';
import 'package:virya/features/maps/widgets/route_map_view.dart';
import 'package:virya/features/maps/widgets/virya_map_controller.dart';

/// Per-point colours for [mode] (same rules as the JS side).
List<Color>? routeColors(List<double>? values, RouteColorMode mode) {
  if (values == null || values.isEmpty || mode == RouteColorMode.plain) {
    return null;
  }
  switch (mode) {
    case RouteColorMode.surface:
      return [
        for (final v in values)
          FN.surface[SurfaceType.values[
                  v.isFinite ? v.round().clamp(0, SurfaceType.values.length - 1) : 5]] ??
              FN.signal
      ];
    case RouteColorMode.grade:
      return [for (final v in values) FN.grade(v.isFinite ? v : 0)];
    case RouteColorMode.speed:
      final sorted = values.where((v) => v.isFinite).toList()..sort();
      if (sorted.isEmpty) return null;
      final lo = sorted[((sorted.length - 1) * .05).floor()];
      final hi = sorted[((sorted.length - 1) * .95).floor()];
      return [
        for (final v in values)
          routeSpeedRamp[(((hi > lo ? (v - lo) / (hi - lo) : .5).clamp(0.0, .9999)) *
                  routeSpeedRamp.length)
              .floor()]
      ];
    case RouteColorMode.plain:
      return null;
  }
}

/// Paper-styled route drawing used when no WebView is available
/// (tests/desktop) and while the map loads.
class RoutePreview extends StatelessWidget {
  const RoutePreview({
    super.key,
    required this.points,
    this.colors,
    this.currentPosition,
    this.bearing,
    this.progress,
    this.caption,
  });

  final List<LatLon> points;
  final List<Color>? colors;
  final LatLon? currentPosition;
  final double? bearing;

  /// When set (0..1), draws a tracer up to this fraction (flyover fallback).
  final double? progress;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: RoutePreviewPainter(
          points: points,
          colors: colors,
          currentPosition: currentPosition,
          bearing: bearing,
          progress: progress,
        ),
        child: caption == null
            ? const SizedBox.expand()
            : Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(caption!, style: FN.label(size: 9)),
                ),
              ),
      ),
    );
  }
}

class RoutePreviewPainter extends CustomPainter {
  RoutePreviewPainter({
    required this.points,
    this.colors,
    this.currentPosition,
    this.bearing,
    this.progress,
  });

  final List<LatLon> points;
  final List<Color>? colors;
  final LatLon? currentPosition;
  final double? bearing;
  final double? progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = FN.paper);
    // Survey grid.
    final grid = Paint()
      ..color = FN.paperLine.withValues(alpha: .6)
      ..strokeWidth = .6;
    const step = 28.0;
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final all = [...points, if (currentPosition != null) currentPosition!];
    if (all.isEmpty) return;

    // Fit with equirectangular projection.
    var minLat = all.first.$1, maxLat = minLat;
    var minLon = all.first.$2, maxLon = minLon;
    for (final p in all) {
      minLat = math.min(minLat, p.$1);
      maxLat = math.max(maxLat, p.$1);
      minLon = math.min(minLon, p.$2);
      maxLon = math.max(maxLon, p.$2);
    }
    final kx = math.cos((minLat + maxLat) / 2 * math.pi / 180);
    final w = math.max(1e-6, (maxLon - minLon) * kx);
    final h = math.max(1e-6, maxLat - minLat);
    const pad = 20.0;
    final s = math.min(
        (size.width - 2 * pad) / w, (size.height - 2 * pad) / h);
    final ox = (size.width - w * s) / 2, oy = (size.height - h * s) / 2;
    Offset proj(LatLon p) =>
        Offset(ox + (p.$2 - minLon) * kx * s, oy + (maxLat - p.$1) * s);

    if (points.length >= 2) {
      final path = Path()..moveTo(proj(points.first).dx, proj(points.first).dy);
      for (final p in points.skip(1)) {
        final o = proj(p);
        path.lineTo(o.dx, o.dy);
      }
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(
          path,
          stroke
            ..color = FN.ink.withValues(alpha: progress == null ? 1 : .25)
            ..strokeWidth = 6);
      final cols = colors;
      final lastIdx = progress == null
          ? points.length - 1
          : (progress!.clamp(0.0, 1.0) * (points.length - 1)).round();
      final inner = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3;
      if (cols == null || cols.length != points.length) {
        final pp = Path()..moveTo(proj(points.first).dx, proj(points.first).dy);
        for (var i = 1; i <= lastIdx; i++) {
          final o = proj(points[i]);
          pp.lineTo(o.dx, o.dy);
        }
        canvas.drawPath(pp, inner..color = FN.signal);
      } else {
        for (var i = 0; i < lastIdx; i++) {
          canvas.drawLine(
              proj(points[i]), proj(points[i + 1]), inner..color = cols[i]);
        }
      }
      // Start (orange) + finish (ink).
      final st = proj(points.first), fi = proj(points.last);
      canvas.drawCircle(fi, 6, Paint()..color = FN.paper);
      canvas.drawCircle(fi, 4.5, Paint()..color = FN.ink);
      canvas.drawCircle(st, 6, Paint()..color = FN.ink);
      canvas.drawCircle(st, 4.5, Paint()..color = FN.signal);
      if (progress != null && lastIdx >= 0) {
        canvas.drawCircle(proj(points[lastIdx]), 7, Paint()..color = FN.paper);
        canvas.drawCircle(proj(points[lastIdx]), 5, Paint()..color = FN.signal);
      }
    }
    final cp = currentPosition;
    if (cp != null) {
      final o = proj(cp);
      canvas.drawCircle(o, 8, Paint()..color = FN.paper);
      canvas.drawCircle(o, 6, Paint()..color = FN.signal);
      if (bearing != null) {
        final a = (bearing! - 90) * math.pi / 180;
        canvas.drawLine(
            o,
            o + Offset(math.cos(a), math.sin(a)) * 14,
            Paint()
              ..color = FN.ink
              ..strokeWidth = 2.5);
      }
    }
  }

  @override
  bool shouldRepaint(RoutePreviewPainter old) =>
      !identical(old.points, points) ||
      old.points.length != points.length ||
      old.colors != colors ||
      old.currentPosition != currentPosition ||
      old.bearing != bearing ||
      old.progress != progress;
}
