import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/activity_history/data/journal_providers.dart';
import 'package:virya/features/calendar/domain/calendar_day.dart';
import 'package:virya/features/calendar/domain/calendar_stats.dart';

export 'package:virya/features/calendar/domain/calendar_day.dart';
export 'package:virya/features/calendar/domain/calendar_stats.dart';

/// Category of a stored `sportType` string. Gym sessions are stored as
/// `strength` (no GPS SportType yet); everything else goes via [SportType].
SportCategory categoryOfName(String sportType) {
  final n = sportType.toLowerCase();
  if (n == 'strength' || n == 'gym' || n.startsWith('strength')) {
    return SportCategory.strength;
  }
  return categoryOf(sportFromName(sportType));
}

/// Maps a DB row to the calendar's pure model (start converted to local).
CalendarEntry calendarEntryOf(Activity a) => CalendarEntry(
  id: a.id,
  title: a.title,
  sportName: a.sportType,
  category: categoryOfName(a.sportType),
  start: a.startTime.toLocal(),
  durationSeconds: a.movingTimeSeconds > 0
      ? a.movingTimeSeconds
      : a.elapsedTimeSeconds,
  distanceMeters: a.totalDistanceMeters,
  elevationGainMeters: a.elevationGainMeters,
);

/// Every completed activity bucketed by LOCAL day. Key = local midnight.
///
/// Type: `AsyncValue<Map<DateTime, CalendarDay>>`. Reuses the journal's
/// `completedActivitiesProvider`, so it updates live when activities change.
/// Look up a day with `days[DateTime(y, m, d)]`.
final calendarDaysProvider = Provider<AsyncValue<Map<DateTime, CalendarDay>>>(
  (ref) => ref
      .watch(completedActivitiesProvider)
      .whenData((list) => bucketByDay(list.map(calendarEntryOf))),
);

/// Streaks and % active days (this year up to today) for a filter
/// (`null` = all categories). Type: `AsyncValue<CalendarStats>`.
/// "Today" is re-read when activities change or the day rolls over.
final calendarStatsProvider =
    Provider.family<AsyncValue<CalendarStats>, SportCategory?>((ref, filter) {
      ref.watch(currentDayProvider); // hitung ulang saat hari berganti
      return ref
          .watch(calendarDaysProvider)
          .whenData(
            (days) =>
                CalendarStats.compute(days, DateTime.now(), filter: filter),
          );
    });
