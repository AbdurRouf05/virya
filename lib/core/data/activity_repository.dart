import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/analytics/activity_analyzer.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/models/track_sample.dart';

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

  /// Deletes the activity, its track points and cleans up physical photo files.
  Future<void> delete(String activityId) async {
    try {
      final photos = await db.waypointPhotosDao.getPhotosForActivity(activityId);
      for (final ph in photos) {
        final f = File(ph.filePath);
        if (await f.exists()) await f.delete();
      }
    } catch (_) {}
    await db.activitiesDao.deleteActivity(activityId);
  }

  Future<AthleteParams> _athleteParams() async {
    final profile = await db.select(db.userProfiles).getSingleOrNull();
    if (profile == null) return const AthleteParams();
    return AthleteParams(
      weightKg: profile.weightKg,
      maxHr: profile.maxHeartRate,
      ftpW: profile.ftpWatts?.toDouble(),
    );
  }
}

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(ref.watch(databaseProvider)),
);

/// Load + analyze one activity. Auto-disposes 30s after closing the screen
/// to free large track point arrays from memory while keeping transitions fast.
final activityBundleProvider =
    FutureProvider.autoDispose.family<ActivityBundle?, String>((ref, id) {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(seconds: 30), link.close);
  ref.onDispose(timer.cancel);
  return ref.watch(activityRepositoryProvider).load(id);
});
