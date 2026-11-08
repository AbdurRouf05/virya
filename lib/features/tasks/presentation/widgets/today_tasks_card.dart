import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/core/widgets/today_card.dart';
import 'package:virya/features/tasks/application/task_actions.dart';
import 'package:virya/features/tasks/data/task_providers.dart';
import 'package:virya/features/tasks/presentation/tasks_screen.dart';
import 'package:virya/features/tasks/presentation/widgets/task_edit_sheet.dart';
import 'package:virya/features/tasks/presentation/widgets/task_quick_add_sheet.dart';
import 'package:virya/features/tasks/presentation/widgets/task_tile.dart';

/// Kartu "TUGAS HARI INI" di layar Hari Ini. Jarak bawah ada di dalam kartu
/// agar tidak tersisa celah saat modul tugas tidak terpasang.
class TodayTasksCard extends ConsumerWidget {
  static const _maxShown = 5;

  const TodayTasksCard({super.key});

  void _openAll(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const TasksScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buckets = ref.watch(taskBucketsProvider).valueOrNull;
    if (buckets == null) return const SizedBox.shrink();
    final today = ref.watch(currentDayProvider);
    final tasks = buckets.today;
    final shown = tasks.take(_maxShown).toList();
    final hidden = tasks.length - shown.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TodayCard(
        title: 'TUGAS HARI INI',
        trailing: tasks.isEmpty ? 'SEMUA →' : '${tasks.length} TERSISA →',
        onTap: () => _openAll(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                child: Text(
                  'Belum ada tugas untuk hari ini.',
                  style: TextStyle(
                    fontFamily: FN.sans,
                    fontSize: 14,
                    color: FN.inkMuted,
                  ),
                ),
              ),
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) Container(height: 1, color: FN.paperLine),
              TaskTile(
                task: shown[i],
                today: today,
                onToggle: () => toggleTaskWithUndo(context, ref, shown[i]),
                onTap: () => showTaskEditor(context, shown[i]),
              ),
            ],
            _Footer(hidden: hidden, onAdd: () => showQuickAddTask(context)),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final int hidden;
  final VoidCallback onAdd;
  const _Footer({required this.hidden, required this.onAdd});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: hidden > 0
              ? Text('$hidden LAGI', style: FN.label(size: 10.5))
              : const SizedBox.shrink(),
        ),
      ),
      Semantics(
        button: true,
        label: 'Tambah tugas',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onAdd,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Text(
              '+ TAMBAH',
              style: FN
                  .label(size: 11, color: FN.ink)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    ],
  );
}
