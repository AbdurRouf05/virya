import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/tasks/data/task_repository.dart';

/// Migrasi skema 4 → 5: tabel fokus dibuat tanpa menyentuh data lama.
void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('virya_mig_focus_');
    file = File('${dir.path}/db.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('database v4 naik ke versi terbaru dengan tabel fokus', () async {
    var db = AppDatabase.forTesting(NativeDatabase(file));
    final taskId = await TaskRepository(db.tasksDao).add('Tugas lama');
    await db.customStatement('DROP TABLE body_photos');
    await db.customStatement('DROP TABLE body_checkins');
    await db.customStatement('DROP TABLE app_limits');
    await db.customStatement('DROP TABLE app_usage_days');
    await db.customStatement('PRAGMA user_version = 4');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(file));
    final version = await db
        .customSelect('PRAGMA user_version')
        .map((r) => r.read<int>('user_version'))
        .getSingle();
    expect(version, 6);

    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((r) => r.read<String>('name'))
        .get();
    expect(tables, containsAll(['app_limits', 'app_usage_days']));

    final open = await db.tasksDao.watchOpen().first;
    expect(open.single.id, taskId);
    expect(open.single.title, 'Tugas lama');

    // Tabel hasil migrasi benar-benar bisa dipakai.
    await db.focusDao.upsertLimit(
      AppLimitsCompanion.insert(
        packageName: 'a',
        label: 'A',
        dailyMinutes: 30,
        createdAt: DateTime.utc(2026, 11, 8),
      ),
    );
    await db.focusDao.upsertUsage([
      AppUsageDaysCompanion.insert(
        day: '2026-11-08',
        packageName: 'a',
        label: 'A',
        minutes: 5,
        limitMinutes: 30,
      ),
    ], '2026-11-08');
    expect((await db.focusDao.getLimits()).single.enabled, isTrue);
    expect(await db.focusDao.watchUsageOn('2026-11-08').first, hasLength(1));
    await db.close();
  });
}
