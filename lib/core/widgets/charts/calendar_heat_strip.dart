import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stravo/app/format.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/core/widgets/charts/chart_kit.dart';

/// GitHub-style calendar strip: columns = weeks (Mon..Sun rows).
/// Values are e.g. km per day; top quartile drawn in signal orange.
class CalendarHeatStrip extends StatelessWidget {
  final Map<DateTime, double> dailyValue; // keys = local midnight
  final int weeks;
  final DateTime? endDay;

  const CalendarHeatStrip({
    super.key,
    required this.dailyValue,
    this.weeks = 26,
    this.endDay,
  });

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return LayoutBuilder(builder: (context, c) {
      final cell = math.min(18.0, (c.maxWidth - 20) / weeks);
      return SizedBox(
        height: cell * 7 + 16,
        width: double.infinity,
        child: CustomPaint(
          painter: _HeatPainter(
              dailyValue, weeks, endDay ?? DateTime.now(), cell, fg),
        ),
      );
    });
  }
}

class _HeatPainter extends CustomPainter {
  final Map<DateTime, double> values;
  final int weeks;
  final DateTime end;
  final double cell;
  final Color fg;
  _HeatPainter(this.values, this.weeks, this.end, this.cell, this.fg);

  @override
  void paint(Canvas canvas, Size size) {
    final endDay = DateTime(end.year, end.month, end.day);
    // Monday of the last column
    final lastMonday = endDay.subtract(Duration(days: endDay.weekday - 1));
    final firstMonday = lastMonday.subtract(Duration(days: 7 * (weeks - 1)));
    final positives = values.values.where((v) => v > 0).toList()..sort();
    final maxV = positives.isEmpty ? 1.0 : positives.last;
    final q3 = positives.isEmpty
        ? double.infinity
        : positives[(positives.length * 0.75).floor().clamp(0, positives.length - 1)];

    const left = 16.0, top = 14.0;
    final gap = math.max(1.0, cell * 0.14);
    final empty = Paint()
      ..color = fg.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    int? lastMonth;
    for (var w = 0; w < weeks; w++) {
      final monday = firstMonday.add(Duration(days: 7 * w));
      if (monday.month != lastMonth) {
        if (lastMonth != null || monday.day <= 7) {
          ChartKit.text(canvas, Fmt.monthsShort[monday.month - 1],
              Offset(left + w * cell, 0),
              size: 8.5, color: fg.withValues(alpha: 0.7));
        }
        lastMonth = monday.month;
      }
      for (var d = 0; d < 7; d++) {
        final day = DateTime(monday.year, monday.month, monday.day + d);
        if (day.isAfter(endDay)) continue;
        final r = Rect.fromLTWH(left + w * cell, top + d * cell,
            cell - gap, cell - gap);
        final v = values[day] ?? 0;
        if (v <= 0) {
          canvas.drawRect(r.deflate(0.3), empty);
        } else {
          final t = (0.35 + 0.65 * (v / maxV)).clamp(0.35, 1.0);
          final color =
              v >= q3 && positives.length >= 4 ? FN.signal : fg.withValues(alpha: t);
          canvas.drawRect(r, Paint()..color = color);
        }
      }
    }
    for (final (i, l) in [(0, 'S'), (2, 'R'), (4, 'J'), (6, 'M')]) {
      ChartKit.text(canvas, l, Offset(0, top + i * cell + cell / 2 - 7),
          size: 8, color: fg.withValues(alpha: 0.6));
    }
  }

  @override
  bool shouldRepaint(_HeatPainter old) =>
      !identical(old.values, values) || old.cell != cell || old.fg != fg;
}
