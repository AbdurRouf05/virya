import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/widgets/charts/chart_kit.dart';

/// Fitness (CTL, thick ink), fatigue (ATL, orange) and form (TSB, bars).
class FitnessChart extends StatelessWidget {
  final List<FitnessDay> days;
  final double height;
  const FitnessChart({super.key, required this.days, this.height = 190});

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: RepaintBoundary(
            child: CustomPaint(painter: _FitnessPainter(days, fg)),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            _legend(fg, 'KEBUGARAN', fg, thick: true),
            _legend(fg, 'KELELAHAN', FN.signal),
            _legend(fg, 'BENTUK', FN.ok, bar: true),
          ],
        ),
      ],
    );
  }

  Widget _legend(
    Color fg,
    String t,
    Color c, {
    bool thick = false,
    bool bar = false,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: bar ? 8 : 16,
        height: bar ? 10 : (thick ? 3 : 1.5),
        color: c,
      ),
      const SizedBox(width: 6),
      Text(t, style: FN.label(size: 9.5, color: fg)),
    ],
  );
}

class _FitnessPainter extends CustomPainter {
  final List<FitnessDay> days;
  final Color fg;
  _FitnessPainter(this.days, this.fg);

  @override
  void paint(Canvas canvas, Size size) {
    if (days.length < 2) {
      ChartKit.text(
        canvas,
        'BELUM ADA DATA BEBAN LATIHAN',
        Offset(size.width / 2, size.height / 2 - 6),
        align: TextAlign.center,
        color: fg.withValues(alpha: 0.6),
      );
      return;
    }
    var hi = 10.0, lo = 0.0;
    for (final d in days) {
      hi = math.max(hi, math.max(d.fitness, d.fatigue));
      lo = math.min(lo, d.form);
    }
    hi *= 1.1;
    lo = lo < 0 ? lo * 1.1 : 0;
    final f = ChartFrame(
      size,
      minX: 0,
      maxX: (days.length - 1).toDouble(),
      minY: lo,
      maxY: hi,
      left: 30,
    );

    final grid = Paint()
      ..color = fg.withValues(alpha: 0.18)
      ..strokeWidth = 0.7;
    for (final t in ChartKit.niceTicks(lo, hi, count: 4)) {
      ChartKit.dashedH(canvas, f.plot.left, f.plot.right, f.y(t), grid);
      ChartKit.text(
        canvas,
        t.round().toString(),
        Offset(f.plot.left - 4, f.y(t) - 6),
        align: TextAlign.right,
        color: fg.withValues(alpha: 0.6),
      );
    }
    // Zero line
    canvas.drawLine(
      Offset(f.plot.left, f.y(0)),
      Offset(f.plot.right, f.y(0)),
      Paint()
        ..color = fg
        ..strokeWidth = 1,
    );

    // Form bars
    final bw = math.max(1.0, f.plot.width / days.length - 1);
    for (var i = 0; i < days.length; i++) {
      final v = days[i].form;
      final x = f.x(i.toDouble());
      canvas.drawRect(
        Rect.fromLTRB(
          x - bw / 2,
          f.y(math.max(v, 0)),
          x + bw / 2,
          f.y(math.min(v, 0)),
        ),
        Paint()..color = (v >= 0 ? FN.ok : FN.warn).withValues(alpha: 0.45),
      );
    }

    void series(double Function(FitnessDay) get, Color c, double w) {
      final p = Path()..moveTo(f.x(0), f.y(get(days[0])));
      for (var i = 1; i < days.length; i++) {
        p.lineTo(f.x(i.toDouble()), f.y(get(days[i])));
      }
      canvas.drawPath(
        p,
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeJoin = StrokeJoin.round,
      );
    }

    series((d) => d.fatigue, FN.signal, 1.3);
    series((d) => d.fitness, fg, 2.6);

    // Month ticks
    for (var i = 0; i < days.length; i++) {
      final d = days[i].day;
      if (d.day == 1 || i == 0) {
        final x = f.x(i.toDouble());
        canvas.drawLine(
          Offset(x, f.plot.bottom),
          Offset(x, f.plot.bottom + 3),
          Paint()..color = fg,
        );
        ChartKit.text(
          canvas,
          Fmt.monthsShort[d.month - 1],
          Offset(x + 2, f.plot.bottom + 4),
          color: fg.withValues(alpha: 0.7),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FitnessPainter old) =>
      !identical(old.days, days) || old.fg != fg;
}

/// Plain-language reading of form (TSB).
({String title, String note, Color color}) formStatus(double form) {
  if (form > 25) {
    return (
      title: 'TRANSISI',
      note:
          'Sangat segar, tapi kebugaran mulai turun. Saatnya kembali berlatih.',
      color: FN.inkMuted,
    );
  }
  if (form > 5) {
    return (
      title: 'SEGAR',
      note: 'Tubuh pulih dan siap untuk upaya besar atau lomba.',
      color: FN.ok,
    );
  }
  if (form > -10) {
    return (
      title: 'NETRAL',
      note: 'Beban seimbang. Kebugaran terjaga tanpa banyak kemajuan.',
      color: FN.inkSoft,
    );
  }
  if (form > -30) {
    return (
      title: 'OPTIMAL',
      note: 'Zona membangun kebugaran. Lelah itu wajar — jaga tidur & makan.',
      color: FN.signal,
    );
  }
  return (
    title: 'LELAH',
    note: 'Beban terlalu tinggi. Risiko cedera/sakit naik — ambil hari ringan.',
    color: FN.warn,
  );
}
