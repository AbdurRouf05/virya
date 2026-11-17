import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/seed/exercise_library.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  WorkoutSetsCompanion set(
    String id,
    String activity,
    String exercise, {
    int order = 0,
    int index = 0,
    double kg = 60,
    int reps = 8,
    bool done = true,
  }) => WorkoutSetsCompanion.insert(
    id: id,
    activityId: activity,
    exerciseId: exercise,
    exerciseOrder: order,
    setIndex: index,
    weightKg: Value(kg),
    reps: Value(reps),
    completedAt: Value(done ? DateTime.utc(2026, 11, 1) : null),
  );

  Future<String> finishedSession(String id, DateTime start, double kg) async {
    await db.gymDao.startSession(id: id, title: 'Gym · $id', start: start);
    await db.gymDao.upsertSet(set('$id-1', id, 'ex_bench_press', kg: kg));
    await db.gymDao.finishSession(id, end: start.add(const Duration(hours: 1)));
    return id;
  }

  test('pustaka gerakan bawaan ter-seed saat database dibuat', () async {
    final all = await db.gymDao.watchExercises().first;
    expect(all.length, builtInExercises.length);
    expect(all.length, greaterThanOrEqualTo(40));
    expect(all.every((e) => !e.isCustom), isTrue);
  });

  test('selesai sesi: set belum dicentang dibuang, durasi tercatat', () async {
    final start = DateTime.utc(2026, 11, 1, 10);
    await db.gymDao.startSession(id: 'g1', title: 'Gym · Push', start: start);
    expect((await db.gymDao.activeSession())?.id, 'g1');

    await db.gymDao.upsertSet(set('a', 'g1', 'ex_bench_press'));
    await db.gymDao.upsertSet(set('b', 'g1', 'ex_bench_press', index: 1, done: false));
    // upsert memperbarui baris yang sama
    await db.gymDao.upsertSet(set('a', 'g1', 'ex_bench_press', kg: 62.5));

    await db.gymDao.finishSession('g1', end: start.add(const Duration(minutes: 45)));

    final sets = await db.gymDao.setsFor('g1');
    expect(sets.map((s) => s.id), ['a']);
    expect(sets.single.weightKg, 62.5);
    final act = await db.activitiesDao.getActivityById('g1');
    expect(act!.status, 'completed');
    expect(act.sportType, 'strength');
    expect(act.elapsedTimeSeconds, 45 * 60);
    expect(act.totalDistanceMeters, 0);
    expect(await db.gymDao.activeSession(), isNull);
  });

  test('previousSets mengambil sesi selesai terakhir', () async {
    await finishedSession('old', DateTime.utc(2026, 10, 1), 50);
    await finishedSession('new', DateTime.utc(2026, 10, 8), 55);
    await db.gymDao.startSession(id: 'cur', title: 'x', start: DateTime.utc(2026, 10, 9));
    await db.gymDao.upsertSet(set('c1', 'cur', 'ex_bench_press', kg: 70));

    final prev = await db.gymDao.previousSets(
      'ex_bench_press',
      excludeActivityId: 'cur',
    );
    expect(prev.single.weightKg, 55);
    expect(await db.gymDao.previousSets('ex_squat'), isEmpty);

    final logged = await db.gymDao.watchLoggedSets().first;
    expect(logged.length, 2); // sesi berjalan tidak ikut
  });

  test('hapus aktivitas ikut menghapus set (cascade)', () async {
    await finishedSession('g', DateTime.utc(2026, 10, 1), 50);
    expect(await db.gymDao.setsFor('g'), isNotEmpty);
    await db.activitiesDao.deleteActivity('g');
    final left = await db.select(db.workoutSets).get();
    expect(left, isEmpty);
  });

  test('buang sesi menghapus aktivitas & setnya', () async {
    await db.gymDao.startSession(id: 'd', title: 'x', start: DateTime.utc(2026));
    await db.gymDao.upsertSet(set('d1', 'd', 'ex_bench_press'));
    await db.gymDao.discardSession('d');
    expect(await db.activitiesDao.getActivityById('d'), isNull);
    expect(await db.select(db.workoutSets).get(), isEmpty);
  });

  test('pemulihan GPS mengabaikan sesi gym berjalan', () async {
    await db.gymDao.startSession(id: 'g', title: 'x', start: DateTime.utc(2026));
    expect(await db.activitiesDao.getUnfinishedActivity(), isNull);
  });

  test('template: simpan, ganti isi, hapus (cascade item)', () async {
    final now = DateTime.utc(2026);
    final t = WorkoutTemplatesCompanion.insert(
      id: 't1',
      name: 'Push',
      createdAt: now,
      updatedAt: now,
    );
    WorkoutTemplateItemsCompanion item(String id, String ex, int o) =>
        WorkoutTemplateItemsCompanion.insert(
          id: id,
          templateId: 't1',
          exerciseId: ex,
          itemOrder: o,
        );
    await db.gymDao.saveTemplate(t, [
      item('i1', 'ex_bench_press', 0),
      item('i2', 'ex_ohp', 1),
    ]);
    expect((await db.gymDao.templateItems('t1')).length, 2);

    await db.gymDao.saveTemplate(t.copyWith(name: const Value('Push B')), [
      item('i3', 'ex_squat', 0),
    ]);
    final items = await db.gymDao.templateItems('t1');
    expect(items.single.exerciseId, 'ex_squat');
    expect(items.single.targetSets, 3);
    expect((await db.gymDao.watchTemplates().first).single.name, 'Push B');

    await db.gymDao.deleteTemplate('t1');
    expect(await db.gymDao.watchTemplates().first, isEmpty);
    expect(await db.select(db.workoutTemplateItems).get(), isEmpty);
  });
}
