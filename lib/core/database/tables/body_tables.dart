import 'package:drift/drift.dart';

/// Check-in progres tubuh, satu per hari.
class BodyCheckins extends Table {
  TextColumn get id => text()();

  /// Hari lokal, format `YYYY-MM-DD`.
  TextColumn get day => text()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get bodyFatPct => real().nullable()();
  RealColumn get waistCm => real().nullable()();
  RealColumn get chestCm => real().nullable()();
  RealColumn get armCm => real().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {day},
  ];
}

/// Foto satu pose pada satu check-in.
class BodyPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get checkinId =>
      text().references(BodyCheckins, #id, onDelete: KeyAction.cascade)();

  /// Nama enum `BodyPose`: `front`, `side`, atau `back`.
  TextColumn get pose => text()();

  /// Relatif terhadap folder dokumen aplikasi, supaya tetap benar setelah
  /// backup dipulihkan di perangkat lain.
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {checkinId, pose},
  ];
}
