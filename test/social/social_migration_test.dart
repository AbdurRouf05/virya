import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('virya_social_mig_');
    file = File('${dir.path}/db.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('database v8 naik ke v9 tanpa kehilangan aktivitas', () async {
    var db = AppDatabase.forTesting(NativeDatabase(file));
    await db.activitiesDao.insertActivity(
      ActivitiesCompanion.insert(
        id: 'run-v8',
        title: 'Lari lama',
        sportType: 'running',
        status: 'completed',
        startTime: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 1),
      ),
    );
    await db.customStatement('DROP TABLE circle_members');
    await db.customStatement('DROP TABLE social_circles');
    await db.customStatement('DROP TABLE social_identities');
    await db.customStatement('PRAGMA user_version = 8');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(file));
    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((row) => row.read<String>('name'))
        .get();

    expect(tables, containsAll(['social_identities', 'social_circles', 'circle_members']));
    expect(await db.activitiesDao.getActivityById('run-v8'), isNotNull);
    expect(await db.select(db.socialIdentities).get(), isEmpty);
    await db.close();
  });
}
