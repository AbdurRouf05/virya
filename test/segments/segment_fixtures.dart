import 'dart:math' as math;

import 'package:virya/core/analytics/geo.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/models/track_sample.dart';

const lat0 = -6.9, lon0 = 107.6;
const _ky = earthRadiusM * math.pi / 180;
final _kx = _ky * math.cos(lat0 * math.pi / 180);

(double, double) at(double eastM, double northM) =>
    (lat0 + northM / _ky, lon0 + eastM / _kx);

/// Garis lurus ke timur sepanjang [lengthM], titik tiap 20 m.
List<(double, double)> straightSegment(double lengthM) => [
  for (var x = 0.0; x <= lengthM; x += 20) at(x, 0),
];

final t0 = DateTime.utc(2026, 6, 1, 7);

/// Satu fix per detik dari 200 m sebelum segmen sampai 200 m sesudahnya.
List<TrackSample> pass(double speed, double lengthM, {int startS = 0}) {
  final out = <TrackSample>[];
  for (var k = 0;; k++) {
    final d = -200 + k * speed;
    if (d > lengthM + 200) break;
    final (lat, lon) = at(d, 0);
    out.add(
      TrackSample(
        time: t0.add(Duration(seconds: startS + k)),
        lat: lat,
        lon: lon,
      ),
    );
  }
  return out;
}

Future<void> seedActivity(
  AppDatabase db,
  String id,
  List<TrackSample> samples, {
  String sport = 'roadCycling',
  String status = 'completed',
}) async {
  await db.activitiesDao.insertActivity(
    ActivitiesCompanion.insert(
      id: id,
      title: 'Aktivitas $id',
      sportType: sport,
      status: status,
      startTime: samples.first.time,
      updatedAt: samples.first.time,
    ),
  );
  await db.batch(
    (b) => b.insertAll(db.trackPoints, [
      for (final (i, s) in samples.indexed)
        TrackPointsCompanion.insert(
          activityId: id,
          sequenceIdx: i,
          timestamp: s.time,
          latitude: s.lat,
          longitude: s.lon,
          altitudeMeters: 700,
          accuracyMeters: 4,
          speedMps: 5,
        ),
    ]),
  );
}
