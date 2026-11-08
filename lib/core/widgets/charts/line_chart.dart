import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/widgets/charts/chart_kit.dart';

/// Single-series line chart over distance. Nulls create gaps.
/// [invert] puts low values on top (pace: faster = higher).
class InkLineChart extends StatelessWidget {
  final List<double> x;
  final List<double?> y;
  final Color? _color;
  Color get color => _color ?? FN.ink;
  final double height;
  final bool invert;
  final bool fill;
  final double? average;
  final String Function(double v) formatY;
  final String Function(double x) formatX;
  final double? clampMin;
  final double? clampMax;

  const InkLineChart({
    super.key,
    required this.x,
    required this.y,
    required this.formatY,
    required this.formatX,
    Color? color,
    this.height = 140,
    this.invert = false,
    this.fill = true,
    this.average,
    this.clampMin,
    this.clampMax,
  }) : _color = color;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: RepaintBoundary(
        child: CustomPaint(painter: _LinePainter(this, fg)),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final InkLineChart w;
  final Color fg;
  _LinePainter(this.w, this.fg);

  @override
  void paint(Canvas canvas, Size size) {
    final n = math.min(w.x.length, w.y.length);
    final vals = <double>[
      for (var i = 0; i < n; i++)
        if (w.y[i] != null && w.y[i]!.isFinite) w.y[i]!,
    ];
    if (n < 2 || vals.length < 2) {
      ChartKit.text(
        canvas,
        'TIDAK ADA DATA',
        Offset(size.width / 2, size.height / 2 - 6),
        align: TextAlign.center,
      );
      return;
    }
    double clamp(double v) {
      if (w.clampMin != null && v < w.clampMin!) return w.clampMin!;
      if (w.clampMax != null && v > w.clampMax!) return w.clampMax!;
      return v;
    }

    var lo = clamp(vals.reduce(math.min)), hi = clamp(vals.reduce(math.max));
    final pad = math.max((hi - lo) * 0.1, 0.5);
    lo -= pad;
    hi += pad;
    final f = ChartFrame(
      size,
      minX: w.x.first,
      maxX: w.x[n - 1],
      minY: w.invert ? -hi : lo,
      maxY: w.invert ? -lo : hi,
    );
    double yy(double v) => f.y(w.invert ? -clamp(v) : clamp(v));

    final grid = Paint()
      ..color = fg.withValues(alpha: 0.18)
      ..strokeWidth = 0.7;
    for (final t in ChartKit.niceTicks(lo, hi, count: 3)) {
      ChartKit.dashedH(canvas, f.plot.left, f.plot.right, yy(t), grid);
      ChartKit.text(
        canvas,
        w.formatY(t),
        Offset(f.plot.left - 4, yy(t) - 6),
        align: TextAlign.right,
        color: fg.withValues(alpha: 0.6),
      );
    }

    final line = Path();
    final area = Path();
    var open = false;
    double? lastX;
    for (var i = 0; i < n; i++) {
      final v = w.y[i];
      final px = f.x(w.x[i]);
      if (v == null || !v.isFinite) {
        if (open && lastX != null) {
          area.lineTo(lastX, f.plot.bottom);
          area.close();
        }
        open = false;
        continue;
      }
      final py = yy(v);
      if (!open) {
        line.moveTo(px, py);
        area.moveTo(px, f.plot.bottom);
        area.lineTo(px, py);
        open = true;
      } else {
        line.lineTo(px, py);
        area.lineTo(px, py);
      }
      lastX = px;
    }
    if (open && lastX != null) {
      area.lineTo(lastX, f.plot.bottom);
      area.close();
    }
    if (w.fill) {
      canvas.drawPath(area, Paint()..color = w.color.withValues(alpha: 0.14));
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = w.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );

    if (w.average != null && w.average!.isFinite) {
      final ay = yy(w.average!);
      ChartKit.dashedH(
        canvas,
        f.plot.left,
        f.plot.right,
        ay,
        Paint()
          ..color = fg
          ..strokeWidth = 1,
        dash: 6,
        gap: 3,
      );
      ChartKit.text(
        canvas,
        'RATA ${w.formatY(w.average!)}',
        Offset(f.plot.right - 2, ay - 13),
        align: TextAlign.right,
        bold: true,
        color: FN.paper,
        background: fg,
      );
    }

    canvas.drawLine(
      f.plot.bottomLeft,
      f.plot.bottomRight,
      Paint()
        ..color = fg
        ..strokeWidth = 1,
    );
    for (final t in ChartKit.niceTicks(f.minX, f.maxX, count: 5)) {
      final x = f.x(t);
      canvas.drawLine(
        Offset(x, f.plot.bottom),
        Offset(x, f.plot.bottom + 3),
        Paint()..color = fg,
      );
      ChartKit.text(
        canvas,
        w.formatX(t),
        Offset(x, f.plot.bottom + 4),
        align: TextAlign.center,
        color: fg.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.w != w || old.fg != fg;
}
