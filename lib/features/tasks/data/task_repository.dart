import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/daos/tasks_dao.dart';
import 'package:virya/features/tasks/domain/task_logic.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

/// DB row → model domain.
TaskItem taskItemOf(Task t) => TaskItem(
  id: t.id,
  title: t.title,
  note: t.note,
  due: parseTaskDay(t.dueDay),
  important: t.priority > 0,
  pinned: t.pinned,
  doneAt: t.doneAt,
  createdAt: t.createdAt,
);

/// Semua penulisan tugas lewat sini.
class TaskRepository {
  final TasksDao _dao;
  TaskRepository(this._dao);

  /// Null bila judul kosong.
  Future<String?> add(
    String rawTitle, {
    DateTime? due,
    bool important = false,
    bool pinned = false,
  }) async {
    final title = normalizeTaskTitle(rawTitle);
    if (title == null) return null;
    final id = const Uuid().v4();
    await _dao.insertTask(
      TasksCompanion.insert(
        id: id,
        title: title,
        dueDay: Value(due == null ? null : taskDayKey(due)),
        priority: Value(important ? 1 : 0),
        pinned: Value(pinned),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    return id;
  }

  /// Simpan hasil edit. Judul kosong diabaikan (judul lama dipertahankan).
  Future<void> save(TaskItem t) async {
    final title = normalizeTaskTitle(t.title);
    final note = t.note?.trim();
    await _dao.updateTask(
      t.id,
      TasksCompanion(
        title: title == null ? const Value.absent() : Value(title),
        note: Value(note == null || note.isEmpty ? null : note),
        dueDay: Value(t.due == null ? null : taskDayKey(t.due!)),
        priority: Value(t.important ? 1 : 0),
        pinned: Value(t.pinned),
      ),
    );
  }

  Future<void> setDone(String id, bool done) =>
      _dao.setDoneAt(id, done ? DateTime.now().toUtc() : null);

  Future<void> delete(String id) => _dao.deleteTask(id);

  /// Terapkan perubahan dari luar aplikasi. Aman diulang untuk op yang sama.
  Future<void> applyOp(TaskInboxOp op) async {
    switch (op) {
      case TaskCaptureOp():
        final title = normalizeTaskTitle(op.title);
        if (title == null) return;
        await _dao.insertTask(
          TasksCompanion.insert(
            id: op.id,
            title: title,
            dueDay: Value(parseTaskDay(op.dueDay) == null ? null : op.dueDay),
            createdAt: op.at,
          ),
        );
      case TaskDoneOp():
        await _dao.markDoneIfOpen(op.taskId, op.at);
    }
  }
}

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(ref.watch(tasksDaoProvider)),
);
