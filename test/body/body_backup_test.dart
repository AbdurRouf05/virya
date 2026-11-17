import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:virya/core/backup/backup_service.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/body/data/body_repository.dart';
import 'package:virya/features/body/domain/body_models.dart';

/// Foto tubuh tinggal di `photos/body/`, jadi harus ikut backup dan pulih di
/// lokasi yang sama dengan path relatif di database.
void main() {
  late AppDatabase db;
  late Directory base;

  setUp(() {
    db = AppDatabase.memory();
    base = Directory.systemTemp.createTempSync('virya_body_bak_');
    File(p.join(base.path, BackupService.dbFileName)).writeAsBytesSync([
      ...utf8.encode('SQLite format 3'),
      0,
      ...List.filled(84, 0),
    ]);
  });

  tearDown(() async {
    await db.close();
    if (base.existsSync()) base.deleteSync(recursive: true);
  });

  Future<BodyPhoto> savedPhoto() async {
    final repo = BodyRepository(db.bodyDao, () async => base);
    final id = await repo.ensureCheckin(DateTime(2026, 11, 8));
    final src = File(p.join(base.path, 'capture.jpg'))
      ..writeAsStringSync('isi-foto');
    await repo.savePhoto(
      checkinId: id,
      pose: BodyPose.front,
      sourcePath: src.path,
    );
    return (await db.bodyDao.photosOf(id)).single;
  }

  test('foto tubuh masuk zip backup dengan path relatif yang sama', () async {
    final photo = await savedPhoto();

    final zip = await BackupService(db, baseDir: base).createBackup();

    final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
    final entry = archive.find(photo.filePath);
    expect(entry, isNotNull);
    expect(utf8.decode(entry!.readBytes()!), 'isi-foto');
  });

  test('foto tubuh kembali ke lokasinya setelah dipulihkan', () async {
    final photo = await savedPhoto();
    final service = BackupService(db, baseDir: base);
    final zip = await service.createBackup();
    final target = File(p.joinAll([base.path, ...photo.filePath.split('/')]));
    target.deleteSync();

    await service.restore(zip.path);
    expect(await BackupService.applyPendingRestore(baseDir: base), isTrue);

    expect(target.readAsStringSync(), 'isi-foto');
  });
}
