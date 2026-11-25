import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';

/// Upgrade dari skema 7 tetap membuat tabel rute tanpa menyentuh data lama.
void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('virya_mig_routes_');
    file = File('${dir.path}/db.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('database v7 naik dengan tabel planned_routes', () async {
    final at = DateTime.utc(2026, 11, 16);
    var db = AppDatabase.forTesting(NativeDatabase(file));
    await db.focusDao.upsertLimit(
      AppLimitsCompanion.insert(
        packageName: 'a',
        label: 'A',
        dailyMinutes: 30,
        createdAt: at,
      ),
    );
    await db.customStatement('DROP TABLE planned_routes');
    await db.customStatement('PRAGMA user_version = 7');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(file));
    final version = await db
        .customSelect('PRAGMA user_version')
        .map((r) => r.read<int>('user_version'))
        .getSingle();
    expect(version, db.schemaVersion);

    final limits = await db.focusDao.getLimits();
    expect(limits.single.packageName, 'a');

    await db.plannedRoutesDao.upsert(PlannedRoutesCompanion.insert(
      id: 'r1',
      name: 'Keliling utara',
      sport: 'ride',
      shape: 'loop',
      pointsJson: '[[-6.2,106.8,10],[-6.21,106.81,12]]',
      distanceM: 1500,
      createdAt: at,
      updatedAt: at,
    ));
    final rows = await db.plannedRoutesDao.watchAll().first;
    expect(rows.single.name, 'Keliling utara');
    expect(rows.single.waypointsJson, '[]');
    expect(rows.single.ascentM, 0);

    await db.plannedRoutesDao.rename('r1', 'Pagi', at);
    expect((await db.plannedRoutesDao.byId('r1'))!.name, 'Pagi');
    await db.plannedRoutesDao.remove('r1');
    expect(await db.plannedRoutesDao.watchAll().first, isEmpty);
    await db.close();
  });
}
