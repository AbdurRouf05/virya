import 'package:drift/drift.dart';

/// Tugas / to-do pribadi.
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();

  /// Hari jatuh tempo lokal, format `YYYY-MM-DD` (bukan DateTime agar tidak
  /// bergeser saat zona waktu berubah). Null = "Nanti", tanpa tanggal.
  TextColumn get dueDay => text().nullable()();

  /// 0 = biasa, 1 = penting.
  IntColumn get priority => integer().withDefault(const Constant(0))();

  /// Di-pin: selalu tampil di Hari Ini dan widget layar utama.
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  /// Null = belum selesai.
  DateTimeColumn get doneAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
