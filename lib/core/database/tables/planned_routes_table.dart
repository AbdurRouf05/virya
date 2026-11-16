import 'package:drift/drift.dart';

/// v8: rute rencana buatan pengguna (Buat rute), dipakai offline.
class PlannedRoutes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// `ride` | `run` | `walk`.
  TextColumn get sport => text()();

  /// `loop` | `outAndBack` | `pointToPoint` | `manual`.
  TextColumn get shape => text()();

  /// JSON `[[lat, lon, ele], ...]`; ele boleh `null`.
  TextColumn get pointsJson => text()();

  /// JSON `[[lat, lon], ...]` titik bantu untuk mode edit.
  TextColumn get waypointsJson => text().withDefault(const Constant('[]'))();
  RealColumn get distanceM => real()();
  RealColumn get ascentM => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
