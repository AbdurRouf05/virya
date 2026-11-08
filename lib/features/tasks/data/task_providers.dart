import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/features/tasks/data/task_repository.dart';
import 'package:virya/features/tasks/domain/task_logic.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

/// Semua tugas yang belum selesai (belum terurut).
final openTasksProvider = StreamProvider<List<TaskItem>>(
  (ref) => ref
      .watch(tasksDaoProvider)
      .watchOpen()
      .map((rows) => rows.map(taskItemOf).toList()),
);

/// Tugas terbuka dibagi Hari ini / Nanti; dihitung ulang saat hari berganti.
final taskBucketsProvider = Provider<AsyncValue<TaskBuckets>>((ref) {
  final today = ref.watch(currentDayProvider);
  return ref
      .watch(openTasksProvider)
      .whenData((open) => bucketTasks(open, today));
});

/// 30 tugas terakhir yang selesai.
final doneTasksProvider = StreamProvider<List<TaskItem>>(
  (ref) => ref
      .watch(tasksDaoProvider)
      .watchDone()
      .map((rows) => rows.map(taskItemOf).toList()),
);

/// Tugas yang selesai pada hari lokal [day] (tengah malam).
final tasksDoneOnProvider =
    StreamProvider.autoDispose.family<List<TaskItem>, DateTime>((ref, day) {
      final next = DateTime(day.year, day.month, day.day + 1);
      return ref
          .watch(tasksDaoProvider)
          .watchDoneBetween(day.toUtc(), next.toUtc())
          .map((rows) => rows.map(taskItemOf).toList());
    });
