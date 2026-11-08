import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/data/gym_providers.dart';
import 'package:virya/features/gym/data/gym_repository.dart';
import 'package:virya/features/gym/domain/session_draft.dart';
import 'package:virya/features/gym/presentation/widgets/gym_dialogs.dart';

/// Isi detail aktivitas gym: ringkasan, tabel set per gerakan, dan tombol
/// "simpan sebagai template". Dipakai lewat `Integrations.gymSessionDetail`.
class GymSessionDetail extends ConsumerWidget {
  final String activityId;
  const GymSessionDetail({super.key, required this.activityId});

  Future<void> _saveTemplate(BuildContext context, WidgetRef ref) async {
    final name = await gymPrompt(context, title: 'Simpan sebagai template');
    if (name == null) return;
    await ref.read(gymRepositoryProvider).templateFromSession(activityId, name);
    if (context.mounted) gymToast(context, 'Template "$name" disimpan.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(sessionSetsProvider(activityId)).valueOrNull;
    final lib = ref.watch(exerciseMapProvider);
    if (sets == null) return const SizedBox(height: 120);
    final groups = <int, List<WorkoutSet>>{};
    for (final s in sets) {
      (groups[s.exerciseOrder] ??= []).add(s);
    }
    final orders = groups.keys.toList()..sort();
    var vol = 0.0;
    var work = 0;
    for (final s in sets) {
      if (s.isWarmup) continue;
      work++;
      vol += (s.weightKg ?? 0) * (s.reps ?? 0);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkBox(
            child: Row(
              children: [
                Expanded(
                  child: StatBlock(
                    label: 'Volume',
                    value: Fmt.number(vol),
                    unit: 'KG',
                    size: 28,
                  ),
                ),
                Expanded(
                  child: StatBlock(label: 'Set', value: '$work', size: 28),
                ),
                Expanded(
                  child: StatBlock(
                    label: 'Gerakan',
                    value: '${orders.length}',
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          if (sets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Tidak ada set tercatat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: FN.sans, color: FN.inkSoft),
              ),
            ),
          for (final o in orders)
            _exercise(
              lib[groups[o]!.first.exerciseId]?.name ?? 'Gerakan',
              groups[o]!,
            ),
          if (sets.isNotEmpty) ...[
            const SizedBox(height: 18),
            InkButton(
              label: 'Simpan sebagai template',
              icon: Icons.bookmark_add_outlined,
              style: InkButtonStyle.outline,
              expand: true,
              onPressed: () => _saveTemplate(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  Widget _exercise(String name, List<WorkoutSet> list) {
    var n = 0;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            name.toUpperCase(),
            style: TextStyle(
              fontFamily: FN.display,
              fontSize: 20,
              color: FN.ink,
            ),
          ),
          const SizedBox(height: 4),
          InkRule(color: FN.ink),
          for (final s in list)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      s.isWarmup ? 'W' : '${++n}',
                      style: FN.label(size: 11, color: FN.inkSoft),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${fmtKg(s.weightKg ?? 0)} kg × ${s.reps ?? 0}',
                      style: TextStyle(
                        fontFamily: FN.mono,
                        fontSize: 14,
                        color: FN.ink,
                      ),
                    ),
                  ),
                  if (s.rpe != null)
                    Text('RPE ${fmtKg(s.rpe!)}', style: FN.label(size: 10)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
