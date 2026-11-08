import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/tasks/domain/task_logic.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

/// Satu baris tugas: kotak centang, judul, dan keterangan singkat.
class TaskTile extends StatelessWidget {
  final TaskItem task;
  final DateTime today;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.today,
    required this.onToggle,
    this.onTap,
  });

  String? _dueLabel() {
    final due = task.due;
    if (due == null || task.isDone) return null;
    if (isTaskOverdue(task, today)) return 'TERLAMBAT';
    if (due == today) return 'HARI INI';
    if (due == DateTime(today.year, today.month, today.day + 1)) return 'BESOK';
    return '${due.day} ${Fmt.monthsShort[due.month - 1]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final overdue = isTaskOverdue(task, today);
    final meta = [?_dueLabel(), if (task.important) 'PENTING'].join(' · ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Row(
          children: [
            _CheckBox(
              done: task.isDone,
              title: task.title,
              onTap: onToggle,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FN.sans,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: task.isDone ? FN.inkMuted : FN.ink,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: FN.label(
                          size: 10,
                          color: overdue ? FN.warn : FN.inkMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (task.pinned) ...[
              const SizedBox(width: 8),
              Icon(Icons.push_pin, size: 16, color: FN.ink),
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  final bool done;
  final String title;
  final VoidCallback onTap;
  const _CheckBox({
    required this.done,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    checked: done,
    label: title,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: done ? FN.ink : Colors.transparent,
              border: Border.all(color: FN.ink, width: 2),
            ),
            child: done ? Icon(Icons.check, size: 18, color: FN.paper) : null,
          ),
        ),
      ),
    ),
  );
}
