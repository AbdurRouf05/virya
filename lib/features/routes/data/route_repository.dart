import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/routes/domain/route_codec.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/domain/route_scoring.dart';
import 'package:virya/features/routes/domain/route_stats.dart';

/// Simpan/baca rute rencana dan data riwayat yang dibutuhkan "Buat rute".
class RouteRepository {
  RouteRepository(this._db);

  final AppDatabase _db;

  Stream<List<SavedRoute>> watchAll() => _db.plannedRoutesDao
      .watchAll()
      .map((rows) => [for (final r in rows) fromRow(r)]);

  Future<SavedRoute?> byId(String id) async {
    final r = await _db.plannedRoutesDao.byId(id);
    return r == null ? null : fromRow(r);
  }

  /// Menyimpan; id kosong berarti rute baru. Mengembalikan versi tersimpan.
  Future<SavedRoute> save(SavedRoute r) async {
    final saved = r.id.isEmpty ? r.copyWith(id: const Uuid().v4()) : r;
    await _db.plannedRoutesDao.upsert(PlannedRoutesCompanion.insert(
      id: saved.id,
      name: saved.name,
      sport: saved.sport.name,
      shape: saved.shape.name,
      pointsJson: encodePath(saved.path),
      waypointsJson: Value(encodeWaypoints(saved.waypoints)),
      distanceM: saved.path.distanceM,
      ascentM: Value(saved.path.ascentM),
      createdAt: saved.createdAt,
      updatedAt: DateTime.now(),
    ));
    return saved;
  }

  Future<void> rename(String id, String name) =>
      _db.plannedRoutesDao.rename(id, name, DateTime.now());

  Future<void> delete(String id) => _db.plannedRoutesDao.remove(id);

  static SavedRoute fromRow(PlannedRoute r) => SavedRoute(
        id: r.id,
        name: r.name,
        sport: RouteSport.fromName(r.sport),
        shape: RouteShape.fromName(r.shape),
        path: decodePath(r.pointsJson,
            distanceM: r.distanceM, ascentM: r.ascentM),
        waypoints: decodeWaypoints(r.waypointsJson),
        createdAt: r.createdAt,
      );

  /// Titik jejak lama dalam radius [radiusM] dari [center] (untuk skor
  /// "jalan baru"). Dibatasi [maxPoints] titik supaya tetap ringan.
  Future<TrackGrid> trackGrid(LatLon center, double radiusM,
      {int maxPoints = 200000}) async {
    final dLat = radiusM / 111320;
    final dLon = radiusM /
        (111320 * math.max(0.1, math.cos(center.$1 * math.pi / 180)));
    final t = _db.trackPoints;
    final q = _db.selectOnly(t)
      ..addColumns([t.latitude, t.longitude])
      ..where(t.isPaused.equals(false) &
          t.latitude.isBetweenValues(center.$1 - dLat, center.$1 + dLat) &
          t.longitude.isBetweenValues(center.$2 - dLon, center.$2 + dLon))
      ..limit(maxPoints);
    final grid = TrackGrid(center);
    for (final row in await q.get()) {
      grid.add((row.read(t.latitude)!, row.read(t.longitude)!));
    }
    return grid;
  }

  /// Kecepatan rata-rata pengguna dari aktivitas selesai olahraga sejenis.
  Future<SportPace> pace(RouteSport sport) async {
    final want = switch (sport) {
      RouteSport.ride => SportCategory.cycling,
      RouteSport.run => SportCategory.running,
      RouteSport.walk => SportCategory.walking,
    };
    var dist = 0.0, moving = 0.0;
    for (final a in await _db.activitiesDao.getCompletedActivities()) {
      if (categoryOf(sportFromName(a.sportType)) != want) continue;
      if (a.movingTimeSeconds <= 0 || a.totalDistanceMeters <= 0) continue;
      dist += a.totalDistanceMeters;
      moving += a.movingTimeSeconds;
    }
    return paceFromHistory(sport, dist, moving);
  }
}
