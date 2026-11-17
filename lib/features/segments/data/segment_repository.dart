import 'dart:isolate';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/daos/segments_dao.dart';
import 'package:virya/core/models/track_sample.dart';
import 'package:virya/features/segments/domain/route_measure.dart';
import 'package:virya/features/segments/domain/segment_codec.dart';
import 'package:virya/features/segments/domain/segment_matcher.dart';
import 'package:virya/features/segments/domain/segment_models.dart';
import 'package:virya/features/segments/domain/segment_path.dart';

typedef _Polyline = List<(double, double)>;

List<List<SegmentEffortMatch>> _matchAll(
  List<_Polyline> polylines,
  List<TrackSample> samples,
) => [
  for (final line in polylines)
    const SegmentMatcher().findEfforts(line, samples),
];

/// Di isolate terpisah, karena rute panjang bisa punya puluhan ribu titik.
Future<List<List<SegmentEffortMatch>>> _matchInBackground(
  List<_Polyline> polylines,
  List<TrackSample> samples,
) => Isolate.run(() => _matchAll(polylines, samples));

SportType _sportOf(String name) =>
    SportType.values.asNameMap()[name] ?? SportType.gravelCycling;

/// Membuat segmen, mencari upayanya, dan menyiapkan ghost untuk perekaman.
class SegmentRepository {
  final AppDatabase _db;
  SegmentRepository(this._db);

  SegmentsDao get _dao => _db.segmentsDao;

  Stream<List<SegmentSummary>> watchSummaries() =>
      _dao.watchSegmentsWithEfforts().map(_summaries);

