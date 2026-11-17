import 'package:drift/drift.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/tables/tasks_table.dart';

part 'tasks_dao.g.dart';

/// Akses tabel tugas. Waktu `doneAt` disimpan UTC.
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  /// Tugas belum selesai, plus semua rutinitas (selesai-tidaknya hari ini
  /// dipilah di Dart karena bergantung pada hari lokal).
  Stream<List<Task>> watchOpen() => (select(
    tasks,
  )..where((t) => t.doneAt.isNull() | t.repeatDaily.equals(true))).watch();

  /// Semua rutinitas harian.
  Stream<List<Task>> watchRoutines() =>
      (select(tasks)..where((t) => t.repeatDaily.equals(true))).watch();

  /// Tugas selesai, terbaru dulu.
  Stream<List<Task>> watchDone({int limit = 30}) =>
      (select(tasks)
            ..where((t) => t.doneAt.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.doneAt)])
            ..limit(limit))
          .watch();

  /// Tugas yang selesai dalam rentang `[from, to)`.
  Stream<List<Task>> watchDoneBetween(DateTime from, DateTime to) =>
      (select(tasks)
            ..where(
              (t) =>
                  t.doneAt.isBiggerOrEqualValue(from) &
                  t.doneAt.isSmallerThanValue(to),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.doneAt)]))
          .watch();

  /// Tidak menimpa bila id sudah ada, jadi aman diulang (antrean native).
  Future<void> insertTask(TasksCompanion t) =>
      into(tasks).insert(t, mode: InsertMode.insertOrIgnore);

  Future<void> updateTask(String id, TasksCompanion t) =>
      (update(tasks)..where((r) => r.id.equals(id))).write(t);

  Future<void> setDoneAt(String id, DateTime? at) => updateTask(
    id,
    TasksCompanion(doneAt: Value(at)),
  );

  /// Tandai selesai hanya bila masih terbuka (waktu selesai pertama dipakai).
  /// Rutinitas yang terakhir dicentang sebelum [dayStart] dianggap terbuka.
  Future<void> markDoneIfOpen(String id, DateTime at, DateTime dayStart) =>
      (update(tasks)..where(
            (r) =>
                r.id.equals(id) &
                (r.doneAt.isNull() |
                    (r.repeatDaily.equals(true) &
                        r.doneAt.isSmallerThanValue(dayStart))),
          ))
          .write(TasksCompanion(doneAt: Value(at)));

  Future<void> deleteTask(String id) =>
      (delete(tasks)..where((r) => r.id.equals(id))).go();
}
