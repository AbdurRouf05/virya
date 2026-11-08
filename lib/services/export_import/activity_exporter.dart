import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/models/track_sample.dart';
import 'package:stravo/services/export_import/gpx_codec.dart';
import 'package:stravo/services/export_import/tcx_codec.dart';

/// Writes activities as GPX 1.1 / TCX v2 into `app documents/exports/`.
class ActivityExporter {
  final AppDatabase db;

  /// Override of the base directory (tests); defaults to app documents.
  final Directory? baseDir;

  ActivityExporter(this.db, {this.baseDir});

  Future<File> exportGpx(String activityId) => _export(activityId, 'gpx');
  Future<File> exportTcx(String activityId) => _export(activityId, 'tcx');

  Future<File> _export(String activityId, String ext) async {
    final activity = await db.activitiesDao.getActivityById(activityId);
    if (activity == null) {
      throw StateError('Activity $activityId not found');
    }
    final points = await db.trackPointsDao.getPointsForActivity(activityId);
    final samples = points.map(TrackSample.fromTrackPoint).toList();
    final sport = SportType.values.firstWhere(
      (s) => s.name == activity.sportType,
      orElse: () => SportType.gravelCycling,
    );
    final content = ext == 'gpx'
        ? buildGpx(
            title: activity.title,
            sport: sport,
            samples: samples,
            description: activity.description,
          )
        : buildTcx(title: activity.title, sport: sport, samples: samples);
    final base = baseDir ?? await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'exports'));
    await dir.create(recursive: true);
    final file = File(p.join(dir.path,
        '${exportFileStem(activity.title, activity.startTime)}.$ext'));
    await file.writeAsString(content, flush: true);
    return file;
  }
}

/// Filesystem-safe name: `title_yyyyMMdd_HHmm`.
String exportFileStem(String title, DateTime start) {
  var t = title
      .replaceAll(RegExp(r'[^A-Za-z0-9 _\-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '_');
  if (t.length > 60) t = t.substring(0, 60);
  if (t.isEmpty) t = 'stravo';
  final l = start.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t}_${l.year}${two(l.month)}${two(l.day)}_${two(l.hour)}${two(l.minute)}';
}

final activityExporterProvider = Provider<ActivityExporter>(
  (ref) => ActivityExporter(ref.watch(databaseProvider)),
);
