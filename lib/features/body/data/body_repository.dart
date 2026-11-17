import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/daos/body_dao.dart';
import 'package:virya/core/time/day_key.dart';
import 'package:virya/features/body/domain/body_logic.dart';
import 'package:virya/features/body/domain/body_models.dart';

/// Baris database → model, dengan path foto dijadikan absolut.
BodyEntry bodyEntryOf(BodyCheckinRow row, String basePath) {
  final c = row.checkin;
  final measured = <BodyField, double?>{
    BodyField.weightKg: c.weightKg,
    BodyField.bodyFatPct: c.bodyFatPct,
    BodyField.waistCm: c.waistCm,
    BodyField.chestCm: c.chestCm,
    BodyField.armCm: c.armCm,
  };
  return BodyEntry(
    id: c.id,
    day: dayFromKey(c.day)!,
    values: {
      for (final e in measured.entries)
        if (e.value != null) e.key: e.value!,
    },
    note: c.note,
    shots: {
      for (final s in row.photos.map((f) => _shotOf(f, basePath)).nonNulls)
        s.pose: s,
    },
  );
}

/// Null bila nama pose di database tidak dikenal.
BodyShot? _shotOf(BodyPhoto f, String basePath) {
  final pose = BodyPose.parse(f.pose);
  if (pose == null) return null;
  return BodyShot(
    id: f.id,
    pose: pose,
    path: p.join(basePath, p.joinAll(f.filePath.split('/'))),
  );
}

/// Foto disimpan di `photos/body/`, folder privat yang ikut backup dan tidak
/// muncul di galeri.
class BodyRepository {
  final BodyDao _dao;
  final Future<Directory> Function() _baseDir;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  BodyRepository(this._dao, this._baseDir, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// Id check-in pada [day], dibuat bila belum ada.
  Future<String> ensureCheckin(DateTime day) async {
    final key = dayKeyOf(day);
    final found = await _dao.findByDay(key);
    if (found != null) return found.id;
    await _dao.insertCheckin(
      BodyCheckinsCompanion.insert(
        id: _uuid.v4(),
        day: key,
        createdAt: _clock().toUtc(),
      ),
    );
    return (await _dao.findByDay(key))!.id;
  }

  /// Ukuran yang tidak ada di [values] dikosongkan.
  Future<void> saveDetails(
    String checkinId,
    Map<BodyField, double> values,
    String? note,
  ) {
    final trimmed = note?.trim();
    return _dao.updateCheckin(
      checkinId,
      BodyCheckinsCompanion(
        weightKg: Value(values[BodyField.weightKg]),
        bodyFatPct: Value(values[BodyField.bodyFatPct]),
        waistCm: Value(values[BodyField.waistCm]),
        chestCm: Value(values[BodyField.chestCm]),
        armCm: Value(values[BodyField.armCm]),
        note: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
      ),
    );
  }

  /// Salin [sourcePath] ke folder privat dan jadikan foto [pose]. Berkas
  /// sumber dan foto lama dihapus setelah database berhasil diperbarui.
  Future<void> savePhoto({
    required String checkinId,
    required BodyPose pose,
    required String sourcePath,
  }) async {
    final base = (await _baseDir()).path;
    final id = _uuid.v4();
    final rel = bodyPhotoRelPath(checkinId, pose, id);
    final target = File(_abs(base, rel));
    await target.parent.create(recursive: true);
    await File(sourcePath).copy(target.path);
    final BodyPhoto? old;
    try {
      old = await _dao.replacePhoto(
        BodyPhotosCompanion.insert(
          id: id,
          checkinId: checkinId,
          pose: pose.name,
          filePath: rel,
          createdAt: _clock().toUtc(),
        ),
      );
    } catch (_) {
      await _tryDelete(target);
      rethrow;
    }
    if (old != null) await _tryDelete(File(_abs(base, old.filePath)));
    await _tryDelete(File(sourcePath));
  }

  Future<void> deletePhoto(String photoId) async {
    final row = await _dao.findPhoto(photoId);
    if (row == null) return;
    await _dao.deletePhoto(photoId);
    await _tryDelete(File(_abs((await _baseDir()).path, row.filePath)));
  }

  /// Hapus check-in beserta seluruh fotonya.
  Future<void> deleteCheckin(String checkinId) async {
    final base = (await _baseDir()).path;
    final photos = await _dao.photosOf(checkinId);
    await _dao.deleteCheckin(checkinId);
    for (final f in photos) {
      await _tryDelete(File(_abs(base, f.filePath)));
    }
    final dir = Directory(p.join(base, 'photos', 'body', checkinId));
    try {
      if (dir.existsSync()) await dir.delete(recursive: true);
    } on FileSystemException catch (e) {
      debugPrint('Folder check-in gagal dihapus: $e');
    }
  }

  String _abs(String base, String rel) => p.join(base, p.joinAll(rel.split('/')));

  Future<void> _tryDelete(File f) async {
    try {
      if (f.existsSync()) await f.delete();
    } on FileSystemException catch (e) {
      debugPrint('Berkas gagal dihapus: $e');
    }
  }
}
