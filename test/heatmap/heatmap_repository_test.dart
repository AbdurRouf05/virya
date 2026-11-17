import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/heatmap/application/heatmap_providers.dart';
import 'package:virya/features/heatmap/data/heatmap_repository.dart';
import 'package:virya/features/heatmap/domain/heatmap_builder.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  Future<void> add(
    String id,
    String sport, {
    String status = 'completed',
    List<bool> paused = const [false, false, false],
  }) async {
    final now = DateTime(2026, 11, 1);
    await db.activitiesDao.insertActivity(
      ActivitiesCompanion.insert(
        id: id,
        title: id,
        sportType: sport,
        status: status,
        startTime: now,
        updatedAt: now,
      ),
    );
    await db.trackPointsDao.insertBatchTrackPoints([
      for (var i = paused.length - 1; i >= 0; i--)
        TrackPointsCompanion.insert(
          activityId: id,
          sequenceIdx: i,
          timestamp: now.add(Duration(seconds: i)),
          latitude: -6.9 + i * 0.0001,
          longitude: 107.6,
          altitudeMeters: 700,
          accuracyMeters: 3,
          speedMps: 5,
          isPaused: Value(paused[i]),
        ),
    ]);
  }

  test('hanya aktivitas selesai yang punya jalur GPS', () async {
    await add('ride', 'gravelCycling');
    await add('run', 'trailRunning');
    await add('rekam', 'hiking', status: 'inProgress');
    await add('gym', 'strength');
    await add('satu', 'walking', paused: const [false]);

    final tracks = await HeatmapRepository(db).loadTracks();
    expect(tracks.map((t) => t.category).toSet(), {
      SportCategory.cycling,
      SportCategory.running,
    });
    expect(tracks.length, 2);
  });

  test('titik urut dan titik jeda dilewati', () async {
    await add('ride', 'roadCycling', paused: const [false, true, false]);
    final track = (await HeatmapRepository(db).loadTracks()).single;
    final lats = [for (final p in track.points) p.$1];
    expect(lats.length, 2);
    expect(lats.first, closeTo(-6.9, 1e-9));
    expect(lats.last, closeTo(-6.8998, 1e-9));
  });

  test('provider menghitung hasil per filter', () async {
    await add('ride', 'gravelCycling');
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    Future<HeatmapResult> read(HeatmapFilter f) {
      final p = heatmapProvider(f);
      container.listen(p, (_, _) {});
      return container.read(p.future);
    }

    expect((await read(HeatmapFilter.all)).trackCount, 1);
    expect((await read(HeatmapFilter.cycling)).isEmpty, isFalse);
    expect((await read(HeatmapFilter.running)).isEmpty, isTrue);
  });
}
