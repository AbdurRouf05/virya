import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/activity_history/application/journal_filter.dart';
import 'package:virya/features/activity_history/data/journal_providers.dart';
import 'package:virya/features/activity_history/presentation/activity_detail_screen.dart';
import 'package:virya/features/activity_history/presentation/widgets/journal_empty_state.dart';
import 'package:virya/features/activity_history/presentation/widgets/journal_entry.dart';
import 'package:virya/features/settings/data/data_actions.dart';

export 'package:virya/features/activity_history/application/journal_filter.dart';
export 'package:virya/features/activity_history/presentation/widgets/journal_empty_state.dart';
export 'package:virya/features/activity_history/presentation/widgets/journal_entry.dart';

/// "JURNAL" — activity history as notebook entries grouped by month.
class JournalScreen extends ConsumerStatefulWidget {
  /// `true` saat tampil di dalam tab LATIHAN (judul besar disembunyikan).
  final bool embedded;
  const JournalScreen({super.key, this.embedded = false});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  JournalFilter _filter = JournalFilter.all;

  void _open(String id) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ActivityDetailScreen(activityId: id),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(completedActivitiesProvider);
    final fmt = ref.watch(fmtProvider);
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          bottom: false,
          child: async.when(
            loading: () => const Center(child: _InkSpinner()),
            error: (e, _) => Center(child: Text('Gagal memuat jurnal: $e')),
            data: (all) {
              if (all.isEmpty) return const JournalEmptyState();
              final list = all
                  .where((a) => _filter.matches(sportFromName(a.sportType)))
                  .toList();
              final total = list.fold<double>(
                0,
                (s, a) => s + a.totalDistanceMeters,
              );
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Masthead(
                      kicker: 'Buku catatan lapangan',
                      title: widget.embedded ? null : 'Jurnal',
                      subtitle:
                          '${list.length} entri · ${fmt.distanceFull(total, decimals: 0)} tercatat',
                      actions: [
                        InkIconButton(
                          icon: Icons.upload_file,
                          tooltip: 'Impor riwayat (GPX/TCX/FIT/ZIP Strava)',
                          size: 36,
                          onPressed: () => DataActions.importFile(context, ref),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(child: _filters(all)),
                  ..._monthSlivers(list, fmt),
                  if (list.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Belum ada entri untuk filter ini.',
                          textAlign: TextAlign.center,
                          style: FN.label(size: 12),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 48)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _filters(List<Activity> all) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        children: [
          for (final f in JournalFilter.values)
            if (f == JournalFilter.all ||
                all.any((a) => f.matches(sportFromName(a.sportType))))
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: StampChip(
                  text: f.label,
                  selected: _filter == f,
                  onTap: () => setState(() => _filter = f),
                ),
              ),
        ],
      ),
    );
  }

  List<Widget> _monthSlivers(List<Activity> list, Fmt fmt) {
    final groups = <DateTime, List<Activity>>{};
    for (final a in list) {
      final k = DateTime(a.startTime.year, a.startTime.month);
      (groups[k] ??= []).add(a);
    }
    final out = <Widget>[];
    for (final e in groups.entries) {
      final dist = e.value.fold<double>(0, (s, a) => s + a.totalDistanceMeters);
      out.add(
        SliverToBoxAdapter(
          child: SectionHeader(
            title: Fmt.monthYear(e.key),
            trailing: Text(
              '${e.value.length} · ${fmt.distanceFull(dist, decimals: 0)}'
                  .toUpperCase(),
              style: FN.label(size: 10),
            ),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          ),
        ),
      );
      out.add(
        SliverList.separated(
          itemCount: e.value.length,
          separatorBuilder: (_, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkRule(dashed: true, color: FN.inkMuted),
          ),
          itemBuilder: (_, i) => JournalEntry(
            activity: e.value[i],
            onTap: () => _open(e.value[i].id),
          ),
        ),
      );
    }
    return out;
  }
}

class _InkSpinner extends StatelessWidget {
  const _InkSpinner();
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('MEMBUKA JURNAL…', style: FN.label(size: 11, color: FN.ink)),
      const SizedBox(height: 10),
      const SizedBox(width: 120, child: LinearProgressIndicator()),
    ],
  );
}
