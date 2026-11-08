import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/features/tasks/data/task_repository.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

/// Centang tugas. Saat menandai selesai, tawarkan BATAL lewat snackbar.
Future<void> toggleTaskWithUndo(
  BuildContext context,
  WidgetRef ref,
  TaskItem task,
) async {
  final repo = ref.read(taskRepositoryProvider);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final done = !task.isDone;
  await repo.setDone(task.id, done);
  if (!done) return;
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text('Tugas selesai'),
        action: SnackBarAction(
          label: 'BATAL',
          onPressed: () => repo.setDone(task.id, false),
        ),
      ),
    );
}
