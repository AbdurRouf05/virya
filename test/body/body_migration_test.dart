import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';

/// Migrasi skema 5 → 6: tabel progres tubuh dibuat tanpa menyentuh data lama.
void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('virya_mig_body_');
    file = File('${dir.path}/db.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('database v5 naik ke v6 dengan tabel tubuh', () async {
    final at = DateTime.utc(2026, 11, 8);
    var db = AppDatabase.forTesting(NativeDatabase(file));
    await db.focusDao.upsertLimit(
      AppLimitsCompanion.insert(
        packageName: 'a',
        label: 'A',
        dailyMinutes: 30,
        createdAt: at,
      ),
    );
    await db.customStatement('DROP TABLE body_photos');
    await db.customStatement('DROP TABLE body_checkins');
    await db.customStatement('PRAGMA user_version = 5');
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
    expect(tables, containsAll(['body_checkins', 'body_photos']));

    final limits = await db.focusDao.getLimits();
    expect(limits.single.packageName, 'a');
    expect(limits.single.dailyMinutes, 30);

    // Tabel hasil migrasi bisa dipakai, unique dan cascade tetap berlaku.
    await db.bodyDao.insertCheckin(
      BodyCheckinsCompanion.insert(id: 'c', day: '2026-11-08', createdAt: at),
    );
    await db.bodyDao.insertCheckin(
      BodyCheckinsCompanion.insert(id: 'd', day: '2026-11-08', createdAt: at),
    );
    await db.bodyDao.replacePhoto(
      BodyPhotosCompanion.insert(
        id: 'p',
        checkinId: 'c',
        pose: 'front',
        filePath: 'photos/body/c/front_p.jpg',
        createdAt: at,
      ),
    );
    final rows = await db.bodyDao.watchAll().first;
    expect(rows.single.checkin.id, 'c');
    expect(rows.single.photos.single.id, 'p');

    await db.bodyDao.deleteCheckin('c');
    expect(await db.select(db.bodyPhotos).get(), isEmpty);
    await db.close();
  });
}
