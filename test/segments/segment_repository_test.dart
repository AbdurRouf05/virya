import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/data/activity_finalizer.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/segments/data/live_segment_feed.dart';
import 'package:virya/features/segments/data/segment_repository.dart';
import 'package:virya/features/segments/domain/live_segment_tracker.dart';
import 'package:virya/features/segments/domain/segment_codec.dart';

import 'segment_fixtures.dart';

void main() {
  const lengthM = 1000.0;
  late AppDatabase db;
  late SegmentRepository repo;
  final line = straightSegment(lengthM);

  Future<int> effortCount() async =>
      (await db.select(db.segmentEfforts).get()).length;

  setUp(() {
    db = AppDatabase.memory();
    repo = SegmentRepository(db);
  });

  tearDown(() async {
    ActivityFinalizer.afterFinalize = null;
    await db.close();
  });

  test('membuat segmen langsung menemukan upaya lama', () async {
    await seedActivity(db, 'cepat', pass(10, lengthM));
    await seedActivity(db, 'lambat', pass(5, lengthM));

    final (id, found) = await repo.create(
      name: ' Bukit ',
      polyline: line,
      sportType: 'roadCycling',
    );

    expect(found, 2);
    final summary = (await repo.watchSummaries().first).single;
    expect(summary.name, 'Bukit');
    expect(summary.effortCount, 2);
    expect(summary.bestS, closeTo(100, 3));

    final efforts = await repo.watchEfforts(id).first;
    expect(efforts.first.activityId, 'cepat');
    expect(efforts.first.isBest, isTrue);
    expect(efforts.last.isBest, isFalse);

    final saved = await db.select(db.segmentEfforts).get();
    expect(decodeMarks(saved.first.progressJson), isNotEmpty);
  });

  test('pencarian melewati olahraga lain dan aktivitas belum selesai', () async {
    await seedActivity(db, 'lari', pass(4, lengthM), sport: 'roadRunning');
    await seedActivity(db, 'jalan', pass(5, lengthM), status: 'inProgress');
    await seedActivity(db, 'gowes', pass(5, lengthM), sport: 'gravelCycling');

    final (_, found) = await repo.create(
      name: 'A',
      polyline: line,
      sportType: 'roadCycling',
    );
    expect(found, 1);
  });

  test('sinkron ulang tidak menggandakan upaya', () async {
    final samples = pass(5, lengthM);
    await seedActivity(db, 'a', samples);
    await repo.create(name: 'A', polyline: line, sportType: 'roadCycling');
    expect(await effortCount(), 1);

    await repo.syncActivity('a', samples, SportType.roadCycling);
    await repo.syncActivity('a', samples, SportType.roadCycling);
    expect(await effortCount(), 1);
  });

  test('sinkron menghapus upaya yang tidak lagi berlaku', () async {
    final samples = pass(5, lengthM);
    await seedActivity(db, 'a', samples);
    await repo.create(name: 'A', polyline: line, sportType: 'roadCycling');

    await repo.syncActivity('a', samples, SportType.roadRunning);
    expect(await effortCount(), 0);
  });

  test('finalisasi aktivitas baru mencatat upaya segmen', () async {
    await repo.create(name: 'A', polyline: line, sportType: 'roadCycling');
    await seedActivity(db, 'baru', pass(5, lengthM), status: 'inProgress');
    ActivityFinalizer.afterFinalize = syncSegmentsAfterFinalize;

    await ActivityFinalizer(db).finalize('baru');

    final rows = await db.select(db.segmentEfforts).get();
    expect(rows.single.activityId, 'baru');
  });

  test('menghapus aktivitas ikut menghapus upayanya', () async {
    await seedActivity(db, 'a', pass(5, lengthM));
    await repo.create(name: 'A', polyline: line, sportType: 'roadCycling');

    await db.activitiesDao.deleteActivity('a');

    expect(await effortCount(), 0);
    final summary = (await repo.watchSummaries().first).single;
    expect(summary.bestS, isNull);
  });

  test('menghapus segmen ikut menghapus upayanya', () async {
    await seedActivity(db, 'a', pass(5, lengthM));
    final (id, _) = await repo.create(
      name: 'A',
      polyline: line,
      sportType: 'roadCycling',
    );

    await repo.delete(id);

    expect(await effortCount(), 0);
    expect(await repo.watchSummaries().first, isEmpty);
    expect(await db.activitiesDao.getActivityById('a'), isNotNull);
  });

  test('segmen di aktivitas menandai rekornya', () async {
    await seedActivity(db, 'cepat', pass(10, lengthM));
    await seedActivity(db, 'lambat', pass(5, lengthM));
    await repo.create(name: 'A', polyline: line, sportType: 'roadCycling');

    final fast = await repo.watchActivitySegments('cepat').first;
    final slow = await repo.watchActivitySegments('lambat').first;
    expect(fast.single.isBest, isTrue);
    expect(slow.single.isBest, isFalse);
  });

  test('ghost memakai upaya tercepat dan hanya untuk olahraganya', () async {
    await seedActivity(db, 'cepat', pass(10, lengthM));
    await seedActivity(db, 'lambat', pass(5, lengthM));
    await repo.create(name: 'A', polyline: line, sportType: 'roadCycling');

    final seed = (await repo.liveSeeds(SportType.mountainBiking)).single;
    expect(seed.ghostTimeS, closeTo(100, 3));
    expect(seed.ghostMarksS, isNotEmpty);
    expect(await repo.liveSeeds(SportType.roadRunning), isEmpty);
  });

  group('LiveSegmentFeed', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() => container.dispose());

    test('mengikuti segmen dengan ghost sampai rekor baru', () async {
      await seedActivity(db, 'ghost', pass(5, lengthM));
      await repo.create(name: 'Bukit', polyline: line, sportType: 'roadCycling');

      final feed = container.read(liveSegmentFeedProvider.notifier);
      await feed.begin(SportType.roadCycling);

      final cues = <String>[];
      var finished = false;
      for (final s in pass(8, lengthM, startS: 9000)) {
        final cue = feed.onFix(s.lat, s.lon, s.time);
        if (cue != null) cues.add(cue);
        final v = container.read(liveSegmentFeedProvider);
        finished = finished || v?.state.phase == LiveSegmentPhase.finished;
      }

      expect(finished, isTrue);
      expect(cues.first, 'Segmen Bukit, 200 meter lagi.');
      expect(cues, contains('Segmen Bukit dimulai.'));
      expect(cues.where((c) => c.contains('di depan ghost')), isNotEmpty);
      expect(cues.where((c) => c.startsWith('Rekor baru di Bukit')), hasLength(1));

      feed.end();
      expect(container.read(liveSegmentFeedProvider), isNull);
      final s = pass(8, lengthM).first;
      expect(feed.onFix(s.lat, s.lon, s.time), isNull);
    });

    test('tanpa segmen, fix tidak menghasilkan apa-apa', () async {
      final feed = container.read(liveSegmentFeedProvider.notifier);
      await feed.begin(SportType.roadCycling);
      final s = pass(8, lengthM).first;
      expect(feed.onFix(s.lat, s.lon, s.time), isNull);
      expect(container.read(liveSegmentFeedProvider), isNull);
    });
  });
}
