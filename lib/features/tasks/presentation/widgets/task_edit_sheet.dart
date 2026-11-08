import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/tasks/data/task_repository.dart';
import 'package:virya/features/tasks/domain/task_models.dart';
import 'package:virya/features/tasks/presentation/widgets/task_due_chips.dart';

Future<void> showTaskEditor(BuildContext context, TaskItem task) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: FN.paper,
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      builder: (_) => TaskEditSheet(task: task),
    );

/// Ubah judul, catatan, tanggal, penting, pin; atau hapus tugas.
class TaskEditSheet extends ConsumerStatefulWidget {
  final TaskItem task;
  const TaskEditSheet({super.key, required this.task});

  @override
  ConsumerState<TaskEditSheet> createState() => _State();
}

class _State extends ConsumerState<TaskEditSheet> {
  late final _title = TextEditingController(text: widget.task.title);
  late final _note = TextEditingController(text: widget.task.note ?? '');
  late DateTime? _due = widget.task.due;
  late bool _important = widget.task.important;
  late bool _pinned = widget.task.pinned;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = widget.task;
    await ref
        .read(taskRepositoryProvider)
        .save(
          TaskItem(
            id: t.id,
            title: _title.text,
            note: _note.text,
            due: _due,
            important: _important,
            pinned: _pinned,
            doneAt: t.doneAt,
            createdAt: t.createdAt,
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await ref.read(taskRepositoryProvider).delete(widget.task.id);
    if (mounted) Navigator.pop(context);
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> on) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label, style: FN.label(size: 12, color: FN.ink))),
        InkToggle(value: value, onChanged: on),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(currentDayProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _title,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Tugas',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _note,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),
              const SizedBox(height: 14),
              TaskDueChips(
                value: _due,
                today: today,
                onChanged: (d) => setState(() => _due = d),
              ),
              const SizedBox(height: 8),
              _toggle(
                'PENTING',
                _important,
                (v) => setState(() => _important = v),
              ),
              _toggle(
                'PIN KE HARI INI & WIDGET',
                _pinned,
                (v) => setState(() => _pinned = v),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  InkButton(
                    label: 'Hapus',
                    style: InkButtonStyle.danger,
                    onPressed: _delete,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkButton(
                      label: 'Simpan',
                      style: InkButtonStyle.primary,
                      expand: true,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
