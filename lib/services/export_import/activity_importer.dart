import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:stravo/core/analytics/elevation.dart';
import 'package:stravo/core/analytics/geo.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/data/activity_finalizer.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/models/track_sample.dart';
import 'package:stravo/services/export_import/fit_decoder.dart';
import 'package:stravo/services/export_import/gpx_codec.dart';
import 'package:stravo/services/export_import/parsed_activity.dart';
import 'package:stravo/services/export_import/strava_archive.dart';
import 'package:stravo/services/export_import/tcx_codec.dart';
import 'package:uuid/uuid.dart';

export 'package:stravo/services/export_import/parsed_activity.dart';

/// Imports GPX / TCX / FIT (optionally .gz) and Strava bulk-export .zip.
class ActivityImporter {
  final AppDatabase db;
  ActivityImporter(this.db);

  /// Default sport when the file does not say.
  static const SportType fallbackSport = SportType.gravelCycling;
  static const int _batch = 2000;

  /// Pure parse layer (no DB, no IO). [fileName] selects the format; content
  /// sniffing is used when the extension is unknown. Throws
  /// [FormatException] for unsupported content.
  static List<ParsedActivity> parseBytes(Uint8List bytes, String fileName) {
    var name = fileName.toLowerCase();
    var data = bytes;
    if (name.endsWith('.gz') ||
        (data.length > 2 && data[0] == 0x1F && data[1] == 0x8B)) {
      data = GZipDecoder().decodeBytes(data);
      if (name.endsWith('.gz')) name = name.substring(0, name.length - 3);
    }
    if (name.endsWith('.zip') ||
        (data.length > 4 && data[0] == 0x50 && data[1] == 0x4B)) {
      final archive = ZipDecoder().decodeBytes(data);
      return [
        for (final e in stravaArchiveEntries(archive))
          ..._parseEntry(e.name, e.bytes, e.meta),
      ];
    }
    if (name.endsWith('.fit') || FitDecoder.looksLikeFit(data)) {
      return FitDecoder().decode(data, sourceName: fileName);
    }
    final text = utf8.decode(data, allowMalformed: true);
    final head = text.length > 2048 ? text.substring(0, 2048) : text;
    if (name.endsWith('.tcx') || head.contains('TrainingCenterDatabase')) {
      return parseTcx(text, sourceName: fileName);
    }
    if (name.endsWith('.gpx') || head.contains('<gpx')) {
      return parseGpx(text, sourceName: fileName);
    }
    throw FormatException('Unsupported file: $fileName');
  }

  static List<ParsedActivity> _parseEntry(
      String name, Uint8List bytes, StravaCsvEntry? meta) {
    try {
      return [
        for (final a in parseBytes(bytes, name))
          a.copyWith(
            title: meta?.name,
            sport: sportFromString(meta?.type),
          ),
      ];
    } on Object {
      return const []; // skip broken files inside an archive
    }
  }

  /// Import a file; returns ids of newly created activities (duplicates by
  /// start time ±60 s are skipped).
  Future<List<String>> importFile(String path,
      {void Function(int done, int total)? onProgress}) async {
    final ids = <String>[];
    final lower = path.toLowerCase();
    if (lower.endsWith('.zip')) {
      final input = InputFileStream(path);
      try {
        final archive = ZipDecoder().decodeStream(input);
        final total = archive.files
            .where((f) => f.isFile && isActivityFileName(f.name.toLowerCase()))
            .length;
        var done = 0;
        for (final e in stravaArchiveEntries(archive)) {
          final parsed = await _entryInIsolate(e.name, e.bytes, e.meta);
          for (final a in parsed) {
            final id = await importParsed(a);
            if (id != null) ids.add(id);
          }
          onProgress?.call(++done, total);
        }
      } finally {
        input.closeSync();
      }
      return ids;
    }
    final bytes = await File(path).readAsBytes();
    final name = p.basename(path);
    final parsed = await _bytesInIsolate(bytes, name);
    for (var i = 0; i < parsed.length; i++) {
      final id = await importParsed(parsed[i]);
      if (id != null) ids.add(id);
      onProgress?.call(i + 1, parsed.length);
    }
    return ids;
  }

  /// Insert one parsed activity + points and finalize it. Returns null when
  /// it has < 2 points or duplicates an existing activity.
  Future<String?> importParsed(ParsedActivity a) async {
    final s = a.samples;
    if (s.length < 2) return null;
    final start = s.first.time;
    final dup = await (db.select(db.activities)
          ..where((t) =>
              t.startTime.isBetweenValues(
                  start.subtract(const Duration(seconds: 60)),
                  start.add(const Duration(seconds: 60))) &
              t.status.equals('discarded').not())
          ..limit(1))
        .get();
    if (dup.isNotEmpty) return null;

    final id = const Uuid().v4();
    final title = a.title ??
        'Impor · ${DateFormat('yyyy-MM-dd HH:mm').format(start.toLocal())}';
    final ele = fillElevation([for (final x in s) x.ele]);
    await db.transaction(() async {
      await db.activitiesDao.insertActivity(ActivitiesCompanion.insert(
        id: id,
        title: title,
        sportType: (a.sport ?? fallbackSport).name,
        status: 'inProgress',
        startTime: start,
        endTime: Value(s.last.time),
        source: const Value('imported'),
        updatedAt: DateTime.now(),
      ));
      for (var b = 0; b < s.length; b += _batch) {
        final end = b + _batch < s.length ? b + _batch : s.length;
        await db.trackPointsDao.insertBatchTrackPoints([
          for (var i = b; i < end; i++)
            TrackPointsCompanion.insert(
              activityId: id,
              sequenceIdx: i,
              timestamp: s[i].time,
              latitude: s[i].lat,
              longitude: s[i].lon,
              altitudeMeters: ele == null ? 0 : ele[i],
              accuracyMeters: s[i].accuracyM ?? 5,
              speedMps: s[i].speedMps ?? _derivedSpeed(s, i),
              surfaceType: Value(s[i].surface.name),
              vibrationRaw: Value(s[i].vibration),
              heartRate: Value(s[i].heartRate),
              cadence: Value(s[i].cadence),
              isPaused: Value(s[i].paused),
            ),
        ]);
      }
    });
    await ActivityFinalizer(db).finalize(id);
    return id;
  }

  static Future<List<ParsedActivity>> _entryInIsolate(
          String name, Uint8List bytes, StravaCsvEntry? meta) =>
      Isolate.run(() => _parseEntry(name, bytes, meta));

  static Future<List<ParsedActivity>> _bytesInIsolate(
          Uint8List bytes, String name) =>
      Isolate.run(() => parseBytes(bytes, name));

  static double _derivedSpeed(List<TrackSample> s, int i) {
    if (i == 0) return 0;
    final a = s[i - 1], b = s[i];
    final dt = b.time.difference(a.time).inMilliseconds / 1000;
    if (dt <= 0) return 0;
    return haversineM(a.lat, a.lon, b.lat, b.lon) / dt;
  }
}

final activityImporterProvider = Provider<ActivityImporter>(
  (ref) => ActivityImporter(ref.watch(databaseProvider)),
);
