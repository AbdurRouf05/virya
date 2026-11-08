import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/data/activity_finalizer.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/models/track_sample.dart';
import 'package:uuid/uuid.dart';

/// SHARED DEV UTILITY — deterministic synthetic gravel ride (~32 km loop in
/// the hills north of Bandung) with elevation, surfaces, vibration, HR.
/// Use in tests (`demoGravelRide()`) and in-app "load demo ride".
List<TrackSample> demoGravelRide({int seconds = 5400, int seed = 7}) {
  final rnd = math.Random(seed);
  const lat0 = -6.835, lon0 = 107.62; // Lembang-ish
  final start = DateTime(2026, 11, 1, 6, 0, 0);
  final out = <TrackSample>[];
  var hrDrift = 0.0;
  for (var i = 0; i < seconds; i++) {
    final t = i / seconds; // 0..1 around the loop
    final ang = t * 2 * math.pi;
    // Lumpy loop: radius wobbles so the shape is not a perfect circle.
    final r = 0.045 + 0.012 * math.sin(3 * ang) + 0.006 * math.cos(7 * ang);
    final lat = lat0 + r * math.sin(ang) + (rnd.nextDouble() - .5) * 0.00002;
    final lon = lon0 + r * 1.2 * math.cos(ang) + (rnd.nextDouble() - .5) * 0.00002;
    // One big climb, a rolling middle and a fast descent.
    final ele = 1150 +
        420 * math.exp(-math.pow((t - 0.35) / 0.12, 2)) +
        60 * math.sin(t * 18) +
        (rnd.nextDouble() - .5) * 1.5;
    // Surface by section.
    SurfaceType surface;
    if (t < 0.15 || t > 0.9) {
      surface = SurfaceType.asphalt;
    } else if (t < 0.3) {
      surface = SurfaceType.smoothGravel;
    } else if (t < 0.45) {
      surface = SurfaceType.roughGravel;
    } else if (t < 0.6) {
      surface = SurfaceType.dirt;
    } else if (t < 0.75) {
      surface = SurfaceType.smoothGravel;
    } else {
      surface = SurfaceType.asphalt;
    }
    final vib = switch (surface) {
      SurfaceType.asphalt => 0.6,
      SurfaceType.smoothGravel => 2.2,
      SurfaceType.roughGravel => 4.8,
      SurfaceType.dirt => 3.1,
      _ => 1.0,
    } + rnd.nextDouble() * 0.6;
    final climbing = t > 0.22 && t < 0.35;
    final speed = (climbing ? 3.2 : (t > 0.35 && t < 0.45 ? 9.5 : 6.4)) +
        (rnd.nextDouble() - .5) * 0.8;
    hrDrift += 0.0004;
    final hr = (climbing ? 168 : 138) + hrDrift + rnd.nextInt(5);
    // A short café stop at ~60%.
    final paused = t > 0.6 && t < 0.61;
    out.add(TrackSample(
      time: start.add(Duration(seconds: i)),
      lat: lat,
      lon: lon,
      ele: ele,
      speedMps: paused ? 0 : speed,
      accuracyM: 4,
      heartRate: hr.round(),
      cadence: paused ? 0 : (climbing ? 72 : 86),
      surface: surface,
      vibration: paused ? 0.05 : vib,
      paused: paused,
    ));
  }
  return out;
}

/// Insert the demo ride into [db] and finalize it. Returns the activity id.
Future<String> seedDemoActivity(AppDatabase db) async {
  final id = const Uuid().v4();
  final samples = demoGravelRide();
  await db.activitiesDao.insertActivity(ActivitiesCompanion.insert(
    id: id,
    title: 'Demo · Gravel Lembang Loop',
    sportType: SportType.gravelCycling.name,
    status: 'inProgress',
    startTime: samples.first.time,
    endTime: Value(samples.last.time),
    source: const Value('imported'),
    updatedAt: DateTime.now(),
  ));
  await db.trackPointsDao.insertBatchTrackPoints([
    for (var i = 0; i < samples.length; i++)
      TrackPointsCompanion.insert(
        activityId: id,
        sequenceIdx: i,
        timestamp: samples[i].time,
        latitude: samples[i].lat,
        longitude: samples[i].lon,
        altitudeMeters: samples[i].ele ?? 0,
        accuracyMeters: samples[i].accuracyM ?? 5,
        speedMps: samples[i].speedMps ?? 0,
        surfaceType: Value(samples[i].surface.name),
        vibrationRaw: Value(samples[i].vibration),
        heartRate: Value(samples[i].heartRate),
        cadence: Value(samples[i].cadence),
        isPaused: Value(samples[i].paused),
      ),
  ]);
  await ActivityFinalizer(db).finalize(id);
  return id;
}
