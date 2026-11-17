import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/calendar/domain/calendar_day.dart';
import 'package:virya/features/calendar/domain/calendar_grid.dart';
import 'package:virya/features/calendar/domain/calendar_stats.dart';
import 'package:virya/features/calendar/presentation/widgets/calendar_cell_painter.dart';

/// 53-week × 7-day heatmap of one year (Monday-first rows), month labels on
/// top. Tapping a square reports its date.
class CalendarYearHeatmap extends StatelessWidget {
  final int year;
  final Map<DateTime, CalendarDay> days;
  final SportCategory? filter;
  final DateTime today;
  final DateTime? selected;
  final ValueChanged<DateTime>? onTap;

  const CalendarYearHeatmap({
    super.key,
    required this.year,
    required this.days,
    required this.today,
    this.filter,
    this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final grid = YearGrid(year);
    final maxSec = maxDaySeconds(
      days.values.where((d) => d.date.year == year),
      filter: filter,
    );
    return LayoutBuilder(
      builder: (context, c) {
        final col = c.maxWidth / grid.weeks;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 16,
              child: Stack(
                children: [
                  for (var m = 1; m <= 12; m++)
                    Positioned(
                      left: grid.weekOfMonthStart(m) * col,
                      top: 0,
                      child: Text(
                        Fmt.monthsShort[m - 1],
                        style: FN.label(size: 8.5, color: FN.inkSoft),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: onTap == null
                  ? null
                  : (e) {
                      final w = e.localPosition.dx ~/ col;
                      final d = e.localPosition.dy ~/ col;
                      if (w < 0 || w >= grid.weeks || d < 0 || d > 6) return;
                      final date = grid.dateAt(w, d);
                      if (grid.contains(date)) onTap!(date);
                    },
              child: CustomPaint(
                size: Size(c.maxWidth, col * 7),
                painter: _HeatmapPainter(
                  grid: grid,
                  col: col,
                  looks: (date) => cellLook(
                    date,
                    days: days,
                    today: today,
                    maxSeconds: maxSec,
                    filter: filter,
                    inRange: grid.contains(date),
                  ),
                  selected: selected,
                  signal: FN.signal,
                  ink: FN.ink,
                  key: Object.hash(
                    year,
                    filter,
                    identityHashCode(days),
                    selected,
                    today,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final YearGrid grid;
  final double col;
  final CellLook Function(DateTime) looks;
  final DateTime? selected;
  final Color signal;
  final Color ink;
  final int key;

  _HeatmapPainter({
    required this.grid,
    required this.col,
    required this.looks,
    required this.selected,
    required this.signal,
    required this.ink,
    required this.key,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gap = col > 6 ? 1.5 : 1.0;
    final cell = col - gap;
    for (var w = 0; w < grid.weeks; w++) {
      for (var d = 0; d < 7; d++) {
        final date = grid.dateAt(w, d);
        final look = looks(date);
        final r = Rect.fromLTWH(w * col, d * col, cell, cell);
        paintDayCell(
          canvas,
          r,
          kind: look.kind,
          parts: look.parts,
          alpha: look.alpha,
          outline: date == selected
              ? ink
              : look.isToday
              ? signal
              : null,
          outlineWidth: 1.2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.key != key || old.col != col || old.signal != signal;
}
