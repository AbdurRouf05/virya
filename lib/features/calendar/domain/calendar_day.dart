import 'package:virya/core/constants/sport_category.dart';

/// One activity as the calendar sees it. Pure data, no DB types.
class CalendarEntry {
  final String id;
  final String title;

  /// Raw sport name as stored in `activities.sportType`.
  final String sportName;
  final SportCategory category;
  final DateTime start;
  final int durationSeconds;
  final double distanceMeters;
  final double elevationGainMeters;

  const CalendarEntry({
    required this.id,
    required this.title,
    required this.sportName,
    required this.category,
    required this.start,
    required this.durationSeconds,
    this.distanceMeters = 0,
    this.elevationGainMeters = 0,
  });
}

/// Calendar date (local midnight) of an instant. Converts UTC to local first.
DateTime dayOf(DateTime t) {
  final l = t.toLocal();
  return DateTime(l.year, l.month, l.day);
}

/// All activities of one local calendar day.
class CalendarDay {
  /// Local midnight of the day.
  final DateTime date;

  /// Activities sorted by start time (oldest first).
  final List<CalendarEntry> entries;

  const CalendarDay(this.date, this.entries);

  /// Categories present that day, in [SportCategory] order.
  List<SportCategory> categories([SportCategory? filter]) => [
    for (final c in SportCategory.values)
      if ((filter == null || filter == c) &&
          entries.any((e) => e.category == c))
        c,
  ];

  /// Whether the day counts as active for [filter] (null = all categories).
  bool isActive([SportCategory? filter]) =>
      entries.any((e) => filter == null || e.category == filter);

  /// Seconds trained that day for [filter].
  int seconds([SportCategory? filter]) => entries
      .where((e) => filter == null || e.category == filter)
      .fold(0, (s, e) => s + e.durationSeconds);

  /// Seconds per category, used to choose the dominant one.
  int secondsOf(SportCategory c) => seconds(c);
}

/// Groups entries by their LOCAL calendar day. Keys are local midnights.
Map<DateTime, CalendarDay> bucketByDay(Iterable<CalendarEntry> entries) {
  final map = <DateTime, List<CalendarEntry>>{};
  for (final e in entries) {
    (map[dayOf(e.start)] ??= []).add(e);
  }
  return {
    for (final kv in map.entries)
      kv.key: CalendarDay(
        kv.key,
        kv.value..sort((a, b) => a.start.compareTo(b.start)),
      ),
  };
}

/// How a cell is split: 1 part = full, 2 = diagonal, 4 = quadrants
/// (top-left, top-right, bottom-left, bottom-right). With 3 categories the
/// fourth quadrant repeats the dominant (most seconds) category.
List<SportCategory> cellParts(CalendarDay day, [SportCategory? filter]) {
  final cats = day.categories(filter);
  if (cats.length <= 2) return cats;
  if (cats.length == 4) return cats;
  var dominant = cats.first;
  for (final c in cats) {
    if (day.secondsOf(c) > day.secondsOf(dominant)) dominant = c;
  }
  return [...cats, dominant];
}

/// Fill strength 0..1 for a day lasting [seconds] when the busiest day lasts
/// [maxSeconds]. Never below [floor] for an active day so it stays visible.
double intensity(int seconds, int maxSeconds, {double floor = 0.35}) {
  if (maxSeconds <= 0) return 1;
  final r = (seconds / maxSeconds).clamp(0.0, 1.0);
  return floor + (1 - floor) * r;
}
