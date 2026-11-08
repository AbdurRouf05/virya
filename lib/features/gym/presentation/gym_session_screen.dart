import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/application/gym_clock.dart';
import 'package:virya/features/gym/application/gym_session_controller.dart';
import 'package:virya/features/gym/application/gym_stats.dart';
import 'package:virya/features/gym/presentation/exercise_history_screen.dart';
import 'package:virya/features/gym/presentation/exercise_picker_screen.dart';
import 'package:virya/features/gym/presentation/widgets/gym_dialogs.dart';
import 'package:virya/features/gym/presentation/widgets/gym_exercise_card.dart';
import 'package:virya/features/gym/presentation/widgets/gym_rest_bar.dart';
import 'package:virya/features/gym/presentation/widgets/gym_session_header.dart';

/// Layar sesi gym berjalan. Kembali (←) tidak menghentikan sesi.
class GymSessionScreen extends ConsumerStatefulWidget {
  const GymSessionScreen({super.key});

  @override
  ConsumerState<GymSessionScreen> createState() => _GymSessionScreenState();
}

class _GymSessionScreenState extends ConsumerState<GymSessionScreen> {
  bool _busy = false;
  DateTime? _restBuzzed;

  GymSessionController get _ctl => ref.read(gymSessionProvider.notifier);

  Future<void> _rename(String current) async {
    final t = await gymPrompt(context, title: 'Ganti nama', initial: current);
    if (t != null) await _ctl.rename(t);
  }

  Future<void> _discard() async {
    final ok = await gymConfirm(
      context,
      title: 'Buang sesi?',
      body: 'Semua set di sesi ini akan dihapus dan tidak bisa dikembalikan.',
      action: 'BUANG',
      danger: true,
    );
    if (!ok) return;
    await _ctl.discard();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _addExercise() async {
    final e = await pickExercise(context);
    if (e != null) await _ctl.addExercise(e);
  }

  Future<void> _finish() async {
    final s = ref.read(gymSessionProvider);
    if (s == null) return;
    final sum = s.summary;
    if (sum.doneSets == 0) {
      gymToast(context, 'Centang minimal satu set dulu.');
      return;
    }
    if (sum.doneSets < sum.totalSets) {
      final ok = await gymConfirm(
        context,
        title: 'Selesai latihan?',
        body:
            '${sum.totalSets - sum.doneSets} set belum dicentang dan tidak akan disimpan.',
        action: 'SELESAI',
      );
      if (!ok) return;
    }
    setState(() => _busy = true);
    final id = await _ctl.finish();
    if (!mounted) return;
    if (id == null) return Navigator.pop(context);
    final integ = ref.read(integrationsProvider);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => integ.activityDetail(id)),
    );
  }

  void _restTick(DateTime? endsAt, DateTime now) {
    if (endsAt == null || now.isBefore(endsAt) || _restBuzzed == endsAt) return;
    _restBuzzed = endsAt;
    HapticFeedback.heavyImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctl.skipRest();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gymSessionProvider);
    final now = ref.watch(gymClockProvider).valueOrNull ?? DateTime.now();
    final prs = ref.watch(gymPrsProvider);
    if (s == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('SESI GYM')),
        body: const Center(child: Text('Tidak ada sesi berjalan.')),
      );
    }
    _restTick(s.restEndsAt, now);
    final rest = s.restEndsAt;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SESI GYM'),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: FN.ok, width: 2),
              ),
              child: Text(
                '● BERJALAN',
                style: FN
                    .label(size: 10, color: FN.ok)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => v == 'rename' ? _rename(s.title) : _discard(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('Ganti nama')),
              PopupMenuItem(value: 'discard', child: Text('Buang sesi')),
            ],
          ),
        ],
      ),
      body: PaperBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  GymSessionHeader(
                    title: s.title,
                    start: s.start,
                    now: now,
                    summary: s.summary,
                    onRename: () => _rename(s.title),
                  ),
                  const SizedBox(height: 16),
                  if (s.exercises.isEmpty) _empty(),
                  for (final (i, e) in s.exercises.indexed) ...[
                    GymExerciseCard(
                      key: ValueKey('ex-$i-${e.exercise.id}'),
                      exercise: e,
                      pr: prs[e.exercise.id],
                      onUpdate: (set, f) => _ctl.updateSet(i, set, f),
                      onToggleDone: (set) => _ctl.toggleDone(i, set),
                      onRemoveSet: (set) => _ctl.removeSet(i, set),
                      onAddSet: () => _ctl.addSet(i),
                      onRemove: () => _ctl.removeExercise(i),
                      onHistory: () => openExerciseHistory(context, e.exercise),
                    ),
                    const SizedBox(height: 14),
                  ],
                  InkButton(
                    label: 'Gerakan',
                    icon: Icons.add,
                    style: InkButtonStyle.outline,
                    expand: true,
                    onPressed: _addExercise,
                  ),
                ],
              ),
            ),
            if (rest != null)
              GymRestBar(
                remainingS: rest.difference(now).inSeconds,
                totalS: s.restTotalS,
                label: s.restLabel,
                onMinus: () => _ctl.adjustRest(-15),
                onPlus: () => _ctl.adjustRest(15),
                onSkip: _ctl.skipRest,
              ),
            Container(
              color: FN.paper,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: SafeArea(
                top: false,
                child: InkButton(
                  label: 'Selesai latihan',
                  icon: Icons.check,
                  style: InkButtonStyle.primary,
                  expand: true,
                  busy: _busy,
                  onPressed: _finish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Column(
      children: [
        Icon(Icons.fitness_center, size: 40, color: FN.inkMuted),
        const SizedBox(height: 10),
        Text('BELUM ADA GERAKAN', style: FN.label(size: 11)),
        const SizedBox(height: 4),
        Text(
          'Tambah gerakan untuk mulai mencatat set.',
          style: TextStyle(fontFamily: FN.sans, color: FN.inkSoft),
        ),
      ],
    ),
  );
}
