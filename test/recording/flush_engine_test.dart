import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/recording/data/incremental_flush_engine.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  TrackPointsCompanion pt(int i, DateTime t0) => TrackPointsCompanion.insert(
        activityId: 'a1',
        sequenceIdx: i,
        timestamp: t0.add(Duration(seconds: i)),
        latitude: -7.2 + i * 1e-4,
        longitude: 107.9,
        altitudeMeters: 700,
        accuracyMeters: 4,
        speedMps: 8,
      );

  test('flush writes points and a partial summary that keeps other columns',
      () async {
    final now = DateTime(2026, 5, 1, 7);
    await db.activitiesDao.insertActivity(ActivitiesCompanion.insert(
      id: 'a1',
      title: 'Gravel Pagi',
      sportType: 'gravelCycling',
      status: 'inProgress',
      startTime: now,
      updatedAt: now,
      description: const Value('catatan'),
      gearId: const Value('g1'),
      isFavorite: const Value(true),
    ));

    final engine = IncrementalFlushEngine(
      trackPointsDao: db.trackPointsDao,
      activitiesDao: db.activitiesDao,
      activityId: 'a1',
      autoStartTimer: false,
    );
    for (var i = 0; i < 7; i++) {
      await engine.recordPoint(pt(i, now),
          totalDistanceMeters: i * 8.0,
          movingTimeSeconds: i,
          elapsedTimeSeconds: i,
          maxSpeedMps: 8,
          gravelPercentage: 60,
          asphaltPercentage: 40);
    }
    // threshold 5 -> one auto flush, 2 buffered
    expect(engine.totalFlushedCount, 5);
    expect(engine.bufferedPointsCount, 2);
    await engine.dispose();
    expect(engine.totalFlushedCount, 7);

    final a = (await db.activitiesDao.getActivityById('a1'))!;
    expect(a.totalDistanceMeters, 48);
    expect(a.gravelPercentage, 60);
    expect(a.title, 'Gravel Pagi');
    expect(a.description, 'catatan');
    expect(a.gearId, 'g1');
    expect(a.isFavorite, isTrue);
    expect(a.status, 'inProgress');
    expect(await db.trackPointsDao.getPointsForActivity('a1'), hasLength(7));
  });

  test('concurrent flushes are serialized (no duplicate inserts)', () async {
    final now = DateTime(2026, 5, 1, 7);
    await db.activitiesDao.insertActivity(ActivitiesCompanion.insert(
      id: 'a1',
      title: 't',
      sportType: 'roadCycling',
      status: 'inProgress',
      startTime: now,
      updatedAt: now,
    ));
    final engine = IncrementalFlushEngine(
      trackPointsDao: db.trackPointsDao,
      activitiesDao: db.activitiesDao,
      activityId: 'a1',
      flushThreshold: 100,
      autoStartTimer: false,
    );
    for (var i = 0; i < 3; i++) {
      await engine.recordPoint(pt(i, now));
    }
    await Future.wait([engine.flush(), engine.flush(), engine.flush()]);
    expect(engine.totalFlushedCount, 3);
    expect(await db.trackPointsDao.getPointsForActivity('a1'), hasLength(3));
  });
}