  List<SegmentSummary> _summaries(List<(Segment, SegmentEffort?)> rows) {
    final segments = <String, Segment>{};
    final efforts = <String, List<SegmentEffort>>{};
    for (final (s, e) in rows) {
      segments[s.id] = s;
      final list = efforts.putIfAbsent(s.id, () => []);
      if (e != null) list.add(e);
    }
    final out = [
      for (final s in segments.values)
        _summary(s, efforts[s.id] ?? const <SegmentEffort>[]),
    ];
    out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  SegmentSummary _summary(Segment s, List<SegmentEffort> efforts) {
    int? best;
    DateTime? last;
    for (final e in efforts) {
      if (best == null || e.elapsedS < best) best = e.elapsedS;
      if (last == null || e.startedAt.isAfter(last)) last = e.startedAt;
    }
    return SegmentSummary(
      id: s.id,
      name: s.name,
      polyline: decodePolyline(s.polylineJson),
      distanceM: s.distanceM,
      bestS: best,
      effortCount: efforts.length,
      lastEffortAt: last,
    );
  }

  Stream<List<SegmentEffortRow>> watchEfforts(String segmentId) =>
      _dao.watchEffortsOfSegment(segmentId).map((rows) {
        return [
          for (final (i, (e, a)) in rows.indexed)
            SegmentEffortRow(
              activityId: a.id,
              activityTitle: a.title,
              startedAt: e.startedAt,
              elapsedS: e.elapsedS,
              isBest: i == 0,
            ),
        ];
      });

  Stream<List<ActivitySegmentRow>> watchActivitySegments(String activityId) =>
      _dao.watchEffortsOfActivity(activityId).asyncMap((rows) async {
        final out = <ActivitySegmentRow>[];
        for (final (e, s) in rows) {
          final best = await _dao.bestEffort(s.id);
          out.add(
            ActivitySegmentRow(
              segmentId: s.id,
              segmentName: s.name,
              distanceM: s.distanceM,
              elapsedS: e.elapsedS,
              isBest: best != null && e.elapsedS <= best.elapsedS,
            ),
          );
        }
        return out;
      });

  Future<void> delete(String segmentId) => _dao.deleteSegment(segmentId);

  /// Menyimpan segmen dari potongan rute, lalu mencari upaya di riwayat.
  /// Mengembalikan id segmen dan jumlah upaya yang ditemukan.
  Future<(String, int)> create({
    required String name,
    required List<(double lat, double lon)> polyline,
    required String sportType,
  }) async {
    final path = SegmentPath(polyline);
    final id = const Uuid().v4();
    await _dao.insertSegment(
      SegmentsCompanion.insert(
        id: id,
        name: name.trim(),
        sportType: Value(sportType),
        polylineJson: encodePolyline(polyline),
        distanceM: path.lengthM,
        startLat: polyline.first.$1,
        startLon: polyline.first.$2,
        endLat: polyline.last.$1,
        endLon: polyline.last.$2,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    return (id, await _backfill(id, polyline, sportType));
  }

  Future<int> _backfill(String id, _Polyline polyline, String sportType) async {
    final start = SegmentBounds.of([polyline.first]);
    final dLat = SegmentBounds.latMargin(60);
    final candidates = await _dao.completedActivitiesInBox(
      minLat: start.minLat - dLat,
      maxLat: start.maxLat + dLat,
      minLon: start.minLon - dLat * 3,
      maxLon: start.maxLon + dLat * 3,
    );
    final rows = <SegmentEffortsCompanion>[];
    for (final a in candidates) {
      if (!segmentAllowsSport(sportType, _sportOf(a.sportType))) continue;
      final samples = await _samples(a.id);
      final found = await _matchInBackground([polyline], samples);
      rows.addAll([for (final m in found.single) _row(id, a.id, m)]);
    }
    await _dao.insertEfforts(rows);
    return rows.length;
  }

  Future<List<TrackSample>> _samples(String activityId) async {
    final points = await _db.trackPointsDao.getPointsForActivity(activityId);
    return points.map(TrackSample.fromTrackPoint).toList();
  }

  SegmentEffortsCompanion _row(
    String segmentId,
    String activityId,
    SegmentEffortMatch m,
  ) => SegmentEffortsCompanion.insert(
    id: const Uuid().v4(),
    segmentId: segmentId,
    activityId: activityId,
    elapsedS: m.elapsedS,
    startedAt: m.startedAt,
    progressJson: Value(encodeMarks(m.progressS)),
  );

  /// Mencari ulang upaya satu aktivitas. Aman diulang.
  Future<void> syncActivity(
    String activityId,
    List<TrackSample> samples,
    SportType sport,
  ) async {
    final rows = <SegmentEffortsCompanion>[];
    final route = RouteMeasure.fromSamples(samples);
    if (route.points.length >= 2) {
      final area = SegmentBounds.of(route.points);
      final targets = <(String, _Polyline)>[];
      for (final s in await _dao.allSegments()) {
        if (!segmentAllowsSport(s.sportType, sport)) continue;
        final line = decodePolyline(s.polylineJson);
        if (line.length < 2) continue;
        if (SegmentBounds.of(line).overlaps(area, 30)) targets.add((s.id, line));
      }
      if (targets.isNotEmpty) {
        final found = await _matchInBackground([
          for (final (_, l) in targets) l,
        ], samples);
        for (final (i, matches) in found.indexed) {
          rows.addAll([
            for (final m in matches) _row(targets[i].$1, activityId, m),
          ]);
        }
      }
    }
    await _dao.replaceActivityEfforts(activityId, rows);
  }

  /// Segmen untuk olahraga ini, masing-masing dengan ghost tercepatnya.
  Future<List<LiveSegmentSeed>> liveSeeds(SportType sport) async {
    final out = <LiveSegmentSeed>[];
    for (final s in await _dao.allSegments()) {
      if (!segmentAllowsSport(s.sportType, sport)) continue;
      final best = await _dao.bestEffort(s.id);
      final marks = best == null ? null : decodeMarks(best.progressJson);
      out.add(
        LiveSegmentSeed(
          id: s.id,
          name: s.name,
          polyline: decodePolyline(s.polylineJson),
          ghostMarksS: marks == null || marks.isEmpty ? null : marks,
          ghostTimeS: best?.elapsedS,
        ),
      );
    }
    return out;
  }
}

/// Dipasang ke `ActivityFinalizer.afterFinalize` di `main.dart`, supaya
/// aktivitas hasil rekam, impor, dan hitung ulang semuanya tercocokkan.
Future<void> syncSegmentsAfterFinalize(
  AppDatabase db,
  String activityId,
  List<TrackSample> samples,
  SportType sport,
) async {
  try {
    await SegmentRepository(db).syncActivity(activityId, samples, sport);
  } catch (e) {
    debugPrint('Sinkron segmen gagal: $e');
  }
}
