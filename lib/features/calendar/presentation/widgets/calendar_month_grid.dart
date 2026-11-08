import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/calendar/domain/calendar_day.dart';
import 'package:virya/features/calendar/domain/calendar_grid.dart';
import 'package:virya/features/calendar/domain/calendar_stats.dart';
import 'package:virya/features/calendar/presentation/widgets/calendar_cell_painter.dart';

/// Month grid (Monday-first) with prev/next arrows. Leading days of the
/// previous month are dimmed. Tap a day to select it.
class CalendarMonthGrid extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, CalendarDay> days;
  final SportCategory? filter;
  final DateTime today;
  final DateTime? selected;
  final ValueChanged<DateTime> onTap;
  final ValueChanged<int> onShift;

  const CalendarMonthGrid({
    super.key,
    required this.month,
    required this.days,
    required this.today,
    required this.onTap,
    required this.onShift,
    this.filter,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final cells = monthCells(month.year, month.month);
    final maxSec = maxDaySeconds(
      days.values.where(
        (d) => d.date.year == month.year && d.date.month == month.month,
      ),
      filter: filter,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Bulan sebelumnya',
              icon: Icon(Icons.chevron_left, color: FN.ink),
              onPressed: () => onShift(-1),
            ),
            Expanded(
              child: Text(
                Fmt.monthYear(month),
                textAlign: TextAlign.center,
                style: FN
                    .label(size: 13, color: FN.ink)
                    .copyWith(fontWeight: FontWeight.w700, letterSpacing: 2.4),
              ),
            ),
            IconButton(
              tooltip: 'Bulan berikutnya',
              icon: Icon(Icons.chevron_right, color: FN.ink),
              onPressed: () => onShift(1),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final d in Fmt.daysShort)
              Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: FN.label(size: 9.5, color: FN.inkSoft),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 1.35,
          padding: EdgeInsets.zero,
          children: [
            for (final date in cells)
              _MonthCell(
                date: date,
                look: cellLook(
                  date,
                  days: days,
                  today: today,
                  maxSeconds: maxSec,
                  filter: filter,
                ),
                inMonth: date.month == month.month,
                selected: date == selected,
                onTap: () => onTap(date),
              ),
          ],
        ),
      ],
    );
  }
}

class _MonthCell extends StatelessWidget {
  final DateTime date;
  final CellLook look;
  final bool inMonth;
  final bool selected;
  final VoidCallback onTap;

  const _MonthCell({
    required this.date,
    required this.look,
    required this.inMonth,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filled = look.kind == CellKind.active;
    final strong = filled && look.alpha > 0.55;
    final numColor = strong
        ? FN.paper
        : look.kind == CellKind.future
        ? FN.inkMuted
        : FN.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: Fmt.dateStamp(date, withTime: false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: inMonth ? 1 : 0.4,
          child: CustomPaint(
            painter: DayCellPainter(
              kind: look.kind,
              parts: look.parts,
              alpha: look.alpha,
              outline: selected
                  ? FN.ink
                  : look.isToday
                  ? FN.signal
                  : null,
              outlineWidth: selected || look.isToday ? 2.5 : 1.5,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '${date.day}',
                  style: FN
                      .label(size: 11, color: numColor)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
