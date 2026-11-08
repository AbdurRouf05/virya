import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stravo/core/backup/backup_service.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/services/export_import/activity_exporter.dart';
import 'package:stravo/services/export_import/activity_importer.dart';
import 'package:stravo/services/export_import/gpx_codec.dart';
import 'package:stravo/services/export_import/tcx_codec.dart';

import 'codecs_test.dart' show sampleTrack;

void main() {
  late AppDatabase db;
  late Directory tmp;

  setUp(() {
    db = AppDatabase.memory();
    tmp = Directory.systemTemp.createTempSync('stravo_io_');
  });
  tearDown(() async {
    await db.close();
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  test('import GPX, finalize, dedupe, export round trip', () async {
    final track = sampleTrack(300);
    final f = File(p.join(tmp.path, 'ride.gpx'))
      ..writeAsStringSync(buildGpx(
          title: 'Gowes', sport: SportType.gravelCycling, samples: track));
    final importer = ActivityImporter(db);
    final ids = await importer.importFile(f.path);
    expect(ids, hasLength(1));

    final act = (await db.activitiesDao.getActivityById(ids.single))!;
    expect(act.title, 'Gowes');
    expect(act.source, 'imported');
    expect(act.sportType, SportType.gravelCycling.name);
    expect(act.status, 'completed');
    expect(await db.trackPointsDao.countPointsForActivity(act.id), 300);

    // Same start time ±60 s → skipped.
    expect(await importer.importFile(f.path), isEmpty);

    final exporter = ActivityExporter(db, baseDir: tmp);
    final gpx = await exporter.exportGpx(act.id);
    expect(p.basename(p.dirname(gpx.path)), 'exports');
    final back = parseGpx(gpx.readAsStringSync()).single;
    expect(back.samples, hasLength(300));
    expect(back.samples.first.time, track.first.time);
    expect(back.samples.last.ele!, closeTo(track.last.ele!, 0.1));
    final tcx = await exporter.exportTcx(act.id);
    expect(parseTcx(tcx.readAsStringSync()).single.samples, hasLength(300));
  });

  test('untitled import gets default title', () async {
    final xml = buildGpx(
            title: 'x', sport: SportType.roadRunning, samples: sampleTrack(20))
        .replaceAll('<name>x</name>', '');
    final a = ActivityImporter.parseBytes(
            Uint8List.fromList(utf8.encode(xml)), 'a.gpx')
        .single;
    final id = await ActivityImporter(db).importParsed(a);
    final act = (await db.activitiesDao.getActivityById(id!))!;
    expect(act.title, startsWith('Impor · 2026-05-03'));
  });

  group('BackupService', () {
    final sqliteHeader = [...'SQLite format 3'.codeUnits, 0];

    test('create → restore → apply swaps files', () async {
      final dbFile = File(p.join(tmp.path, BackupService.dbFileName))
        ..writeAsBytesSync([...sqliteHeader, 1, 2, 3]);
      Directory(p.join(tmp.path, 'photos', 'a')).createSync(recursive: true);
      File(p.join(tmp.path, 'photos', 'a', 'x.jpg')).writeAsBytesSync([9, 9]);

      final svc = BackupService(db, baseDir: tmp);
      final zip = await svc.createBackup();
      expect(zip.existsSync(), isTrue);
      final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
      final manifest = jsonDecode(
          utf8.decode(archive.find('manifest.json')!.readBytes()!)) as Map;
      expect(manifest['schemaVersion'], db.schemaVersion);
      expect(archive.find('photos/a/x.jpg'), isNotNull);

      // Mutate live data, then restore the backup.
      dbFile.writeAsBytesSync([...sqliteHeader, 7, 7]);
      File(p.join(tmp.path, 'photos', 'a', 'x.jpg')).deleteSync();
      File('${dbFile.path}-wal').writeAsBytesSync([1]);

      await svc.restore(zip.path);
      expect(await BackupService.hasPendingRestore(baseDir: tmp), isTrue);
      expect(await BackupService.applyPendingRestore(baseDir: tmp), isTrue);

      expect(dbFile.readAsBytesSync(), [...sqliteHeader, 1, 2, 3]);
      expect(File('${dbFile.path}-wal').existsSync(), isFalse);
      expect(File(p.join(tmp.path, 'photos', 'a', 'x.jpg')).readAsBytesSync(),
          [9, 9]);
      expect(
          File(p.join(tmp.path, 'pre_restore', BackupService.dbFileName))
              .readAsBytesSync(),
          [...sqliteHeader, 7, 7]);
      expect(Directory(p.join(tmp.path, 'restore_pending')).existsSync(),
          isFalse);
      expect(await BackupService.applyPendingRestore(baseDir: tmp), isFalse);
    });

    test('restore rejects invalid archives', () async {
      final svc = BackupService(db, baseDir: tmp);
      Future<void> expectRejected(Archive a) async {
        final f = File(p.join(tmp.path, 'bad.zip'))
          ..writeAsBytesSync(ZipEncoder().encodeBytes(a));
        await expectLater(svc.restore(f.path), throwsFormatException);
        expect(await BackupService.hasPendingRestore(baseDir: tmp), isFalse);
      }

      await expectRejected(Archive()
        ..addFile(ArchiveFile.bytes(BackupService.dbFileName, sqliteHeader)));
      await expectRejected(Archive()
        ..addFile(ArchiveFile.string('manifest.json',
            jsonEncode({'app': 'stravo', 'schemaVersion': 999})))
        ..addFile(ArchiveFile.bytes(BackupService.dbFileName, sqliteHeader)));
      await expectRejected(Archive()
        ..addFile(ArchiveFile.string('manifest.json',
            jsonEncode({'app': 'stravo', 'schemaVersion': 1})))
        ..addFile(
            ArchiveFile.string(BackupService.dbFileName, 'not a database')));
    });
  });
}
