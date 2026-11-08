import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/widgets/charts/chart_kit.dart';

/// A marked range on the distance axis (e.g. a climb or gravel sector).
class ChartMark {
  final double startM;
  final double endM;
  final String label;
  final Color? _color;
  Color get color => _color ?? FN.ink;
  const ChartMark(this.startM, this.endM, this.label, {Color? color})
    : _color = color;
}

/// Filled elevation profile, each slice colored by its grade (FN.grade).
class ElevationProfile extends StatelessWidget {
  final List<double> distanceM;
  final List<double> ele;
  final List<double> gradePct;
  final List<ChartMark> marks;
  final double height;
  final String Function(double meters) formatX;
  final String Function(double meters) formatY;

  const ElevationProfile({
    super.key,
    required this.distanceM,
    required this.ele,
    required this.gradePct,
    this.marks = const [],
    this.height = 180,
    required this.formatX,
    required this.formatY,
  });

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: RepaintBoundary(
        child: CustomPaint(painter: _ElevationPainter(this, fg)),
      ),
    );
  }
}

class _ElevationPainter extends CustomPainter {
  final ElevationProfile w;
  final Color fg;
  _ElevationPainter(this.w, this.fg);

  @override
  void paint(Canvas canvas, Size size) {
    final n = math.min(w.distanceM.length, w.ele.length);
    if (n < 2) {
      ChartKit.text(
        canvas,
        'TIDAK ADA DATA ELEVASI',
        Offset(size.width / 2, size.height / 2 - 6),
        align: TextAlign.center,
      );
      return;
    }
    var lo = w.ele.take(n).reduce(math.min);
    var hi = w.ele.take(n).reduce(math.max);
    final pad = math.max((hi - lo) * 0.12, 5.0);
    lo = (lo - pad).floorToDouble();
    hi = hi + pad;
    final topGutter = w.marks.isEmpty ? 8.0 : 26.0;
    final f = ChartFrame(
      size,
      minX: w.distanceM.first,
      maxX: w.distanceM[n - 1],
      minY: lo,
      maxY: hi,
      top: topGutter,
    );

    // Grid
    final grid = Paint()
      ..color = fg.withValues(alpha: 0.18)
      ..strokeWidth = 0.7;
    for (final t in ChartKit.niceTicks(lo, hi, count: 3)) {
      ChartKit.dashedH(canvas, f.plot.left, f.plot.right, f.y(t), grid);
      ChartKit.text(
        canvas,
        w.formatY(t),
        Offset(f.plot.left - 4, f.y(t) - 6),
        align: TextAlign.right,
        color: fg.withValues(alpha: 0.6),
      );
    }

    // Graded fill
    final fill = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < n - 1; i++) {
      final g = i < w.gradePct.length ? w.gradePct[i] : 0.0;
      fill.color = FN.grade(g);
      final x0 = f.x(w.distanceM[i]), x1 = f.x(w.distanceM[i + 1]);
      if (x1 - x0 <= 0) continue;
      final path = Path()
        ..moveTo(x0, f.plot.bottom)
        ..lineTo(x0, f.y(w.ele[i]))
        ..lineTo(x1 + 0.4, f.y(w.ele[i + 1]))
        ..lineTo(x1 + 0.4, f.plot.bottom)
        ..close();
      canvas.drawPath(path, fill);
    }

    // Ink outline
    final line = Path()..moveTo(f.x(w.distanceM[0]), f.y(w.ele[0]));
    for (var i = 1; i < n; i++) {
      line.lineTo(f.x(w.distanceM[i]), f.y(w.ele[i]));
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = fg
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );

    // Baseline + x ticks
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

    // Marks: bracket above the range + label
    for (final m in w.marks) {
      final x0 = f.x(m.startM), x1 = f.x(m.endM);
      final y = topGutter - 8;
      final p = Paint()
        ..color = m.color
        ..strokeWidth = 1.4;
      canvas.drawLine(Offset(x0, y), Offset(x1, y), p);
      canvas.drawLine(Offset(x0, y), Offset(x0, y + 5), p);
      canvas.drawLine(Offset(x1, y), Offset(x1, y + 5), p);
      final dash = Paint()
        ..color = m.color.withValues(alpha: 0.35)
        ..strokeWidth = 0.8;
      for (final x in [x0, x1]) {
        for (var yy = y + 6; yy < f.plot.bottom; yy += 6) {
          canvas.drawLine(Offset(x, yy), Offset(x, yy + 3), dash);
        }
      }
      ChartKit.text(
        canvas,
        m.label,
        Offset((x0 + x1) / 2, y - 13),
        align: TextAlign.center,
        bold: true,
        size: 9,
        color: FN.paper,
        background: m.color,
      );
    }
  }

  @override
  bool shouldRepaint(_ElevationPainter old) => old.w != w || old.fg != fg;
}

/// Grade legend strip under the profile.
class GradeLegend extends StatelessWidget {
  const GradeLegend({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      (0.0, '<3'),
      (4.0, '3-5'),
      (6.0, '5-8'),
      (9.0, '8-11'),
      (12.0, '11-15'),
      (16.0, '15+'),
    ];
    return Row(
      children: [
        Text('TANJAKAN %', style: FN.label(size: 9)),
        const SizedBox(width: 8),
        for (final (g, l) in steps)
          Expanded(
            child: Column(
              children: [
                Container(height: 6, color: FN.grade(g)),
                const SizedBox(height: 2),
                Text(l, style: FN.label(size: 8.5)),
              ],
            ),
          ),
      ],
    );
  }
}
