import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/activity_history/data/journal_providers.dart';
import 'package:virya/features/activity_history/presentation/activity_detail_screen.dart';
import 'package:virya/features/dashboard/domain/stats_math.dart';
import 'package:virya/features/dashboard/presentation/widgets/stats_fitness_panel.dart';
import 'package:virya/features/dashboard/presentation/widgets/stats_records.dart';
import 'package:virya/features/dashboard/presentation/widgets/stats_totals.dart';

export 'package:virya/features/dashboard/application/fitness_timeline_provider.dart';

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
              StatsTotals(activities: list, from: _period.start(now), fmt: fmt),
              SectionHeader(number: sec.next(), title: 'Kebugaran & bentuk'),
              const StatsFitnessPanel(),
              SectionHeader(number: sec.next(), title: 'Kalender 26 minggu'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CalendarHeatStrip(
                  dailyValue: dailySum(list, (a) => a.totalDistanceMeters),
                  weeks: 26,
                ),
              ),
              SectionHeader(number: sec.next(), title: 'Rekor pribadi'),
              StatsRecords(
                activities: list,
                fmt: fmt,
                onOpen: (a) => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ActivityDetailScreen(activityId: a.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _periodPicker() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Row(
      children: [
        for (final p in StatsPeriod.values)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: StampChip(
              text: p.label,
              selected: _period == p,
              onTap: () => setState(() => _period = p),
            ),
          ),
      ],
    ),
  );
}
