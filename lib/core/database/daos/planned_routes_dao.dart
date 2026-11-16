import 'package:drift/drift.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/tables/planned_routes_table.dart';

part 'planned_routes_dao.g.dart';

/// Akses rute rencana yang disimpan.
@DriftAccessor(tables: [PlannedRoutes])
class PlannedRoutesDao extends DatabaseAccessor<AppDatabase>
    with _$PlannedRoutesDaoMixin {
  PlannedRoutesDao(super.db);

  /// Terbaru dulu.
  Stream<List<PlannedRoute>> watchAll() => (select(plannedRoutes)
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
      .watch();

  Future<PlannedRoute?> byId(String id) =>
      (select(plannedRoutes)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(PlannedRoutesCompanion row) =>
      into(plannedRoutes).insertOnConflictUpdate(row);

  Future<void> rename(String id, String name, DateTime at) =>
      (update(plannedRoutes)..where((t) => t.id.equals(id))).write(
        PlannedRoutesCompanion(name: Value(name), updatedAt: Value(at)),
      );

  Future<int> remove(String id) =>
      (delete(plannedRoutes)..where((t) => t.id.equals(id))).go();
}
