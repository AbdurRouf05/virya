import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/calendar/domain/calendar_day.dart';

/// Visual state of one day square.
enum CellKind { active, rest, future, outside }

/// What to draw for one date.
class CellLook {
  final CellKind kind;
  final List<SportCategory> parts;
  final double alpha;
  final bool isToday;

  const CellLook(
    this.kind, {
    this.parts = const [],
    this.alpha = 1,
    this.isToday = false,
  });
}

/// Look of [date] given the bucketed [days], [today] (local midnight), the
/// active [filter] and the busiest day's seconds [maxSeconds].
/// Pass [inRange] false for padding cells outside the shown year.
CellLook cellLook(
  DateTime date, {
  required Map<DateTime, CalendarDay> days,
  required DateTime today,
  required int maxSeconds,
  SportCategory? filter,
  bool inRange = true,
}) {
  if (!inRange) return const CellLook(CellKind.outside);
  final isToday = date == today;
  final day = days[date];
  if (day != null && day.isActive(filter)) {
    return CellLook(
      CellKind.active,
      parts: cellParts(day, filter),
      alpha: intensity(day.seconds(filter), maxSeconds),
      isToday: isToday,
    );
  }
  if (date.isAfter(today)) return const CellLook(CellKind.future);
  return CellLook(CellKind.rest, isToday: isToday);
}
