import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/tasks/data/task_repository.dart';

/// Kolom ketik di atas daftar: Enter menyimpan tugas untuk hari ini dan
/// kolom tetap aktif untuk tugas berikutnya.
class TaskCaptureField extends ConsumerStatefulWidget {
  const TaskCaptureField({super.key});

  @override
  ConsumerState<TaskCaptureField> createState() => _State();
}

class _State extends ConsumerState<TaskCaptureField> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final id = await ref
        .read(taskRepositoryProvider)
        .add(_text.text, due: ref.read(currentDayProvider));
    if (id == null || !mounted) return;
    _text.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextField(
          controller: _text,
          focusNode: _focus,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            hintText: 'Catat tugas untuk hari ini',
            counterText: '',
          ),
        ),
      ),
      const SizedBox(width: 10),
      InkIconButton(
        icon: Icons.add,
        size: 48,
        tooltip: 'Tambah tugas',
        onPressed: _submit,
      ),
    ],
  );
}
