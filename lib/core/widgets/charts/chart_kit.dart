import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Shared helpers for the CustomPainter charts.
class ChartKit {
  ChartKit._();

  /// "Nice" tick values between [min] and [max], about [count] ticks.
  static List<double> niceTicks(double min, double max, {int count = 4}) {
    if (!min.isFinite || !max.isFinite) return const [];
    if (max <= min) return [min];
    final raw = (max - min) / count;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final norm = raw / mag;
    final step =
        (norm < 1.5
            ? 1
            : norm < 3
            ? 2
            : norm < 7
            ? 5
            : 10) *
        mag;
    final start = (min / step).ceil() * step;
    return [for (var v = start; v <= max + 1e-9; v += step) v];
  }

  static void text(
    Canvas canvas,
    String s,
    Offset at, {
    Color? color,
    double size = 9,
    TextAlign align = TextAlign.left,
    bool bold = false,
    Color? background,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: FN
            .label(size: size, color: color ?? FN.inkMuted)
            .copyWith(
              letterSpacing: 0.6,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    var dx = at.dx;
    if (align == TextAlign.right) dx -= tp.width;
    if (align == TextAlign.center) dx -= tp.width / 2;
    final o = Offset(dx, at.dy);
    if (background != null) {
      canvas.drawRect(
        Rect.fromLTWH(o.dx - 2, o.dy - 1, tp.width + 4, tp.height + 2),
        Paint()..color = background,
      );
    }
    tp.paint(canvas, o);
  }

  static void dashedH(
    Canvas canvas,
    double x0,
    double x1,
    double y,
    Paint paint, {
    double dash = 3,
    double gap = 3,
  }) {
    for (var x = x0; x < x1; x += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, x1), y), paint);
    }
  }
}

/// Layout gutters for axis charts.
class ChartFrame {
  final Rect plot;
  final double minX, maxX, minY, maxY;
  ChartFrame(
    Size size, {
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    double left = 38,
    double right = 6,
    double top = 8,
    double bottom = 18,
  }) : plot = Rect.fromLTRB(
         left,
         top,
         size.width - right,
         size.height - bottom,
       );

  double x(double v) =>
      plot.left + (maxX == minX ? 0 : (v - minX) / (maxX - minX)) * plot.width;
  double y(double v) =>
      plot.bottom -
      (maxY == minY ? 0.5 : (v - minY) / (maxY - minY)) * plot.height;
}
