import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/body/data/body_repository.dart';
import 'package:virya/features/body/domain/body_models.dart';

void main() {
  late AppDatabase db;
  late Directory base;
  late Directory incoming;
  late BodyRepository repo;
  final now = DateTime.utc(2026, 11, 8, 2);
  final today = DateTime(2026, 11, 8);

  setUp(() {
    db = AppDatabase.memory();
    base = Directory.systemTemp.createTempSync('virya_body_');
    incoming = Directory.systemTemp.createTempSync('virya_body_src_');
    repo = BodyRepository(db.bodyDao, () async => base, clock: () => now);
  });

  tearDown(() async {
    await db.close();
    for (final d in [base, incoming]) {
      if (d.existsSync()) d.deleteSync(recursive: true);
    }
  });

  File source(String name, String content) =>
      File(p.join(incoming.path, name))..writeAsStringSync(content);

  File onDisk(String rel) => File(p.joinAll([base.path, ...rel.split('/')]));

  Future<List<BodyPhoto>> photos(String id) => db.bodyDao.photosOf(id);

  Future<BodyCheckin> row(String id) => (db.select(
    db.bodyCheckins,
  )..where((t) => t.id.equals(id))).getSingle();

  group('ensureCheckin', () {
    test('hari yang sama mengembalikan id yang sama', () async {
      final a = await repo.ensureCheckin(today);
      final b = await repo.ensureCheckin(DateTime(2026, 11, 8, 23, 30));
      expect(b, a);
      expect(await db.select(db.bodyCheckins).get(), hasLength(1));
    });

    test('hari berbeda jadi check-in berbeda, createdAt dari clock', () async {
      final a = await repo.ensureCheckin(today);
      final b = await repo.ensureCheckin(DateTime(2026, 11, 9));
      expect(b, isNot(a));
      final r = await row(a);
      expect(r.day, '2026-11-08');
      expect(r.createdAt.toUtc(), now);
    });
  });

  group('savePhoto', () {
    test('path relatif di bawah photos/body, berkas disalin, sumber hilang', () async {
      final id = await repo.ensureCheckin(today);
      final src = source('a.jpg', 'isi-a');

      await repo.savePhoto(
        checkinId: id,
        pose: BodyPose.front,
        sourcePath: src.path,
      );

      final saved = (await photos(id)).single;
      expect(saved.pose, 'front');
      expect(saved.filePath, startsWith('photos/body/$id/front_'));
      expect(saved.filePath, endsWith('.jpg'));
      expect(saved.filePath, isNot(contains(r'\')));
      expect(p.isAbsolute(saved.filePath), isFalse);
      expect(onDisk(saved.filePath).readAsStringSync(), 'isi-a');
      expect(src.existsSync(), isFalse);
    });

    test('foto ulang menghapus berkas lama dan tetap satu baris', () async {
      final id = await repo.ensureCheckin(today);
      await repo.savePhoto(
        checkinId: id,
        pose: BodyPose.front,
        sourcePath: source('a.jpg', 'lama').path,
      );
      final old = (await photos(id)).single;

      await repo.savePhoto(
        checkinId: id,
        pose: BodyPose.front,
        sourcePath: source('b.jpg', 'baru').path,
      );

      final now = (await photos(id)).single;
      expect(now.id, isNot(old.id));
      expect(now.filePath, isNot(old.filePath));
      expect(onDisk(old.filePath).existsSync(), isFalse);
      expect(onDisk(now.filePath).readAsStringSync(), 'baru');
    });

    test('pose lain tidak terganggu', () async {
      final id = await repo.ensureCheckin(today);
      await repo.savePhoto(
        checkinId: id,
        pose: BodyPose.front,
        sourcePath: source('a.jpg', 'depan').path,
      );
      await repo.savePhoto(
        checkinId: id,
        pose: BodyPose.back,
        sourcePath: source('b.jpg', 'belakang').path,
      );

      final all = await photos(id);
      expect(all.map((f) => f.pose), unorderedEquals(['front', 'back']));
      for (final f in all) {
        expect(onDisk(f.filePath).existsSync(), isTrue);
      }
    });

    test('sumber tidak ada → gagal dan tidak meninggalkan baris', () async {
      final id = await repo.ensureCheckin(today);
      await expectLater(
        repo.savePhoto(
          checkinId: id,
          pose: BodyPose.front,
          sourcePath: p.join(incoming.path, 'tidak_ada.jpg'),
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(await photos(id), isEmpty);
    });

    test('check-in tidak ada → salinan dibersihkan, sumber tetap', () async {
      final src = source('a.jpg', 'isi');
      await expectLater(
        repo.savePhoto(
          checkinId: 'tidak-ada',
          pose: BodyPose.front,
          sourcePath: src.path,
        ),
        throwsA(anything),
      );
      expect(await db.select(db.bodyPhotos).get(), isEmpty);
      expect(src.existsSync(), isTrue);
      final folder = Directory(p.join(base.path, 'photos', 'body', 'tidak-ada'));
      expect(folder.listSync(), isEmpty);
    });
  });

  group('saveDetails', () {
    test('mengisi ukuran dan merapikan catatan', () async {
      final id = await repo.ensureCheckin(today);
      await repo.saveDetails(id, {
        BodyField.weightKg: 70.5,
        BodyField.waistCm: 80,
      }, '  segar  ');

      final r = await row(id);
      expect(r.weightKg, 70.5);
      expect(r.waistCm, 80);
      expect(r.bodyFatPct, isNull);
      expect(r.note, 'segar');
    });

    test('ukuran yang tidak dikirim dikosongkan', () async {
      final id = await repo.ensureCheckin(today);
      await repo.saveDetails(id, {
        BodyField.weightKg: 70,
        BodyField.chestCm: 95,
        BodyField.armCm: 33,
        BodyField.bodyFatPct: 18,
      }, 'catatan');

      await repo.saveDetails(id, {BodyField.armCm: 34}, null);

      final r = await row(id);
      expect(r.weightKg, isNull);
      expect(r.chestCm, isNull);
      expect(r.bodyFatPct, isNull);
      expect(r.armCm, 34);
      expect(r.note, isNull);
    });

    test('catatan kosong jadi null', () async {
      final id = await repo.ensureCheckin(today);
      await repo.saveDetails(id, const {}, '   ');
      expect((await row(id)).note, isNull);
    });

    test('tidak menyentuh hari dan foto', () async {
      final id = await repo.ensureCheckin(today);
      await repo.savePhoto(
        checkinId: id,
        pose: BodyPose.side,
        sourcePath: source('a.jpg', 'x').path,
      );
      await repo.saveDetails(id, {BodyField.weightKg: 70}, null);
      expect((await row(id)).day, '2026-11-08');
      expect(await photos(id), hasLength(1));
    });
  });

  test('deletePhoto menghapus berkas dan baris', () async {
    final id = await repo.ensureCheckin(today);
    await repo.savePhoto(
      checkinId: id,
      pose: BodyPose.front,
      sourcePath: source('a.jpg', 'x').path,
    );
    final saved = (await photos(id)).single;

    await repo.deletePhoto(saved.id);

    expect(await photos(id), isEmpty);
    expect(onDisk(saved.filePath).existsSync(), isFalse);
    expect(await db.bodyDao.findByDay('2026-11-08'), isNotNull);
  });

  test('deletePhoto id tak dikenal tidak melempar', () async {
    await repo.deletePhoto('tidak-ada');
  });

  test('deleteCheckin menghapus baris, berkas, dan folder', () async {
    final a = await repo.ensureCheckin(today);
    final b = await repo.ensureCheckin(DateTime(2026, 11, 1));
    for (final pose in BodyPose.values) {
      await repo.savePhoto(
        checkinId: a,
        pose: pose,
        sourcePath: source('${pose.name}.jpg', 'x').path,
      );
    }
    await repo.savePhoto(
      checkinId: b,
      pose: BodyPose.front,
      sourcePath: source('lain.jpg', 'y').path,
    );
    final kept = (await photos(b)).single;

    await repo.deleteCheckin(a);

    expect(await db.bodyDao.findByDay('2026-11-08'), isNull);
    expect(await photos(a), isEmpty);
    expect(
      Directory(p.join(base.path, 'photos', 'body', a)).existsSync(),
      isFalse,
    );
    expect(onDisk(kept.filePath).existsSync(), isTrue);
  });

  group('bodyEntryOf', () {
    final checkin = BodyCheckin(
      id: 'c1',
      day: '2026-11-08',
      weightKg: 70,
      bodyFatPct: null,
      waistCm: 80,
      chestCm: null,
      armCm: null,
      note: 'hai',
      createdAt: now,
    );

    BodyPhoto photo(String id, String pose) => BodyPhoto(
      id: id,
      checkinId: 'c1',
      pose: pose,
      filePath: 'photos/body/c1/${pose}_$id.jpg',
      createdAt: now,
    );

    test('path absolut, hari lokal, dan hanya ukuran yang terisi', () {
      final entry = bodyEntryOf((
        checkin: checkin,
        photos: [photo('p1', 'front')],
      ), base.path);

      expect(entry.id, 'c1');
      expect(entry.day, DateTime(2026, 11, 8));
      expect(entry.note, 'hai');
      expect(entry.weightKg, 70);
      expect(entry.values.keys, unorderedEquals([
        BodyField.weightKg,
        BodyField.waistCm,
      ]));
      expect(
        entry.shots[BodyPose.front]!.path,
        p.join(base.path, 'photos', 'body', 'c1', 'front_p1.jpg'),
      );
      expect(entry.shots[BodyPose.front]!.id, 'p1');
    });

    test('pose tak dikenal dilewati', () {
      final entry = bodyEntryOf((
        checkin: checkin,
        photos: [photo('p1', 'atas'), photo('p2', 'back')],
      ), base.path);
      expect(entry.shots.keys, [BodyPose.back]);
    });

    test('path tetap benar pada folder dasar lain (pulihkan backup)', () {
      final a = bodyEntryOf((
        checkin: checkin,
        photos: [photo('p1', 'side')],
      ), p.join('x', 'lama'));
      final b = bodyEntryOf((
        checkin: checkin,
        photos: [photo('p1', 'side')],
      ), p.join('y', 'baru'));
      expect(
        p.relative(a.shots[BodyPose.side]!.path, from: p.join('x', 'lama')),
        p.relative(b.shots[BodyPose.side]!.path, from: p.join('y', 'baru')),
      );
    });
  });

  test('bodyEntries dari DAO memakai kolom nullable apa adanya', () async {
    await db.bodyDao.insertCheckin(
      BodyCheckinsCompanion.insert(
        id: 'c',
        day: '2026-11-08',
        createdAt: now,
        bodyFatPct: const Value(15),
      ),
    );
    final rows = await db.bodyDao.watchAll().first;
    final entry = bodyEntryOf(rows.single, base.path);
    expect(entry.weightKg, isNull);
    expect(entry.values, {BodyField.bodyFatPct: 15});
  });
}
