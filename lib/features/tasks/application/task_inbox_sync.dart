import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/features/tasks/data/task_bridge.dart';
import 'package:virya/features/tasks/data/task_repository.dart';

/// Memindahkan antrean native ke database.
///
/// Urutannya baca → terapkan → konfirmasi, jadi bila aplikasi mati di tengah
/// jalan, antrean diulang dan `applyOp` yang idempoten menjaga tidak ada
/// tugas ganda. Pemanggilan bersamaan digabung menjadi satu putaran lagi.
class TaskInboxSync {
  final TaskRepository _repo;
  final TaskBridge _bridge;
  TaskInboxSync(this._repo, this._bridge);

  bool _running = false;
  bool _again = false;

  Future<void> drain() async {
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    try {
      do {
        _again = false;
        final ops = await _bridge.peekInbox();
        if (ops.isEmpty) continue;
        for (final op in ops) {
          await _repo.applyOp(op);
        }
        await _bridge.ackInbox([for (final op in ops) op.id]);
      } while (_again);
    } finally {
      _running = false;
    }
  }
}

final taskInboxSyncProvider = Provider<TaskInboxSync>(
  (ref) => TaskInboxSync(
    ref.watch(taskRepositoryProvider),
    ref.watch(taskBridgeProvider),
  ),
);
