import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/seed/exercise_library.dart';

/// Migrasi skema 2 → 3: tabel gym dibuat & pustaka gerakan di-seed tanpa
/// menyentuh aktivitas yang sudah ada.
void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('virya_mig_');
    file = File('${dir.path}/db.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('database v2 naik ke versi terbaru dengan tabel gym + seed', () async {
    // 1. Buat database terbaru lalu turunkan ke bentuk v2.
    var db = AppDatabase.forTesting(NativeDatabase(file));
    await db.activitiesDao.insertActivity(
      ActivitiesCompanion.insert(
        id: 'run1',
        title: 'Lari pagi',
        sportType: 'running',
        status: 'completed',
        startTime: DateTime.utc(2026, 10, 1),
        updatedAt: DateTime.utc(2026, 10, 1),
      ),
    );
    for (final t in [
      'tasks',
      'workout_template_items',
      'workout_templates',
      'workout_sets',
      'exercises',
    ]) {
      await db.customStatement('DROP TABLE $t');
    }
    await db.customStatement('PRAGMA user_version = 2');
    await db.close();

    // 2. Buka ulang → onUpgrade(from: 2).
    db = AppDatabase.forTesting(NativeDatabase(file));
    final version = await db
        .customSelect('PRAGMA user_version')
        .map((r) => r.read<int>('user_version'))
        .getSingle();
    expect(version, 4);

    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((r) => r.read<String>('name'))
        .get();
    expect(
      tables,
      containsAll([
        'exercises',
        'workout_sets',
        'workout_templates',
        'workout_template_items',
      ]),
    );
    final exercises = await db.gymDao.watchExercises().first;
    expect(exercises.length, builtInExercises.length);
    expect(await db.activitiesDao.getActivityById('run1'), isNotNull);

    // Cascade tetap berlaku di tabel hasil migrasi.
    await db.gymDao.startSession(
      id: 'g1',
      title: 'Gym · Pagi',
      start: DateTime.utc(2026, 11, 1),
    );
    await db.into(db.workoutSets).insert(
      WorkoutSetsCompanion.insert(
        id: 's1',
        activityId: 'g1',
        exerciseId: exercises.first.id,
        exerciseOrder: 0,
        setIndex: 0,
      ),
    );
    await db.activitiesDao.deleteActivity('g1');
    expect(await db.select(db.workoutSets).get(), isEmpty);
    await db.close();
  });
}
