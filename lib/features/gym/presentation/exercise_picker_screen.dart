import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/data/gym_providers.dart';
import 'package:virya/features/gym/domain/gym_models.dart';
import 'package:virya/features/gym/presentation/widgets/gym_new_exercise_dialog.dart';

/// Buka pemilih gerakan. Mengembalikan gerakan terpilih atau null.
Future<ExerciseInfo?> pickExercise(BuildContext context) =>
    Navigator.of(context).push<ExerciseInfo>(
      MaterialPageRoute(builder: (_) => const ExercisePickerScreen()),
    );

/// Cari gerakan per nama & kelompok otot; bisa membuat gerakan kustom.
class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key});

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  String _q = '';
  MuscleGroup? _muscle;

  Future<void> _create() async {
    final e = await showNewExerciseDialog(
      context,
      initialName: _q,
      muscle: _muscle,
    );
    if (e != null && mounted) Navigator.pop(context, e);
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(exercisesProvider).valueOrNull ?? const [];
    final q = _q.trim().toLowerCase();
    final list = all
        .where((e) => _muscle == null || e.muscle == _muscle)
        .where((e) => q.isEmpty || e.name.toLowerCase().contains(q))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('PILIH GERAKAN'),
        actions: [
          IconButton(
            tooltip: 'Gerakan baru',
            icon: const Icon(Icons.add),
            onPressed: _create,
          ),
        ],
      ),
      body: PaperBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                autofocus: false,
                onChanged: (v) => setState(() => _q = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cari gerakan…',
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                children: [
                  _chip('SEMUA', null),
                  for (final m in MuscleGroup.values) _chip(m.label, m),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 32),
                itemCount: list.length + 1,
                separatorBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkRule(dashed: true, color: FN.inkMuted),
                ),
                itemBuilder: (_, i) =>
                    i == list.length ? _createTile() : _tile(list[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, MuscleGroup? m) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: StampChip(
      text: label,
      fontSize: 10,
      selected: _muscle == m,
      onTap: () => setState(() => _muscle = m),
    ),
  );

  Widget _tile(ExerciseInfo e) => ListTile(
    title: Text(
      e.name,
      style: TextStyle(
        fontFamily: FN.sans,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: FN.ink,
      ),
    ),
    subtitle: Text(
      '${e.muscle.label} · ${e.equipment.label}${e.isCustom ? ' · KUSTOM' : ''}',
      style: FN.label(size: 9.5),
    ),
    trailing: Icon(Icons.add, color: FN.ink),
    onTap: () => Navigator.pop(context, e),
  );

  Widget _createTile() => Padding(
    padding: const EdgeInsets.all(16),
    child: InkButton(
      label: _q.trim().isEmpty ? 'Buat gerakan baru' : 'Buat "${_q.trim()}"',
      icon: Icons.add,
      expand: true,
      onPressed: _create,
    ),
  );
}
