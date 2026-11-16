import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/tasks/data/task_repository.dart';

/// Migrasi skema 6 → 7: kolom rutinitas ditambahkan ke tabel tugas lama.
void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('virya_mig_routine_');
    file = File('${dir.path}/db.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('database v6 naik ke v7, tugas lama tetap ada', () async {
    var db = AppDatabase.forTesting(NativeDatabase(file));
    await db.customStatement('DROP TABLE tasks');
    // Bentuk tabel tugas di skema 6, tanpa kolom rutinitas.
    await db.customStatement('''
      CREATE TABLE tasks (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        note TEXT NULL,
        due_day TEXT NULL,
        priority INTEGER NOT NULL DEFAULT 0,
        pinned INTEGER NOT NULL DEFAULT 0 CHECK (pinned IN (0, 1)),
        done_at INTEGER NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.customStatement(
      "INSERT INTO tasks (id, title, due_day, created_at) "
      "VALUES ('old', 'Tugas lama', '2026-11-16', 1700000000)",
    );
    await db.customStatement('PRAGMA user_version = 6');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(file));
    final version = await db
        .customSelect('PRAGMA user_version')
        .map((r) => r.read<int>('user_version'))
        .getSingle();
    expect(version, db.schemaVersion);

    final old = taskItemOf((await db.tasksDao.watchOpen().first).single);
    expect(old.id, 'old');
    expect(old.repeatDaily, isFalse);
    expect(old.remindMinute, isNull);

    final repo = TaskRepository(db.tasksDao);
    final id = await repo.add('Push GitHub', repeatDaily: true, remindMinute: 1200);
    final routine = (await db.tasksDao.watchRoutines().first).single;
    expect(routine.id, id);
    expect(routine.remindMinute, 1200);
    await db.close();
  });
}
