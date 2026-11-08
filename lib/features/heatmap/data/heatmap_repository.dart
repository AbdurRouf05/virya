import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/heatmap/domain/heatmap_builder.dart';

class HeatmapRepository {
  HeatmapRepository(this._db);

  final AppDatabase _db;

  /// Semua jalur GPS dari aktivitas selesai. Dibaca per aktivitas dan langsung
  /// diringkas ke [Float64List], supaya riwayat panjang tidak memakan memori.
  Future<List<HeatmapTrack>> loadTracks() async {
    final activities = await _db.activitiesDao.getCompletedActivities();
    final tracks = <HeatmapTrack>[];
    for (final a in activities) {
      final category = categoryOf(sportFromName(a.sportType));
      if (category == SportCategory.strength) continue;
      final latLon = await _latLon(a.id);
      if (latLon.length >= 4) tracks.add(HeatmapTrack(category, latLon));
    }
    return tracks;
  }

  Future<Float64List> _latLon(String activityId) async {
    final t = _db.trackPoints;
    final query = _db.selectOnly(t)
      ..addColumns([t.latitude, t.longitude])
      ..where(t.activityId.equals(activityId) & t.isPaused.equals(false))
      ..orderBy([OrderingTerm.asc(t.sequenceIdx)]);
    final rows = await query.get();
    final out = Float64List(rows.length * 2);
    for (var i = 0; i < rows.length; i++) {
      out[i * 2] = rows[i].read(t.latitude)!;
      out[i * 2 + 1] = rows[i].read(t.longitude)!;
    }
    return out;
  }
}

final heatmapRepositoryProvider = Provider<HeatmapRepository>(
  (ref) => HeatmapRepository(ref.watch(databaseProvider)),
);
