import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/calendar/domain/calendar_day.dart';

/// Next / previous calendar day. Uses date fields (not +24h) so DST is safe.
DateTime nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);
DateTime prevDay(DateTime d) => DateTime(d.year, d.month, d.day - 1);

/// Consistency numbers for one filter (null = all categories).
class CalendarStats {
  /// Consecutive active days ending today. If today has no activity yet the
  /// streak still counts up to yesterday (it is not broken until the day ends).
  final int currentStreak;
  final int longestStreak;

  /// Active days this year from 1 Jan to today (inclusive).
  final int activeDaysThisYear;
  final int elapsedDaysThisYear;

  /// Whether today already has an activity for the filter.
  final bool activeToday;

  const CalendarStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.activeDaysThisYear,
    required this.elapsedDaysThisYear,
    required this.activeToday,
  });

  /// 0..100, rounded.
  int get activePercent => elapsedDaysThisYear == 0
      ? 0
      : (activeDaysThisYear * 100 / elapsedDaysThisYear).round();

  factory CalendarStats.compute(
    Map<DateTime, CalendarDay> days,
    DateTime now, {
    SportCategory? filter,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    bool active(DateTime d) => days[d]?.isActive(filter) ?? false;
    return CalendarStats(
      currentStreak: streakEndingToday(days, today, filter: filter),
      longestStreak: longestStreakOf(days, filter: filter),
      activeDaysThisYear: _countActive(DateTime(today.year), today, active),
      elapsedDaysThisYear: _countDays(DateTime(today.year), today),
      activeToday: active(today),
    );
  }
}

/// See [CalendarStats.currentStreak].
int streakEndingToday(
  Map<DateTime, CalendarDay> days,
  DateTime today, {
  SportCategory? filter,
}) {
  bool active(DateTime d) => days[d]?.isActive(filter) ?? false;
  var d = DateTime(today.year, today.month, today.day);
  if (!active(d)) d = prevDay(d);
  var n = 0;
  while (active(d)) {
    n++;
    d = prevDay(d);
  }
  return n;
}

/// Longest run of consecutive active days ever.
int longestStreakOf(Map<DateTime, CalendarDay> days, {SportCategory? filter}) {
  final active =
      days.values.where((d) => d.isActive(filter)).map((d) => d.date).toList()
        ..sort();
  var best = 0, run = 0;
  DateTime? last;
  for (final d in active) {
    run = (last != null && nextDay(last) == d) ? run + 1 : 1;
    if (run > best) best = run;
    last = d;
  }
  return best;
}

int _countDays(DateTime from, DateTime to) {
  var n = 0;
  for (var d = from; !d.isAfter(to); d = nextDay(d)) {
    n++;
  }
  return n;
}

int _countActive(DateTime from, DateTime to, bool Function(DateTime) active) {
  var n = 0;
  for (var d = from; !d.isAfter(to); d = nextDay(d)) {
    if (active(d)) n++;
  }
  return n;
}

/// Longest single-day duration among [days] for [filter] (for intensity).
int maxDaySeconds(Iterable<CalendarDay> days, {SportCategory? filter}) {
  var m = 0;
  for (final d in days) {
    final s = d.seconds(filter);
    if (s > m) m = s;
  }
  return m;
}
