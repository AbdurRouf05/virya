import 'package:virya/core/time/day_key.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

const maxTaskTitleLength = 200;

/// Hari lokal → `YYYY-MM-DD`.
String taskDayKey(DateTime d) => dayKeyOf(d);

/// `YYYY-MM-DD` → tengah malam lokal. Null bila kosong atau tidak valid.
DateTime? parseTaskDay(String? key) => dayFromKey(key);

/// Rapikan judul: spasi & baris baru dipadatkan, panjang dibatasi.
/// Null bila kosong.
String? normalizeTaskTitle(String raw) {
  final s = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (s.isEmpty) return null;
  return s.length <= maxTaskTitleLength
      ? s
      : s.substring(0, maxTaskTitleLength);
}

bool isTaskOverdue(TaskItem t, DateTime today) =>
    !t.isDone && t.due != null && t.due!.isBefore(today);

/// Di-pin → penting → tanggal terdekat (tanpa tanggal terakhir) → terlama dibuat.
int compareTasks(TaskItem a, TaskItem b) {
  if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
  if (a.important != b.important) return a.important ? -1 : 1;
  if (a.due != b.due) {
    if (a.due == null) return 1;
    if (b.due == null) return -1;
    return a.due!.compareTo(b.due!);
  }
  return a.createdAt.compareTo(b.createdAt);
}

TaskBuckets bucketTasks(Iterable<TaskItem> open, DateTime today) {
  final now = <TaskItem>[];
  final later = <TaskItem>[];
  for (final t in open) {
    final isToday = t.pinned || (t.due != null && !t.due!.isAfter(today));
    (isToday ? now : later).add(t);
  }
  return TaskBuckets(
    today: now..sort(compareTasks),
    later: later..sort(compareTasks),
  );
}

/// Data untuk widget layar utama. Tanggal ikut dikirim karena widget
/// memilah sendiri "hari ini" saat aplikasi tidak berjalan.
List<Map<String, Object?>> taskWidgetSnapshot(Iterable<TaskItem> open) {
  final list = open.where((t) => t.pinned || t.due != null).toList()
    ..sort(compareTasks);
  return [
    for (final t in list.take(100))
      {
        'id': t.id,
        'title': t.title,
        'day': t.due == null ? null : taskDayKey(t.due!),
        'important': t.important,
        'pinned': t.pinned,
      },
  ];
}
