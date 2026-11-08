import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/app/format.dart';
import 'package:stravo/app/settings.dart';
import 'package:stravo/app/sport_ui.dart';
import 'package:stravo/core/analytics/activity_analyzer.dart';
import 'package:stravo/core/analytics/analysis_models.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/widgets/field_kit.dart';
import 'package:stravo/features/activity_history/data/journal_providers.dart';
import 'package:stravo/features/activity_history/presentation/activity_detail_screen.dart';
import 'package:stravo/features/dashboard/domain/stats_math.dart';

/// Fitness timeline (last 90 days) from activities' relative effort.
final fitnessTimelineProvider = Provider<List<FitnessDay>>((ref) {
  final list = ref.watch(completedActivitiesProvider).valueOrNull ?? const [];
  if (list.isEmpty) return const [];
  final today = dayKey(DateTime.now());
  final load = Map<DateTime, double>.of(dailySum(list, (a) => a.relativeEffort));
  if (load.isEmpty) return const [];
  final first = load.keys.reduce((a, b) => a.isBefore(b) ? a : b);
  load.putIfAbsent(dayKey(first.subtract(const Duration(days: 7))), () => 0);
  final all = const ActivityAnalyzer().fitnessTimeline(load, until: today);
  final from = today.subtract(const Duration(days: 89));
  return all.where((d) => !d.day.isBefore(from)).toList();
});

/// "STATISTIK" — totals, fitness & form, calendar, records.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  StatsPeriod _period = StatsPeriod.week;

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(completedActivitiesProvider).valueOrNull ?? const [];
    final fmt = ref.watch(fmtProvider);
    final now = DateTime.now();
    final sec = SectionCounter();
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              Masthead(
                kicker: 'Laporan lapangan',
                title: 'Statistik',
                subtitle:
                    '${list.length} aktivitas · ${Fmt.dateStamp(now, withTime: false)}',
              ),
              SectionHeader(number: sec.next(), title: 'Total'),
              _periodPicker(),
              _totals(list, fmt, now),
              SectionHeader(number: sec.next(), title: 'Kebugaran & bentuk'),
              _fitness(),
              SectionHeader(
                number: sec.next(),
                title: 'Kalender 26 minggu',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CalendarHeatStrip(
                  dailyValue: dailySum(list, (a) => a.totalDistanceMeters),
                  weeks: 26,
                ),
              ),
              SectionHeader(number: sec.next(), title: 'Rekor pribadi'),
              ..._records(list, fmt),
            ],
          ),
        ),
      ),
    );
  }

  Widget _periodPicker() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(children: [
          for (final p in StatsPeriod.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: StampChip(
                text: p.label,
                selected: _period == p,
                onTap: () => setState(() => _period = p),
              ),
            ),
        ]),
      );

  Widget _totals(List<Activity> list, Fmt fmt, DateTime now) {
    final t = totalsByGroup(list, _period.start(now));
    final all = t.values.fold(
        Totals.zero,
        (Totals s, x) => Totals(s.count + x.count, s.distanceM + x.distanceM,
            s.movingS + x.movingS, s.elevationM + x.elevationM));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        InkBox(
          color: FN.ink,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Row(children: [
            Expanded(
              child: StatBlock(
                label: 'Semua olahraga',
                value: fmt.distance(all.distanceM, decimals: 1),
                unit: fmt.distUnit,
                size: 48,
                valueColor: FN.paper,
                labelColor: FN.signal,
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(Fmt.durationShort(all.movingS),
                  style: FN.label(size: 13, color: FN.paper)),
              Text('▲${fmt.elevation(all.elevationM)} ${fmt.eleUnit}',
                  style: FN.label(size: 13, color: FN.paper)),
              Text('${all.count}× AKTIVITAS',
                  style: FN.label(size: 13, color: FN.paper)),
            ]),
          ]),
        ),
        const SizedBox(height: 10),
        for (final g in SportGroup.values)
          _GroupRow(group: g, totals: t[g] ?? Totals.zero, fmt: fmt),
      ]),
    );
  }

  Widget _fitness() {
    final days = ref.watch(fitnessTimelineProvider);
    final last = days.isEmpty ? null : days.last;
    final st = last == null ? null : formStatus(last.form);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (last != null && st != null)
            InkBox(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                MarkLabel(st.title, color: st.color, fontSize: 14),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(st.note,
                          style: const TextStyle(
                              fontFamily: FN.sans,
                              fontSize: 13.5,
                              height: 1.35,
                              color: FN.ink)),
                      const SizedBox(height: 6),
                      Text(
                        'KEBUGARAN ${last.fitness.round()} · '
                        'KELELAHAN ${last.fatigue.round()} · '
                        'BENTUK ${last.form >= 0 ? '+' : ''}${last.form.round()}',
                        style: FN.label(size: 9.5),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          const SizedBox(height: 14),
          FitnessChart(days: days),
        ],
      ),
    );
  }

  List<Widget> _records(List<Activity> list, Fmt fmt) {
    final rides = list.where((a) => sportFromName(a.sportType).isCycling);
    final runs = list.where((a) => sportFromName(a.sportType).isRunning);
    final recs = <PersonalRecord>[
      if (best(rides, (a) => a.totalDistanceMeters) case final a?)
        PersonalRecord('Gowes terjauh', fmt.distance(a.totalDistanceMeters),
            fmt.distUnit, a),
      if (best(runs, (a) => a.totalDistanceMeters) case final a?)
        PersonalRecord('Lari terjauh', fmt.distance(a.totalDistanceMeters),
            fmt.distUnit, a),
      if (best(list, (a) => a.elevationGainMeters) case final a?)
        PersonalRecord('Tanjakan terbanyak',
            fmt.elevation(a.elevationGainMeters), fmt.eleUnit, a),
      if (best(list, (a) => a.gritScore) case final a?)
        PersonalRecord('Grit tertinggi', a.gritScore.round().toString(),
            'grit', a),
      if (best(rides.where((a) => a.totalDistanceMeters >= 5000),
              (a) => a.avgSpeedMps)
          case final a?)
        PersonalRecord('Gowes tercepat', fmt.speed(a.avgSpeedMps),
            fmt.speedUnit, a),
      if (best(runs.where((a) => a.totalDistanceMeters >= 3000),
              (a) => a.avgSpeedMps)
          case final a?)
        PersonalRecord(
            'Lari tercepat', fmt.pace(a.avgSpeedMps), fmt.paceUnit, a),
    ];
    if (recs.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Rekor muncul setelah aktivitas pertamamu.',
              style: FN.label(size: 11)),
        ),
      ];
    }
    return [
      for (final r in recs)
        _RecordRow(
          record: r,
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => ActivityDetailScreen(activityId: r.activity.id))),
        ),
    ];
  }
}

