import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/tasks/data/task_repository.dart';

/// Migrasi skema 3 → 4: tabel tugas dibuat tanpa menyentuh data lama.
void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('virya_mig_tasks_');
    file = File('${dir.path}/db.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('database v3 naik ke versi terbaru dengan tabel tasks + indeks', () async {
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
    final exerciseCount = (await db.gymDao.watchExercises().first).length;
    await db.customStatement('DROP TABLE tasks');
    await db.customStatement('DROP TABLE body_photos');
    await db.customStatement('DROP TABLE body_checkins');
    await db.customStatement('DROP TABLE app_limits');
    await db.customStatement('DROP TABLE app_usage_days');
    await db.customStatement('PRAGMA user_version = 3');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(file));
    final version = await db
        .customSelect('PRAGMA user_version')
        .map((r) => r.read<int>('user_version'))
        .getSingle();
    expect(version, 6);

    final objects = await db
        .customSelect('SELECT name FROM sqlite_master')
        .map((r) => r.read<String>('name'))
        .get();
    expect(objects, containsAll(['tasks', 'idx_tasks_done_at']));

    expect(await db.activitiesDao.getActivityById('run1'), isNotNull);
    expect((await db.gymDao.watchExercises().first).length, exerciseCount);

    // Tabel hasil migrasi benar-benar bisa dipakai.
    final repo = TaskRepository(db.tasksDao);
    final id = await repo.add('Setelah migrasi');
    expect((await db.tasksDao.watchOpen().first).single.id, id);
    await db.close();
  });

  test('database baru punya indeks tugas', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final names = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .map((r) => r.read<String>('name'))
        .get();
    expect(names, contains('idx_tasks_done_at'));
  });
}
