import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/location/location_fix.dart';
import 'package:virya/core/location/location_source.dart';
import 'package:virya/core/location/sources/simulated_location_source.dart';
import 'package:virya/core/location/telemetry_pipeline.dart';
import 'package:virya/core/models/track_sample.dart';
import 'package:virya/core/sensors/heart_rate_manager.dart';
import 'package:virya/core/sensors/heart_rate_source.dart';
import 'package:virya/core/sensors/hr_sensor_store.dart';
import 'package:virya/core/sensors/sensor_sources.dart';
import 'package:virya/features/recording/application/recording_platform.dart';
import 'package:virya/features/recording/application/recording_session.dart';
import 'package:virya/features/recording/application/recording_sources.dart';
import 'package:virya/features/recording/application/recording_store.dart';
import 'package:virya/features/recording/domain/recording_settings.dart';

import 'fake_ble.dart';

class _FakeHeartRate implements HeartRateSource {
  final out = StreamController<int?>();
  bool started = false;
  bool stopped = false;
  @override
  Stream<int?> start() {
    started = true;
    return out.stream;
  }

  @override
  Future<void> stop() async {
    stopped = true;
    await out.close();
  }
}

class _FakePlatform extends RecordingPlatform {
  const _FakePlatform();
  @override
  LocationSource createLocationSource({
    required bool simulated,
    double speedUp = 10,
    String? notificationLabel,
  }) => SimulatedLocationSource(speedUp: speedUp);
  @override
  PressureSource createPressureSource({required bool simulated}) =>
      NoPressureSource();
}

LocationFix _fix(DateTime t, {double lat = -7.25}) => LocationFix(
  time: t,
  lat: lat,
  lon: 112.75,
  altitude: 10,
  accuracy: 4,
  speed: 4,
);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final t0 = DateTime.utc(2026, 1, 1, 6);

  test('pipeline writes the sensor bpm into samples', () {
    final p = TelemetryPipeline(sport: SportType.roadRunning, startTime: t0);
    p.setHeartRate(144);
    final r = p.process(_fix(t0));
    expect(r.sample?.heartRate, 144);
    expect(r.snapshot.heartRate, 144);
    p.setHeartRate(null);
    expect(p.process(_fix(t0.add(const Duration(seconds: 1)))).sample?.heartRate, isNull);
  });

  test('replay does not carry a stored bpm into new samples', () {
    final p = TelemetryPipeline(sport: SportType.roadRunning, startTime: t0);
    p.replay([
      TrackSample(time: t0, lat: -7.25, lon: 112.75, accuracyM: 4, heartRate: 150),
    ]);
    final r = p.process(_fix(t0.add(const Duration(seconds: 1))));
    expect(r.sample?.heartRate, isNull);
  });

  Future<(RecordingSources, RecordingSession, AppDatabase, String)> startup(
    HeartRateSource source, {
    required bool simulated,
  }) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final (id, start) = await RecordingStore(db).createActivity(SportType.roadRunning);
    final session = RecordingSession(
      db: db,
      activityId: id,
      startTime: start,
      sport: SportType.roadRunning,
      settings: const RecordingSettings(),
      history: const [],
    );
    final sources = RecordingSources(
      () => const _FakePlatform(),
      heartRate: () => source,
    );
    sources.createLocation(
      simulated: true,
      speedUp: 1,
      notificationLabel: 'tes',
    );
    sources.startSensors(session, simulated: simulated);
    return (sources, session, db, id);
  }

  test('sensor bpm reaches the stored track points', () async {
    final hr = _FakeHeartRate();
    final (sources, session, db, id) = await startup(hr, simulated: false);
    hr.out.add(151);
    await Future<void>.delayed(Duration.zero);
    session.process(_fix(t0));
    await session.closeFlush();
    await sources.teardown();
    expect(hr.stopped, isTrue);
    final points = await db.trackPointsDao.getPointsForActivity(id);
    expect(points.single.heartRate, 151);
  });

  test('simulated recording does not open the sensor', () async {
    final hr = _FakeHeartRate();
    final (sources, session, _, _) = await startup(hr, simulated: true);
    await sources.teardown();
    await session.closeFlush();
    expect(hr.started, isFalse);
    expect(hr.stopped, isFalse);
  });

  test('managed source holds the sensor for the recording', () async {
    final gateway = FakeGateway();
    final manager = HeartRateManager(
      gateway: gateway,
      store: FakeStore(const HrSensorRef(id: 'AA', name: 'Tali')),
    );
    addTearDown(manager.dispose);
    final source = ManagedHeartRateSource(manager);
    final seen = <int?>[];
    final sub = source.start().listen(seen.add);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    gateway.lastLink.emit([0x00, 130]);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(seen, contains(130));
    final link = gateway.lastLink;
    await source.stop();
    await sub.cancel();
    expect(link.closed, isTrue);
    await source.stop();
  });
}
