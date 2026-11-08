import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/app/format.dart';
import 'package:stravo/app/settings.dart';
import 'package:stravo/app/sport_ui.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/widgets/field_kit.dart';
import 'package:stravo/features/activity_history/data/journal_providers.dart';
import 'package:stravo/features/activity_history/presentation/activity_detail_screen.dart';
import 'package:stravo/features/settings/data/data_actions.dart';

enum JournalFilter {
  all('SEMUA'),
  gravel('GRAVEL'),
  cycling('SEPEDA'),
  running('LARI'),
  foot('JALAN & HIKING');

  final String label;
  const JournalFilter(this.label);

  bool matches(SportType s) => switch (this) {
        JournalFilter.all => true,
        JournalFilter.gravel => s == SportType.gravelCycling,
        JournalFilter.cycling => s.isCycling,
        JournalFilter.running => s.isRunning,
        JournalFilter.foot => s.group == SportGroup.foot,
      };
}

/// "JURNAL" — activity history as notebook entries grouped by month.
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  JournalFilter _filter = JournalFilter.all;

  void _open(String id) => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ActivityDetailScreen(activityId: id)));

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
              final total =
                  list.fold<double>(0, (s, a) => s + a.totalDistanceMeters);
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Masthead(
                      kicker: 'Buku catatan lapangan',
                      title: 'Jurnal',
                      subtitle:
                          '${list.length} entri · ${fmt.distanceFull(total, decimals: 0)} tercatat',
                      actions: [
                        InkIconButton(
                          icon: Icons.file_download_outlined,
                          tooltip: 'Impor file',
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
                        child: Text('Belum ada entri untuk filter ini.',
                            textAlign: TextAlign.center,
                            style: FN.label(size: 12)),
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
      out.add(SliverToBoxAdapter(
        child: SectionHeader(
          title: Fmt.monthYear(e.key),
          trailing: Text(
            '${e.value.length} · ${fmt.distanceFull(dist, decimals: 0)}'
                .toUpperCase(),
            style: FN.label(size: 10),
          ),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        ),
      ));
      out.add(SliverList.separated(
        itemCount: e.value.length,
        separatorBuilder: (_, _) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: InkRule(dashed: true, color: FN.inkMuted),
        ),
        itemBuilder: (_, i) => JournalEntry(
          activity: e.value[i],
          onTap: () => _open(e.value[i].id),
        ),
      ));
    }
    return out;
  }
}

/// One notebook line: date stamp | text & numbers | route sketch.
class JournalEntry extends ConsumerWidget {
  final Activity activity;
  final VoidCallback? onTap;
  const JournalEntry({super.key, required this.activity, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = activity;
    final fmt = ref.watch(fmtProvider);
    final sport = sportFromName(a.sportType);
    final thumb = ref.watch(routeThumbProvider(a.id));
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateStamp(date: a.startTime),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(sport.icon, size: 13, color: FN.inkMuted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${sport.label} · ${Fmt.time(a.startTime)}',
                        style: FN.label(size: 9.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text(a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: FN.sans,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.2,
                          color: FN.ink)),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(fmt.distance(a.totalDistanceMeters),
                          style: FN.bigNumber(30)),
                      const SizedBox(width: 3),
                      Text(fmt.distUnit, style: FN.label(size: 10)),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          '${Fmt.duration(a.movingTimeSeconds)}  ▲${fmt.elevation(a.elevationGainMeters)}${fmt.eleUnit.toLowerCase()}',
                          overflow: TextOverflow.ellipsis,
                          style: FN.label(size: 11, color: FN.ink),
                        ),
                      ),
                    ],
                  ),
                  if (a.gravelPercentage > 0.5) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      Expanded(
                          child: GravelShareBar(gravelPct: a.gravelPercentage)),
                      const SizedBox(width: 8),
                      Text('GRAVEL ${a.gravelPercentage.round()}%',
                          style: FN.label(size: 9.5, color: FN.ink)),
                    ]),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: FN.paper,
                border: Border.all(color: FN.ink, width: 1),
              ),
              child: thumb.maybeWhen(
                data: (pts) => pts.length < 2
                    ? const Center(child: Text('—'))
                    : RouteThumbnail(points: pts, strokeWidth: 1.4),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateStamp extends StatelessWidget {
  final DateTime date;
  const _DateStamp({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      decoration: BoxDecoration(border: Border.all(color: FN.ink, width: 1.2)),
      child: Column(children: [
        Container(
          width: double.infinity,
          color: FN.ink,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(Fmt.daysShort[date.weekday - 1],
              textAlign: TextAlign.center,
              style: FN.label(size: 9, color: FN.paper)
                  .copyWith(fontWeight: FontWeight.w700)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(date.day.toString().padLeft(2, '0'),
              style: FN.bigNumber(26)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(Fmt.monthsShort[date.month - 1],
              style: FN.label(size: 8.5)),
        ),
      ]),
    );
  }
}

/// Empty notebook: contour page with demo/import buttons.
class JournalEmptyState extends ConsumerStatefulWidget {
  const JournalEmptyState({super.key});

  @override
  ConsumerState<JournalEmptyState> createState() => _JournalEmptyStateState();
}

class _JournalEmptyStateState extends ConsumerState<JournalEmptyState> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() f) async {
    setState(() => _busy = true);
    try {
      await f();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaperBackground(
      texture: PaperTexture.contours,
      seed: 11,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        children: [
          Text('JURNAL · HALAMAN 001',
              style: FN.label(size: 10, color: FN.signal)
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const Text('HALAMAN\nMASIH\nKOSONG.',
              style: TextStyle(
                  fontFamily: FN.display,
                  fontSize: 64,
                  height: 0.95,
                  color: FN.ink)),
          const SizedBox(height: 16),
          Container(height: 3, color: FN.ink),
          const SizedBox(height: 16),
          const Text(
            'Belum ada catatan perjalanan. Tekan REKAM untuk memulai, '
            'impor riwayat lama (GPX, TCX, FIT, atau ZIP ekspor Strava), '
            'atau muat rute demo gravel untuk melihat semua fitur.',
            style: TextStyle(
                fontFamily: FN.sans, fontSize: 15, height: 1.45, color: FN.ink),
          ),
          const SizedBox(height: 28),
          InkButton(
            label: 'Muat rute demo',
            icon: Icons.route,
            style: InkButtonStyle.primary,
            expand: true,
            busy: _busy,
            onPressed: () => _run(() async {
              await DataActions.loadDemo(context, ref);
            }),
          ),
          const SizedBox(height: 14),
          InkButton(
            label: 'Impor file',
            icon: Icons.file_download_outlined,
            expand: true,
            onPressed: _busy
                ? null
                : () => _run(() async {
                      await DataActions.importFile(context, ref);
                    }),
          ),
        ],
      ),
    );
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
