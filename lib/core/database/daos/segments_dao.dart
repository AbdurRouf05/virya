import 'package:drift/drift.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/tables/activities_table.dart';
import 'package:virya/core/database/tables/segments_table.dart';
import 'package:virya/core/database/tables/track_points_table.dart';

part 'segments_dao.g.dart';

/// Akses tabel segmen dan upaya (effort) per segmen.
@DriftAccessor(tables: [Segments, SegmentEfforts, Activities, TrackPoints])
class SegmentsDao extends DatabaseAccessor<AppDatabase>
    with _$SegmentsDaoMixin {
  SegmentsDao(super.db);

  /// Satu baris per upaya; segmen tanpa upaya muncul dengan upaya `null`.
  Stream<List<(Segment, SegmentEffort?)>> watchSegmentsWithEfforts() {
    final q = select(segments).join([
      leftOuterJoin(
        segmentEfforts,
        segmentEfforts.segmentId.equalsExp(segments.id),
      ),
    ]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (r.readTable(segments), r.readTableOrNull(segmentEfforts)),
      ],
    );
  }

  /// Upaya sebuah segmen beserta aktivitasnya, tercepat dulu.
  Stream<List<(SegmentEffort, Activity)>> watchEffortsOfSegment(String id) {
    final q = select(segmentEfforts).join([
      innerJoin(activities, activities.id.equalsExp(segmentEfforts.activityId)),
    ])
      ..where(segmentEfforts.segmentId.equals(id))
      ..orderBy([OrderingTerm.asc(segmentEfforts.elapsedS)]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (r.readTable(segmentEfforts), r.readTable(activities)),
      ],
    );
  }

  /// Upaya di dalam satu aktivitas, urut waktu mulai.
  Stream<List<(SegmentEffort, Segment)>> watchEffortsOfActivity(String id) {
    final q = select(segmentEfforts).join([
      innerJoin(segments, segments.id.equalsExp(segmentEfforts.segmentId)),
    ])
      ..where(segmentEfforts.activityId.equals(id))
      ..orderBy([OrderingTerm.asc(segmentEfforts.startedAt)]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (r.readTable(segmentEfforts), r.readTable(segments)),
      ],
    );
  }

  Future<List<Segment>> allSegments() => select(segments).get();

  Future<SegmentEffort?> bestEffort(String segmentId) =>
      (select(segmentEfforts)
            ..where((t) => t.segmentId.equals(segmentId))
            ..orderBy([(t) => OrderingTerm.asc(t.elapsedS)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> insertSegment(SegmentsCompanion s) => into(segments).insert(s);

  /// Upayanya ikut terhapus lewat cascade.
  Future<void> deleteSegment(String id) =>
      (delete(segments)..where((t) => t.id.equals(id))).go();

  Future<void> insertEfforts(List<SegmentEffortsCompanion> rows) =>
      batch((b) => b.insertAll(segmentEfforts, rows));

  /// Mengganti semua upaya satu aktivitas, jadi aman diulang.
  Future<void> replaceActivityEfforts(
    String activityId,
    List<SegmentEffortsCompanion> rows,
  ) => transaction(() async {
    await (delete(segmentEfforts)
          ..where((t) => t.activityId.equals(activityId)))
        .go();
    await insertEfforts(rows);
  });

  /// Aktivitas selesai yang punya titik GPS di dalam kotak ini.
  Future<List<Activity>> completedActivitiesInBox({
    required double minLat,
    required double maxLat,
    required double minLon,
    required double maxLon,
  }) async {
    final q = selectOnly(trackPoints, distinct: true)
      ..addColumns([trackPoints.activityId])
      ..where(
        trackPoints.latitude.isBetweenValues(minLat, maxLat) &
            trackPoints.longitude.isBetweenValues(minLon, maxLon),
      );
    final ids = [
      for (final r in await q.get()) r.read(trackPoints.activityId)!,
    ];
    if (ids.isEmpty) return const [];
    return (select(activities)
          ..where((t) => t.id.isIn(ids) & t.status.equals('completed')))
        .get();
  }
}
