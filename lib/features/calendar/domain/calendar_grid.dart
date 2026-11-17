import 'package:virya/features/calendar/domain/calendar_stats.dart';

/// Monday on or before [d] (local date).
DateTime mondayOf(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));

/// Year heatmap layout: columns are weeks (Monday-first), rows are weekdays.
class YearGrid {
  final int year;

  /// Monday of the week holding 1 January.
  final DateTime start;

  /// Number of week columns (53 or 54 when 31 Dec spills into a 54th).
  final int weeks;

  YearGrid._(this.year, this.start, this.weeks);

  factory YearGrid(int year) {
    final start = mondayOf(DateTime(year));
    final lastMonday = mondayOf(DateTime(year, 12, 31));
    final weeks = _daysBetween(start, lastMonday) ~/ 7 + 1;
    return YearGrid._(year, start, weeks < 53 ? 53 : weeks);
  }

  /// Date at [week] column, [weekday] row (0 = Monday).
  DateTime dateAt(int week, int weekday) =>
      DateTime(start.year, start.month, start.day + week * 7 + weekday);

  /// Whether [d] lies inside [year] (cells outside are left blank).
  bool contains(DateTime d) => d.year == year;

  /// Column where [month] (1..12) begins, for month labels.
  int weekOfMonthStart(int month) =>
      _daysBetween(start, DateTime(year, month)) ~/ 7;
}

/// Whole days between two local midnights (DST-safe).
int _daysBetween(DateTime a, DateTime b) =>
    (b.difference(a).inHours / 24).round();

/// Month layout, Monday-first: leading days of the previous month fill the
/// first row; the list ends at the last day of [month] (no trailing days).
List<DateTime> monthCells(int year, int month) {
  final first = DateTime(year, month);
  final out = <DateTime>[];
  for (var d = mondayOf(first); d.month != month || d.year != year;) {
    out.add(d);
    d = nextDay(d);
  }
  for (var d = first; d.month == month; d = nextDay(d)) {
    out.add(d);
  }
  return out;
}
