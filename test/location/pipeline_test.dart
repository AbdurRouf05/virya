import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/data/demo_data.dart';
import 'package:virya/core/location/location_fix.dart';
import 'package:virya/core/location/sources/simulated_location_source.dart';
import 'package:virya/core/location/telemetry_pipeline.dart';

final t0 = DateTime(2026, 1, 1, 7);

/// Straight line north at [speed] m/s, 1 Hz.
List<LocationFix> straight(int seconds, double speed, {int from = 0}) => [
      for (var i = 0; i < seconds; i++)
        LocationFix(
          time: t0.add(Duration(seconds: from + i)),
          lat: -6.9 + (from + i) * speed / 111195,
          lon: 107.6,
          accuracy: 4,
          altitude: 700,
          speed: speed,
        ),
    ];

void main() {
  test('distance accumulates along a straight line', () {
    final p = TelemetryPipeline(sport: SportType.roadCycling);
    for (final f in straight(101, 8)) {
      p.process(f);
    }
    // 100 s * 8 m/s = 800 m (Kalman lag trims a few meters).
    expect(p.distanceM, closeTo(800, 15));
    expect(p.movingTimeS, 100);
    final snap = p.snapshotAt(t0.add(const Duration(seconds: 100)));
    expect(snap.currentSpeedKmh, closeTo(28.8, 0.5));
    expect(snap.bearingDegrees, closeTo(0, 1));
  });

  test('stop triggers auto-pause; moving time < elapsed', () {
    final p = TelemetryPipeline(sport: SportType.gravelCycling);
    final fixes = [
      ...straight(60, 6),
      // 60 s stationary at the last position.
      for (var i = 0; i < 60; i++)
        LocationFix(
          time: t0.add(Duration(seconds: 60 + i)),
          lat: -6.9 + 59 * 6 / 111195,
          lon: 107.6,
          accuracy: 4,
          speed: 0,
        ),
    ];
    var changes = 0;
    for (final f in fixes) {
      if (p.process(f).autoPauseChanged) changes++;
    }
    expect(p.isAutoPaused, isTrue);
    expect(changes, 1);
    final s = p.snapshotAt(fixes.last.time);
    expect(s.elapsedTimeSeconds, 119);
    expect(s.movingTimeSeconds, lessThan(70));
    expect(s.currentSpeedKmh, 0);
  });

  test('manual pause excludes distance and time, resume continues', () {
    final p = TelemetryPipeline(sport: SportType.roadRunning);
    for (final f in straight(31, 3)) {
      p.process(f);
    }
    final before = p.distanceM;
    p.setManualPause(true);
    for (final f in straight(30, 3, from: 31)) {
      final r = p.process(f);
      expect(r.sample!.paused, isTrue);
    }
    expect(p.distanceM, before);
    p.setManualPause(false);
    for (final f in straight(30, 3, from: 61)) {
      p.process(f);
    }
    expect(p.distanceM, closeTo(before + 90, 10));
    expect(p.movingTimeS, closeTo(60, 1));
  });

  test('GPS spike and inaccurate fixes do not add distance', () {
    final p = TelemetryPipeline(sport: SportType.roadCycling);
    final fixes = straight(60, 5);
    fixes[30] = LocationFix(
        time: fixes[30].time, lat: -6.8, lon: 107.6, accuracy: 4, speed: 5);
    fixes[40] = LocationFix(
        time: fixes[40].time, lat: -6.95, lon: 107.6, accuracy: 60, speed: 5);
    var rejected = 0;
    for (final f in fixes) {
      if (p.process(f).rejected != null) rejected++;
    }
    expect(rejected, 2);
    expect(p.distanceM, closeTo(295, 15));
  });

  test('replay rebuilds totals for crash recovery', () {
    final ride = demoGravelRide(seconds: 600);
    final a = TelemetryPipeline(sport: SportType.gravelCycling);
    a.replay(ride);
    expect(a.distanceM, greaterThan(3000));
    expect(a.isManuallyPaused, isFalse);
  });

  test('end-to-end: demo gravel ride through the full pipeline', () {
    final ride = demoGravelRide();
    final p = TelemetryPipeline(sport: SportType.gravelCycling);
    for (final s in ride) {
      p.setSurface(s.surface, s.vibration);
      p.process(LocationFix(
        time: s.time,
        lat: s.lat,
        lon: s.lon,
        altitude: s.ele,
        accuracy: s.accuracyM ?? 5,
        speed: s.speedMps,
        heartRate: s.heartRate,
      ));
    }
    final snap = p.snapshotAt(ride.last.time);
    expect(snap.totalDistanceMeters, inInclusiveRange(25000, 45000));
    expect(snap.movingTimeSeconds, lessThan(snap.elapsedTimeSeconds));
    expect(snap.elapsedTimeSeconds, ride.length - 1);
    expect(snap.totalElevationGainMeters, inInclusiveRange(350, 1200));
    expect(snap.averageSpeedKmh, inInclusiveRange(15, 35));
    expect(snap.maxSpeedKmh, lessThan(45));
    expect(snap.heartRate, isNotNull);
  });

  test('SimulatedLocationSource replays samples with speed-up', () async {
    final src = SimulatedLocationSource(
      samples: demoGravelRide(seconds: 50),
      speedUp: 1000,
      startTime: t0,
    );
    final fixes = await src.start().toList().timeout(const Duration(seconds: 5));
    expect(fixes, hasLength(50));
    expect(fixes.first.time, t0);
    expect(fixes.last.time, t0.add(const Duration(seconds: 49)));
    expect(src.isSimulated, isTrue);
    await src.stop();
  });
}
