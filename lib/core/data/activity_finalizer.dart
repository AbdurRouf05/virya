import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/analytics/activity_analyzer.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/models/track_sample.dart';

/// SHARED CONTRACT — recompute and persist an activity's summary columns from
/// its track points. Call after recording stops, after import, and after any
/// edit that changes sport type. Marks the activity `completed`.
class ActivityFinalizer {
  final AppDatabase db;
  ActivityFinalizer(this.db);

  /// Dijalankan setelah ringkasan tersimpan. Dipasang di `main.dart`, karena
  /// `core/` tidak boleh mengenal modul fitur.
  static Future<void> Function(
    AppDatabase db,
    String activityId,
    List<TrackSample> samples,
    SportType sport,
  )? afterFinalize;

  Future<ActivityAnalysis?> finalize(String activityId) async {
    final activity = await db.activitiesDao.getActivityById(activityId);
    if (activity == null) return null;
    final points = await db.trackPointsDao.getPointsForActivity(activityId);
    final samples = points.map(TrackSample.fromTrackPoint).toList();
    final sport = SportType.values.firstWhere(
      (s) => s.name == activity.sportType,
      orElse: () => SportType.gravelCycling,
    );
    // Sesi gym tidak punya titik GPS; ringkasannya ditulis modul gym.
    if (!sport.isGps) return null;
    final profile = await db.select(db.userProfiles).getSingleOrNull();
    final athlete = profile == null
        ? const AthleteParams()
        : AthleteParams(
            weightKg: profile.weightKg,
            maxHr: profile.maxHeartRate,
            ftpW: profile.ftpWatts?.toDouble(),
          );

    final a = await Isolate.run(
      () => const ActivityAnalyzer().analyze(samples, sport, athlete: athlete),
    );

    final asphalt = a.surfaceDistanceM[SurfaceType.asphalt] ?? 0;
    await (db.update(db.activities)..where((t) => t.id.equals(activityId)))
        .write(ActivitiesCompanion(
      status: const Value('completed'),
      endTime: Value(activity.endTime ??
          (samples.isEmpty ? activity.startTime : samples.last.time)),
      totalDistanceMeters: Value(a.distanceM),
      elapsedTimeSeconds: Value(a.elapsedTimeS),
      movingTimeSeconds: Value(a.movingTimeS),
      elevationGainMeters: Value(a.elevationGainM),
      elevationLossMeters: Value(a.elevationLossM),
      maxElevationMeters: Value(a.maxEleM),
      minElevationMeters: Value(a.minEleM),
      avgSpeedMps: Value(a.avgSpeedMps),
      maxSpeedMps: Value(a.maxSpeedMps),
      avgGapMps: Value(a.avgGapMps),
      avgCadence: Value(a.avgCadence),
      avgHeartRate: Value(a.avgHeartRate),
      maxHeartRate: Value(a.maxHeartRate),
      estimatedEnergyKj: Value(a.energyKj?.round()),
      gravelPercentage: Value(a.gravelPct),
      asphaltPercentage:
          Value(a.distanceM == 0 ? 0 : asphalt / a.distanceM * 100),
      relativeEffort: Value(a.relativeEffort),
      gritScore: Value(a.gritScore),
      avgPowerW: Value(a.avgPowerW),
      updatedAt: Value(DateTime.now()),
    ));
    if (activity.gearId != null) await syncGearDistance(activity.gearId!);
    await afterFinalize?.call(db, activityId, samples, sport);
    return a;
  }

  /// Idempotent: gear odometer = sum of its completed activities. Safe to
  /// call after re-finalize, edits that move an activity between gears, and
  /// deletes.
  Future<void> syncGearDistance(String gearId) async {
    final sum = db.activities.totalDistanceMeters.sum();
    final row = await (db.selectOnly(db.activities)
          ..addColumns([sum])
          ..where(db.activities.status.equals('completed') &
              db.activities.gearId.equals(gearId)))
        .getSingle();
    await (db.update(db.gears)..where((t) => t.id.equals(gearId))).write(
        GearsCompanion(totalDistanceMeters: Value(row.read(sum) ?? 0)));
  }
}

final activityFinalizerProvider = Provider<ActivityFinalizer>(
  (ref) => ActivityFinalizer(ref.watch(databaseProvider)),
);
