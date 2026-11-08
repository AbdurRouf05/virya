import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/core/analytics/activity_analyzer.dart';
import 'package:stravo/core/analytics/analysis_models.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/models/track_sample.dart';

/// SHARED CONTRACT — everything a screen needs to render one activity.
class ActivityBundle {
  final Activity activity;
  final List<TrackSample> samples;
  final List<WaypointPhoto> photos;
  final ActivityAnalysis analysis;

  const ActivityBundle({
    required this.activity,
    required this.samples,
    required this.photos,
    required this.analysis,
  });

  SportType get sport => SportType.values.firstWhere(
        (s) => s.name == activity.sportType,
        orElse: () => SportType.gravelCycling,
      );
}

class ActivityRepository {
  final AppDatabase db;
  ActivityRepository(this.db);

  Future<ActivityBundle?> load(String activityId) async {
    final activity = await db.activitiesDao.getActivityById(activityId);
    if (activity == null) return null;
    final points = await db.trackPointsDao.getPointsForActivity(activityId);
    final photos = await db.waypointPhotosDao.getPhotosForActivity(activityId);
    final samples = points.map(TrackSample.fromTrackPoint).toList();
    final sport = SportType.values.firstWhere(
      (s) => s.name == activity.sportType,
      orElse: () => SportType.gravelCycling,
    );
    final athlete = await _athleteParams();
    final analysis = await Isolate.run(
      () => const ActivityAnalyzer().analyze(samples, sport, athlete: athlete),
    );
    return ActivityBundle(
      activity: activity,
      samples: samples,
      photos: photos,
      analysis: analysis,
    );
  }

  Future<AthleteParams> _athleteParams() async {
    final profile = await db.select(db.userProfiles).getSingleOrNull();
    if (profile == null) return const AthleteParams();
    return AthleteParams(
      weightKg: profile.weightKg,
      maxHr: profile.maxHeartRate,
    );
  }
}

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(ref.watch(databaseProvider)),
);

/// Load + analyze one activity. Invalidate after edits.
final activityBundleProvider =
    FutureProvider.family<ActivityBundle?, String>((ref, id) {
  return ref.watch(activityRepositoryProvider).load(id);
});
