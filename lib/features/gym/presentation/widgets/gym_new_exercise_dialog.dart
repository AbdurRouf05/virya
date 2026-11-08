import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/data/gym_repository.dart';
import 'package:virya/features/gym/domain/gym_models.dart';

/// Dialog membuat gerakan kustom. Mengembalikan gerakan baru atau null.
Future<ExerciseInfo?> showNewExerciseDialog(
  BuildContext context, {
  String initialName = '',
  MuscleGroup? muscle,
}) => showDialog<ExerciseInfo>(
  context: context,
  builder: (_) =>
      GymNewExerciseDialog(initialName: initialName, muscle: muscle),
);

class GymNewExerciseDialog extends ConsumerStatefulWidget {
  final String initialName;
  final MuscleGroup? muscle;
  const GymNewExerciseDialog({super.key, this.initialName = '', this.muscle});

  @override
  ConsumerState<GymNewExerciseDialog> createState() => _State();
}

class _State extends ConsumerState<GymNewExerciseDialog> {
  late final _name = TextEditingController(text: widget.initialName);
  late MuscleGroup _muscle = widget.muscle ?? MuscleGroup.dada;
  Equipment _eq = Equipment.barbel;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final e = await ref
        .read(gymRepositoryProvider)
        .createExercise(name: _name.text, muscle: _muscle, equipment: _eq);
    if (mounted) Navigator.pop(context, e);
  }

  Widget _chips<T>(
    List<T> all,
    T sel,
    String Function(T) label,
    ValueChanged<T> on,
  ) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final v in all)
        StampChip(
          text: label(v),
          fontSize: 10,
          selected: v == sel,
          onTap: () => on(v),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: const Text('GERAKAN BARU'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'NAMA'),
            ),
            const SizedBox(height: 14),
            Text('OTOT', style: FN.label(size: 10)),
            const SizedBox(height: 6),
            _chips(
              MuscleGroup.values,
              _muscle,
              (m) => m.label,
              (m) => setState(() => _muscle = m),
            ),
            const SizedBox(height: 14),
            Text('ALAT', style: FN.label(size: 10)),
            const SizedBox(height: 6),
            _chips(
              Equipment.values,
              _eq,
              (e) => e.label,
              (e) => setState(() => _eq = e),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('BATAL'),
        ),
        InkButton(
          label: 'Simpan',
          style: InkButtonStyle.primary,
          busy: _busy,
          height: 40,
          onPressed: _save,
        ),
      ],
    );
  }
}
