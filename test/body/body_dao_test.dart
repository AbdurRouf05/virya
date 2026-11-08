import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/daos/body_dao.dart';

void main() {
  late AppDatabase db;
  late BodyDao dao;
  final at = DateTime.utc(2026, 11, 8, 1);

  setUp(() {
    db = AppDatabase.memory();
    dao = db.bodyDao;
  });

  tearDown(() => db.close());

  Future<void> checkin(String id, String day, {double? kg}) =>
      dao.insertCheckin(
        BodyCheckinsCompanion.insert(
          id: id,
          day: day,
          createdAt: at,
          weightKg: Value(kg),
        ),
      );

  BodyPhotosCompanion photo(String id, String checkinId, String pose) =>
      BodyPhotosCompanion.insert(
        id: id,
        checkinId: checkinId,
        pose: pose,
        filePath: 'photos/body/$checkinId/$pose.jpg',
        createdAt: at,
      );

  test('foreign key aktif', () async {
    final on = await db
        .customSelect('PRAGMA foreign_keys')
        .map((r) => r.read<int>('foreign_keys'))
        .getSingle();
    expect(on, 1);
  });

  test('watchAll terbaru dulu, foto terkelompok, tanpa foto tetap ada', () async {
    await checkin('a', '2026-10-25');
    await checkin('c', '2026-11-08');
    await checkin('b', '2026-11-01');
    await dao.replacePhoto(photo('p1', 'c', 'front'));
    await dao.replacePhoto(photo('p2', 'c', 'side'));
    await dao.replacePhoto(photo('p3', 'a', 'back'));

    final rows = await dao.watchAll().first;
    expect(rows.map((r) => r.checkin.id), ['c', 'b', 'a']);
    expect(rows[0].photos.map((f) => f.id), unorderedEquals(['p1', 'p2']));
    expect(rows[1].photos, isEmpty);
    expect(rows[2].photos.single.id, 'p3');
  });

  test('watchAll kosong saat belum ada data', () async {
    expect(await dao.watchAll().first, isEmpty);
  });

  test('hari yang sama diabaikan dan data lama tetap', () async {
    await checkin('a', '2026-11-08', kg: 70);
    await checkin('b', '2026-11-08', kg: 99);

    final rows = await dao.watchAll().first;
    expect(rows.single.checkin.id, 'a');
    expect(rows.single.checkin.weightKg, 70);
  });

  test('findByDay mencari hari yang tepat', () async {
    await checkin('a', '2026-11-08');
    expect((await dao.findByDay('2026-11-08'))?.id, 'a');
    expect(await dao.findByDay('2026-11-07'), isNull);
  });

  test('replacePhoto mengembalikan baris lama, satu foto per pose', () async {
    await checkin('a', '2026-11-08');
    expect(await dao.replacePhoto(photo('p1', 'a', 'front')), isNull);

    final old = await dao.replacePhoto(photo('p2', 'a', 'front'));
    expect(old?.id, 'p1');
    expect(old?.filePath, 'photos/body/a/front.jpg');

    final photos = await dao.photosOf('a');
    expect(photos.single.id, 'p2');
    expect(await dao.findPhoto('p1'), isNull);
  });

  test('pose berbeda dan check-in berbeda tidak saling mengganti', () async {
    await checkin('a', '2026-11-08');
    await checkin('b', '2026-11-01');
    await dao.replacePhoto(photo('p1', 'a', 'front'));
    expect(await dao.replacePhoto(photo('p2', 'a', 'side')), isNull);
    expect(await dao.replacePhoto(photo('p3', 'b', 'front')), isNull);

    expect((await dao.photosOf('a')).map((f) => f.id), unorderedEquals(['p1', 'p2']));
    expect((await dao.photosOf('b')).single.id, 'p3');
  });

  test('replacePhoto gagal tidak menghapus foto lama', () async {
    await checkin('a', '2026-11-08');
    await checkin('b', '2026-11-01');
    await dao.replacePhoto(photo('p1', 'a', 'front'));
    await dao.replacePhoto(photo('p2', 'b', 'front'));

    // Id p2 sudah dipakai, jadi insert di dalam transaksi gagal.
    await expectLater(
      dao.replacePhoto(photo('p2', 'a', 'front')),
      throwsA(anything),
    );
    expect((await dao.photosOf('a')).single.id, 'p1');
  });

  test('deleteCheckin ikut menghapus foto, check-in lain aman', () async {
    await checkin('a', '2026-11-08');
    await checkin('b', '2026-11-01');
    await dao.replacePhoto(photo('p1', 'a', 'front'));
    await dao.replacePhoto(photo('p2', 'a', 'side'));
    await dao.replacePhoto(photo('p3', 'b', 'front'));

    await dao.deleteCheckin('a');

    expect(await dao.findByDay('2026-11-08'), isNull);
    expect(await dao.photosOf('a'), isEmpty);
    expect((await dao.photosOf('b')).single.id, 'p3');
  });

  test('deletePhoto hanya menghapus foto itu', () async {
    await checkin('a', '2026-11-08');
    await dao.replacePhoto(photo('p1', 'a', 'front'));
    await dao.replacePhoto(photo('p2', 'a', 'side'));

    await dao.deletePhoto('p1');

    expect((await dao.photosOf('a')).single.id, 'p2');
  });

  test('watchAll ikut berubah saat foto ditambahkan', () async {
    await checkin('a', '2026-11-08');
    final stream = dao.watchAll();
    expect((await stream.first).single.photos, isEmpty);
    await dao.replacePhoto(photo('p1', 'a', 'front'));
    expect((await stream.first).single.photos.single.id, 'p1');
  });
}
