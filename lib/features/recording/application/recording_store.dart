import 'dart:io';

import 'package:drift/drift.dart' show BooleanExpressionOperators, Value;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/data/activity_finalizer.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/location/telemetry_pipeline.dart';
import 'package:virya/core/models/track_sample.dart';
import 'package:virya/features/recording/domain/recording_title.dart';

/// Database/file side of a recording session (create, photo, finish, delete).
class RecordingStore {
  final AppDatabase _db;
  const RecordingStore(this._db);

  /// Inserts a new in-progress activity; returns its id and start time.
  Future<(String, DateTime)> createActivity(SportType sport) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await _db.activitiesDao.insertActivity(ActivitiesCompanion.insert(
      id: id,
      title: defaultRecordingTitle(sport, now),
      sportType: sport.name,
      status: 'inProgress',
      startTime: now,
      gearId: Value(await _defaultGearId(sport)),
      updatedAt: now,
    ));
    return (id, now);
  }

  /// Stored points (as samples) and photo count of an interrupted session.
  Future<(List<TrackSample>, int nextSeq, int photoCount)> loadRecovered(
      String activityId) async {
    final points = await _db.trackPointsDao.getPointsForActivity(activityId);
    final photos =
        await _db.waypointPhotosDao.getPhotosForActivity(activityId);
    return (
      points.map(TrackSample.fromTrackPoint).toList(),
      points.isEmpty ? 0 : points.last.sequenceIdx + 1,
      photos.length,
    );
  }

  Future<int> countPoints(String id) =>
      _db.trackPointsDao.countPointsForActivity(id);

  /// Writes the end time and runs analysis. On failure the activity is still
  /// marked completed (points are safe on disk) so it is not "recovered".
  Future<void> finish(String id, DateTime? endTime) async {
    final db = _db;
    if (endTime != null) {
      await (db.update(db.activities)..where((t) => t.id.equals(id)))
          .write(ActivitiesCompanion(endTime: Value(endTime)));
    }
    try {
      await ActivityFinalizer(db).finalize(id);
    } catch (e) {
      debugPrint('Finalize failed: $e');
      await (db.update(db.activities)..where((t) => t.id.equals(id)))
          .write(const ActivitiesCompanion(status: Value('completed')));
    }
  }

  /// Copies a captured image into app storage and geotags it at the
  /// pipeline's current position.
  Future<void> savePhoto({
    required String activityId,
    required String sourcePath,
    required Directory dir,
    required TelemetryPipeline pipe,
    required bool isFirst,
  }) async {
    final photoId = const Uuid().v4();
    final ext =
        p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final dest = p.join(dir.path, '$photoId$ext');
    await File(sourcePath).copy(dest);
    await _db.waypointPhotosDao.insertPhoto(WaypointPhotosCompanion.insert(
      id: photoId,
      activityId: activityId,
      filePath: dest,
      latitude: pipe.latitude!,
      longitude: pipe.longitude!,
      altitudeMeters: pipe.altitude ?? 0,
      distanceFromStartMeters: pipe.distanceM,
      takenAt: DateTime.now(),
    ));
    if (isFirst) {
      final db = _db;
      await (db.update(db.activities)..where((t) => t.id.equals(activityId)))
          .write(ActivitiesCompanion(primaryPhotoPath: Value(dest)));
    }
  }

  /// Deletes the activity, its points and its photo files.
  Future<void> deleteActivity(String id) async {
    try {
      final photos = await _db.waypointPhotosDao.getPhotosForActivity(id);
      for (final ph in photos) {
        final f = File(ph.filePath);
        if (await f.exists()) await f.delete();
      }
    } catch (_) {}
    await _db.activitiesDao.deleteActivity(id);
  }

  Future<String?> _defaultGearId(SportType sport) async {
    try {
      final db = _db;
      final gears = await (db.select(db.gears)
            ..where((g) => g.isDefault.equals(true) & g.isRetired.equals(false)))
          .get();
      final wantShoes = !sport.isCycling;
      for (final g in gears) {
        final isShoe = g.gearType.toLowerCase().contains('shoe');
        if (isShoe == wantShoes) return g.id;
      }
    } catch (_) {}
    return null;
  }
}
