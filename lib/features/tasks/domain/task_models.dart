/// Satu tugas. [due] = tengah malam lokal, atau null bila tanpa tanggal.
class TaskItem {
  final String id;
  final String title;
  final String? note;
  final DateTime? due;
  final bool important;
  final bool pinned;
  final DateTime? doneAt;
  final DateTime createdAt;

  const TaskItem({
    required this.id,
    required this.title,
    this.note,
    this.due,
    this.important = false,
    this.pinned = false,
    this.doneAt,
    required this.createdAt,
  });

  bool get isDone => doneAt != null;
}

/// Pembagian tugas terbuka untuk ditampilkan.
class TaskBuckets {
  /// Jatuh tempo hari ini atau terlambat, plus yang di-pin.
  final List<TaskItem> today;

  /// Tanggal mendatang atau tanpa tanggal.
  final List<TaskItem> later;

  const TaskBuckets({required this.today, required this.later});
}

/// Perubahan yang dibuat di luar aplikasi (notifikasi / widget), menunggu
/// diterapkan ke database. [id] dipakai untuk konfirmasi antrean.
sealed class TaskInboxOp {
  final String id;
  final DateTime at;
  const TaskInboxOp(this.id, this.at);

  /// `null` bila entri rusak atau jenisnya tidak dikenal.
  static TaskInboxOp? parse(Map<String, dynamic> m) {
    final id = m['id'];
    final ms = m['at'];
    if (id is! String || ms is! num) return null;
    final at = DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: true);
    return switch (m['type']) {
      'capture' when m['title'] is String => TaskCaptureOp(
        id,
        at,
        title: m['title'] as String,
        dueDay: m['day'] as String?,
      ),
      'done' when m['taskId'] is String => TaskDoneOp(
        id,
        at,
        taskId: m['taskId'] as String,
      ),
      _ => null,
    };
  }
}

/// Tugas baru. [id] sekaligus menjadi id tugas agar aman diterapkan ulang.
class TaskCaptureOp extends TaskInboxOp {
  final String title;
  final String? dueDay;
  const TaskCaptureOp(super.id, super.at, {required this.title, this.dueDay});
}

class TaskDoneOp extends TaskInboxOp {
  final String taskId;
  const TaskDoneOp(super.id, super.at, {required this.taskId});
}
