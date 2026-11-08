import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/tasks/data/task_repository.dart';
import 'package:virya/features/tasks/presentation/widgets/task_due_chips.dart';

/// Lembar catat cepat: ketik, pilih hari, simpan.
Future<void> showQuickAddTask(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: FN.paper,
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      builder: (_) => const TaskQuickAddSheet(),
    );

class TaskQuickAddSheet extends ConsumerStatefulWidget {
  const TaskQuickAddSheet({super.key});

  @override
  ConsumerState<TaskQuickAddSheet> createState() => _State();
}

class _State extends ConsumerState<TaskQuickAddSheet> {
  final _title = TextEditingController();
  late DateTime? _due = ref.read(currentDayProvider);
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final id = await ref
        .read(taskRepositoryProvider)
        .add(_title.text, due: _due);
    if (!mounted) return;
    if (id == null) {
      setState(() => _saving = false);
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(currentDayProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'TUGAS BARU',
                style: TextStyle(
                  fontFamily: FN.display,
                  fontSize: 32,
                  height: 1.05,
                  color: FN.ink,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _title,
                autofocus: true,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: const InputDecoration(
                  hintText: 'Mau ngerjain apa?',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TaskDueChips(
                value: _due,
                today: today,
                onChanged: (d) => setState(() => _due = d),
              ),
              const SizedBox(height: 14),
              InkButton(
                label: 'Simpan',
                style: InkButtonStyle.primary,
                expand: true,
                busy: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
