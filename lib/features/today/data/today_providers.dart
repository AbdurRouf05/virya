import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/features/activity_history/data/journal_providers.dart';
import 'package:virya/features/today/domain/today_models.dart';

/// Aktivitas selesai dalam bentuk ringkas untuk layar Hari Ini.
final todayActivitiesProvider = Provider<AsyncValue<List<TodayActivity>>>((
  ref,
) {
  return ref
      .watch(completedActivitiesProvider)
      .whenData(
        (rows) => [
          for (final a in rows)
            TodayActivity(
              id: a.id,
              title: a.title,
              sport: sportFromName(a.sportType),
              start: a.startTime,
              distanceMeters: a.totalDistanceMeters,
              movingSeconds: a.movingTimeSeconds,
            ),
        ],
      );
});