class _GroupRow extends StatelessWidget {
  final SportGroup group;
  final Totals totals;
  final Fmt fmt;
  const _GroupRow(
      {required this.group, required this.totals, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final t = totals;
    final dim = t.count == 0;
    return Opacity(
      opacity: dim ? 0.45 : 1,
      child: Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: FN.ink, width: 1))),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 92,
              child: Text(group.label,
                  style: FN.label(size: 11, color: FN.ink)
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: StatBlock(
                  label: 'Jarak',
                  value: fmt.distance(t.distanceM, decimals: 1),
                  unit: fmt.distUnit,
                  size: 26),
            ),
            Expanded(
              child: StatBlock(
                  label: 'Waktu',
                  value: Fmt.durationShort(t.movingS),
                  size: 18),
            ),
            Expanded(
              child: StatBlock(
                  label: 'Naik',
                  value: fmt.elevation(t.elevationM),
                  unit: fmt.eleUnit,
                  size: 18),
            ),
            SizedBox(
              width: 36,
              child: StatBlock(
                  label: 'n',
                  value: '${t.count}',
                  size: 18,
                  align: CrossAxisAlignment.end),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final PersonalRecord record;
  final VoidCallback onTap;
  const _RecordRow({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = record;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(children: [
          const SizedBox(
            width: 52,
            child: Align(
              alignment: Alignment.centerLeft,
              child: MarkLabel('PR', fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title.toUpperCase(),
                    style: FN.label(size: 10, color: FN.ink)
                        .copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '${r.activity.title} · ${Fmt.dateStamp(r.activity.startTime, withTime: false)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FN.label(size: 9.5),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(r.value, style: FN.bigNumber(28)),
              const SizedBox(width: 3),
              Text(r.unit.toUpperCase(), style: FN.label(size: 9.5)),
            ],
          ),
        ]),
      ),
    );
  }
}
