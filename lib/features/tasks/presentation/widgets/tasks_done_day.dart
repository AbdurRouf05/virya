import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/tasks/data/task_providers.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

/// Daftar tugas yang selesai pada [day], untuk detail hari di kalender.
/// Tidak menggambar apa pun bila kosong.
class TasksDoneDay extends ConsumerWidget {
  final DateTime day;
  const TasksDoneDay({super.key, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksDoneOnProvider(day)).valueOrNull ?? const [];
    if (tasks.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: FN.ink, width: 2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'TUGAS SELESAI',
                      style: FN
                          .label(size: 12, color: FN.ink)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '${tasks.length} TUGAS',
                    style: FN.label(size: 11, color: FN.ink),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: FN.ink),
            for (var i = 0; i < tasks.length; i++) ...[
              if (i > 0) Container(height: 1, color: FN.paperLine),
              _Row(task: tasks[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final TaskItem task;
  const _Row({required this.task});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    child: Row(
      children: [
        Icon(Icons.check, size: 18, color: FN.ok),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: FN.sans, fontSize: 14, color: FN.ink),
          ),
        ),
        const SizedBox(width: 8),
        Text(Fmt.time(task.doneAt!.toLocal()), style: FN.label(size: 11)),
      ],
    ),
  );
}
