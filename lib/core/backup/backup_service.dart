import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:stravo/core/database/app_database.dart';

/// Full local backup: zip of the SQLite file, `photos/` and `manifest.json`.
///
/// Restore is two-phase because the DB file is open while the app runs:
/// [restore] validates and stages into `restore_pending/`, then
/// [applyPendingRestore] (call in `main()` BEFORE opening the DB) swaps the
/// staged files in. The replaced files are kept in `pre_restore/`.
class BackupService {
  static const String dbFileName = 'stravo_local.sqlite';
  static const String photosDir = 'photos';
  static const String manifestName = 'manifest.json';
  static const String pendingDir = 'restore_pending';
  static const String readyMarker = '.ready';
  static const String previousDir = 'pre_restore';
  static const int formatVersion = 1;

  final AppDatabase db;

  /// Override of the app documents directory (tests).
  final Directory? baseDir;

  BackupService(this.db, {this.baseDir});

  Future<Directory> _base() async =>
      baseDir ?? await getApplicationDocumentsDirectory();

  /// Writes `backups/stravo_backup_<timestamp>.zip` and returns it.
  Future<File> createBackup() async {
    final base = await _base();
    try {
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    } catch (_) {
      // Not in WAL mode / not supported: copy as is.
    }
    final dbFile = File(p.join(base.path, dbFileName));
    if (!dbFile.existsSync()) {
      throw StateError('Database file not found: ${dbFile.path}');
    }
    final now = DateTime.now();
    final outDir = Directory(p.join(base.path, 'backups'));
    await outDir.create(recursive: true);
    final out = File(p.join(outDir.path, 'stravo_backup_${_stamp(now)}.zip'));

    // Snapshot the DB first so the zip never streams a file being written.
    final snapshot = File(p.join(outDir.path, '.db_snapshot'));
    await dbFile.copy(snapshot.path);
    final enc = ZipFileEncoder();
    try {
      enc.create(out.path);
      final manifest = {
        'app': 'stravo',
        'version': formatVersion,
        'createdAt': now.toUtc().toIso8601String(),
        'schemaVersion': db.schemaVersion,
        'dbFile': dbFileName,
      };
      enc.addArchiveFile(ArchiveFile.string(
          manifestName, const JsonEncoder.withIndent('  ').convert(manifest)));
      await enc.addFile(snapshot, dbFileName);
      final photos = Directory(p.join(base.path, photosDir));
      if (photos.existsSync()) {
        for (final f in photos.listSync(recursive: true)) {
          if (f is! File) continue;
          final rel = p.relative(f.path, from: base.path);
          await enc.addFile(f, p.posix.joinAll(p.split(rel)));
        }
      }
    } finally {
      await enc.close();
      if (snapshot.existsSync()) await snapshot.delete();
    }
    return out;
  }

  /// Validate [zipPath] and stage it for [applyPendingRestore]. Throws
  /// [FormatException] when the archive is not a valid Stravo backup.
  Future<void> restore(String zipPath) async {
    final base = await _base();
    final input = InputFileStream(zipPath);
    final tmp = Directory(p.join(base.path, '$pendingDir.tmp'));
    try {
      final archive = ZipDecoder().decodeStream(input);
      final manifestFile = archive.find(manifestName);
      if (manifestFile == null) {
        throw const FormatException('Backup: manifest.json missing');
      }
      final manifest = jsonDecode(utf8.decode(manifestFile.readBytes()!));
      if (manifest is! Map || manifest['app'] != 'stravo') {
        throw const FormatException('Backup: not a Stravo backup');
      }
      final schema = manifest['schemaVersion'];
      if (schema is! int || schema > db.schemaVersion) {
        throw const FormatException('Backup: newer schema than this app');
      }
      final dbEntry = archive.find(dbFileName);
      final dbBytes = dbEntry?.readBytes();
      if (dbBytes == null || !_isSqlite(dbBytes)) {
        throw const FormatException('Backup: database missing or invalid');
      }

      if (tmp.existsSync()) await tmp.delete(recursive: true);
      await tmp.create(recursive: true);
      for (final f in archive.files) {
        if (!f.isFile) continue;
        final rel = p.posix.normalize(f.name.replaceAll('\\', '/'));
        final allowed = rel == manifestName ||
            rel == dbFileName ||
            rel.startsWith('$photosDir/');
        if (!allowed || rel.contains('..') || p.posix.isAbsolute(rel)) {
          continue;
        }
        final target = File(p.joinAll([tmp.path, ...rel.split('/')]));
        await target.parent.create(recursive: true);
        final bytes = f.readBytes();
        if (bytes != null) await target.writeAsBytes(bytes, flush: true);
      }
      await File(p.join(tmp.path, readyMarker)).writeAsString('1', flush: true);
      final pending = Directory(p.join(base.path, pendingDir));
      if (pending.existsSync()) await pending.delete(recursive: true);
      await tmp.rename(pending.path);
    } finally {
      input.closeSync();
      if (tmp.existsSync()) await tmp.delete(recursive: true);
    }
  }

  /// Whether a staged restore is waiting for the next app start.
  static Future<bool> hasPendingRestore({Directory? baseDir}) async {
    final base = baseDir ?? await getApplicationDocumentsDirectory();
    return File(p.join(base.path, pendingDir, readyMarker)).existsSync();
  }

  /// Swap staged files in. Must run before the database is opened.
  /// Returns true when a restore was applied.
  static Future<bool> applyPendingRestore({Directory? baseDir}) async {
    final base = baseDir ?? await getApplicationDocumentsDirectory();
    final pending = Directory(p.join(base.path, pendingDir));
    if (!File(p.join(pending.path, readyMarker)).existsSync()) return false;
    final stagedDb = File(p.join(pending.path, dbFileName));
    if (!stagedDb.existsSync()) {
      await pending.delete(recursive: true);
      return false;
    }
    final prev = Directory(p.join(base.path, previousDir));
    if (prev.existsSync()) await prev.delete(recursive: true);
    await prev.create(recursive: true);

    // Database (+ WAL side files).
    final live = File(p.join(base.path, dbFileName));
    if (live.existsSync()) {
      await live.rename(p.join(prev.path, dbFileName));
    }
    for (final suffix in ['-wal', '-shm', '-journal']) {
      final side = File('${live.path}$suffix');
      if (side.existsSync()) await side.delete();
    }
    await stagedDb.rename(live.path);

    // Photos.
    final livePhotos = Directory(p.join(base.path, photosDir));
    final stagedPhotos = Directory(p.join(pending.path, photosDir));
    if (livePhotos.existsSync()) {
      await livePhotos.rename(p.join(prev.path, photosDir));
    }
    if (stagedPhotos.existsSync()) {
      await stagedPhotos.rename(livePhotos.path);
    }
    await pending.delete(recursive: true);
    return true;
  }

  static bool _isSqlite(Uint8List b) {
    const magic = 'SQLite format 3';
    if (b.length < 16) return false;
    for (var i = 0; i < magic.length; i++) {
      if (b[i] != magic.codeUnitAt(i)) return false;
    }
    return b[15] == 0;
  }

  static String _stamp(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}${two(t.month)}${two(t.day)}_'
        '${two(t.hour)}${two(t.minute)}${two(t.second)}';
  }
}

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider)),
);
