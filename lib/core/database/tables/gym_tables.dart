import 'package:drift/drift.dart';
import 'package:virya/core/database/tables/activities_table.dart';

/// Library gerakan gym (bawaan + buatan pengguna).
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// dada | punggung | kaki | bahu | lengan | core | lainnya
  TextColumn get muscleGroup => text()();

  /// barbel | dumbel | mesin | kabel | badan | lainnya
  TextColumn get equipment => text().withDefault(const Constant('lainnya'))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Satu set dalam sesi gym. Sesi = baris `activities` (sportType strength).
class WorkoutSets extends Table {
  TextColumn get id => text()();
  TextColumn get activityId =>
      text().references(Activities, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().references(Exercises, #id)();

  /// Urutan gerakan dalam sesi (0..n) dan urutan set dalam gerakan.
  IntColumn get exerciseOrder => integer()();
  IntColumn get setIndex => integer()();

  /// Null = belum diisi (draf sesi yang masih berjalan).
  IntColumn get reps => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get rpe => real().nullable()();
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();

  /// Null = set belum dicentang.
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Template latihan ("Push day", "Kaki").
class WorkoutTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Isi template: gerakan + target set × reps.
class WorkoutTemplateItems extends Table {
  TextColumn get id => text()();
  TextColumn get templateId =>
      text().references(WorkoutTemplates, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get itemOrder => integer()();
  IntColumn get targetSets => integer().withDefault(const Constant(3))();
  IntColumn get targetReps => integer().withDefault(const Constant(8))();

  @override
  Set<Column> get primaryKey => {id};
}
