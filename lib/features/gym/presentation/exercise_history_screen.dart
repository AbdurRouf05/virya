import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/application/gym_stats.dart';
import 'package:virya/features/gym/domain/gym_math.dart';
import 'package:virya/features/gym/domain/gym_models.dart';
import 'package:virya/features/gym/domain/session_draft.dart';
import 'package:virya/features/gym/presentation/widgets/gym_pr_strip.dart';

Future<void> openExerciseHistory(BuildContext context, ExerciseInfo e) =>
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExerciseHistoryScreen(exercise: e)),
    );

/// Riwayat satu gerakan: PR + daftar sesi beserta setnya.
class ExerciseHistoryScreen extends ConsumerWidget {
  final ExerciseInfo exercise;
  const ExerciseHistoryScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(exerciseHistoryProvider(exercise.id));
    final pr = personalRecords(sets);
    final bySession = <String, List<SetRecord>>{};
    for (final s in sets) {
      (bySession[s.sessionId] ??= []).add(s);
    }
    final sessions = bySession.values.toList()
      ..sort((a, b) => b.first.sessionStart.compareTo(a.first.sessionStart));
    return Scaffold(
      appBar: AppBar(title: Text(exercise.name.toUpperCase())),
      body: PaperBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Text(
              '${exercise.muscle.label} · ${exercise.equipment.label}',
              style: FN.label(size: 10),
            ),
            const SizedBox(height: 12),
            if (pr != null) GymPrStrip(pr: pr),
            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Belum ada set tercatat untuk gerakan ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: FN.sans, color: FN.inkSoft),
                ),
              ),
            for (final list in sessions) _session(list),
          ],
        ),
      ),
    );
  }

  Widget _session(List<SetRecord> list) {
    final d = list.first.sessionStart.toLocal();
    final vol = totalVolume(list);
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Fmt.dateStamp(d, withTime: false),
                  style: FN
                      .label(size: 10.5, color: FN.ink)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text('${Fmt.number(vol)} KG', style: FN.label(size: 10)),
            ],
          ),
          const SizedBox(height: 6),
          InkRule(color: FN.ink),
          for (final (i, s) in list.indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      s.isWarmup ? 'W' : '${i + 1}',
                      style: FN.label(size: 11, color: FN.inkSoft),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${fmtKg(s.weightKg)} kg × ${s.reps}',
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
