import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/application/gym_session_controller.dart';
import 'package:virya/features/gym/application/gym_stats.dart';
import 'package:virya/features/gym/data/gym_providers.dart';
import 'package:virya/features/gym/domain/session_draft.dart';
import 'package:virya/features/gym/presentation/exercise_history_screen.dart';
import 'package:virya/features/gym/presentation/gym_launcher.dart';
import 'package:virya/features/gym/presentation/template_editor_screen.dart';
import 'package:virya/features/gym/presentation/widgets/gym_list_tile.dart';
import 'package:virya/features/gym/presentation/widgets/gym_muscle_status.dart';
import 'package:virya/features/gym/presentation/widgets/gym_volume_bars.dart';

/// Beranda gym (tab LATIHAN → GYM): sesi aktif, mulai, template, volume,
/// otot terlewat, PR, dan sesi terakhir.
class GymHomeScreen extends ConsumerStatefulWidget {
  const GymHomeScreen({super.key});

  @override
  ConsumerState<GymHomeScreen> createState() => _GymHomeScreenState();
}

class _GymHomeScreenState extends ConsumerState<GymHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Pulihkan draf setelah aplikasi ditutup paksa.
    Future.microtask(() => ref.read(gymSessionProvider.notifier).resume());
  }

  Widget _section(String n, String title, {Widget? trailing}) => SectionHeader(
    number: n,
    title: title,
    trailing: trailing,
    padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
  );

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(gymSessionProvider);
    final templates = ref.watch(templatesProvider).valueOrNull ?? const [];
    final lib = ref.watch(exerciseMapProvider);
    final prs = ref.watch(gymPrsProvider);
    final weeks = ref.watch(gymWeeklyVolumeProvider);
    final last = ref.watch(gymLastTrainedProvider);
    final sessions =
        ref.watch(recentGymSessionsProvider).valueOrNull ?? const [];
    final integ = ref.watch(integrationsProvider);
    final prList = prs.entries.where((e) => lib.containsKey(e.key)).toList()
      ..sort((a, b) => b.value.achievedAt.compareTo(a.value.achievedAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
      children: [
        if (active != null) ...[
          InkBox(
            color: FN.night,
            borderColor: FN.night,
            onTap: () => openGymSession(context),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '● SESI BERJALAN',
                        style: FN.label(size: 10, color: FN.acid),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        active.title.toUpperCase(),
                        style: TextStyle(
                          fontFamily: FN.display,
                          fontSize: 22,
                          color: FN.paper,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('LANJUTKAN →', style: FN.label(size: 11, color: FN.acid)),
              ],
            ),
          ),
        ] else
          InkButton(
            label: 'Mulai sesi',
            icon: Icons.fitness_center,
            style: InkButtonStyle.primary,
            expand: true,
            onPressed: () => startGymFlow(context, ref),
          ),
        _section(
          '01',
          'TEMPLATE',
          trailing: GestureDetector(
            onTap: () => openTemplateEditor(context),
            child: Text('+ BUAT', style: FN.label(size: 10.5, color: FN.ink)),
          ),
        ),
        if (templates.isEmpty)
          _hint('Belum ada template. Buat dari sini atau dari sesi selesai.'),
        for (final t in templates)
          GymListTile(
            title: t.name,
            subtitle: t.items.isEmpty
                ? 'KOSONG'
                : t.items
                      .map(
                        (i) =>
                            '${lib[i.exerciseId]?.name ?? '?'} ${i.targetSets}×${i.targetReps}',
                      )
                      .join(' · '),
            trailing: Icons.play_arrow,
            onTap: () => openTemplateEditor(context, template: t),
            onTrailing: active != null
                ? () => openGymSession(context)
                : () => startGymFlow(context, ref, template: t),
          ),
        _section('02', 'VOLUME MINGGUAN'),
        GymVolumeBars(weeks: weeks),
        _section('03', 'OTOT · HARI SEJAK DILATIH'),
        GymMuscleStatus(lastTrained: last, now: DateTime.now()),
        _section('04', 'REKOR PRIBADI'),
        if (prList.isEmpty) _hint('PR muncul setelah sesi pertama selesai.'),
        for (final e in prList.take(8))
          GymListTile(
            title: lib[e.key]!.name,
            subtitle:
                'MAKS ${fmtKg(e.value.maxWeightKg)} KG ×${e.value.maxWeightReps} · '
                'e1RM ${fmtKg(e.value.best1rm.roundToDouble())} KG',
            onTap: () => openExerciseHistory(context, lib[e.key]!),
          ),
        _section('05', 'SESI TERAKHIR'),
        if (sessions.isEmpty) _hint('Belum ada sesi gym.'),
        for (final a in sessions)
          GymListTile(
            title: a.title,
            subtitle:
                '${Fmt.dateStamp(a.startTime.toLocal())} · ${Fmt.duration(a.elapsedTimeSeconds)}',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => integ.activityDetail(a.id)),
            ),
          ),
      ],
    );
  }

  Widget _hint(String t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      t,
      style: TextStyle(fontFamily: FN.sans, color: FN.inkSoft),
    ),
  );
}
