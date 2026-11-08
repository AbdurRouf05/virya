import 'package:drift/drift.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/tables/tasks_table.dart';

part 'tasks_dao.g.dart';

/// Akses tabel tugas. Waktu `doneAt` disimpan UTC.
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  Stream<List<Task>> watchOpen() =>
      (select(tasks)..where((t) => t.doneAt.isNull())).watch();

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
  Future<void> markDoneIfOpen(String id, DateTime at) =>
      (update(tasks)..where((r) => r.id.equals(id) & r.doneAt.isNull())).write(
        TasksCompanion(doneAt: Value(at)),
      );

  Future<void> deleteTask(String id) =>
      (delete(tasks)..where((r) => r.id.equals(id))).go();
}
