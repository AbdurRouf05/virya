import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/tasks/application/task_actions.dart';
import 'package:virya/features/tasks/data/task_providers.dart';
import 'package:virya/features/tasks/domain/task_models.dart';
import 'package:virya/features/tasks/presentation/widgets/task_capture_field.dart';
import 'package:virya/features/tasks/presentation/widgets/task_edit_sheet.dart';
import 'package:virya/features/tasks/presentation/widgets/task_outside_section.dart';
import 'package:virya/features/tasks/presentation/widgets/task_tile.dart';

/// Daftar lengkap tugas: Hari ini · Nanti · Selesai.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  List<Widget> _section(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required List<TaskItem> tasks,
    required DateTime today,
    required String empty,
  }) => [
    SectionHeader(
      title: title,
      trailing: tasks.isEmpty
          ? null
          : Text('${tasks.length}', style: FN.label(size: 11)),
    ),
    if (tasks.isEmpty)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          empty,
          style: TextStyle(
            fontFamily: FN.sans,
            fontSize: 14,
            color: FN.inkMuted,
          ),
        ),
      ),
    for (var i = 0; i < tasks.length; i++) ...[
      if (i > 0) Container(height: 1, color: FN.paperLine),
      TaskTile(
        task: tasks[i],
        today: today,
        onToggle: () => toggleTaskWithUndo(context, ref, tasks[i]),
        onTap: () => showTaskEditor(context, tasks[i]),
      ),
    ],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(currentDayProvider);
    final buckets = ref.watch(taskBucketsProvider).valueOrNull;
    final done = ref.watch(doneTasksProvider).valueOrNull ?? const <TaskItem>[];
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
              const Masthead(
                kicker: 'Hari ini · Nanti · Selesai',
                title: 'Tugas',
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: TaskCaptureField(),
              ),
              if (buckets != null) ...[
                ..._section(
                  context,
                  ref,
                  title: 'Hari ini',
                  tasks: buckets.today,
                  today: today,
                  empty: 'Tidak ada tugas untuk hari ini.',
                ),
                ..._section(
                  context,
                  ref,
                  title: 'Nanti',
                  tasks: buckets.later,
                  today: today,
                  empty: 'Belum ada tugas untuk nanti.',
                ),
              ],
              ..._section(
                context,
                ref,
                title: 'Selesai',
                tasks: done,
                today: today,
                empty: 'Belum ada tugas yang selesai.',
              ),
              const TaskOutsideSection(),
            ],
          ),
        ),
      ),
    );
  }
}
