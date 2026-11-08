import 'package:drift/drift.dart';

/// Batas waktu harian per aplikasi.
class AppLimits extends Table {
  TextColumn get packageName => text()();
  TextColumn get label => text()();
  IntColumn get dailyMinutes => integer()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  /// Pemakaian sebelum tanggal ini tidak dicatat sebagai riwayat.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {packageName};
}

/// Catatan pemakaian harian. Nama dan batas ikut disimpan agar riwayat tetap
/// benar setelah batasnya diubah atau dihapus.
class AppUsageDays extends Table {
  /// Hari lokal, format `YYYY-MM-DD`.
  TextColumn get day => text()();
  TextColumn get packageName => text()();
  TextColumn get label => text()();
  IntColumn get minutes => integer()();
  IntColumn get limitMinutes => integer()();

  @override
  Set<Column> get primaryKey => {day, packageName};
}
