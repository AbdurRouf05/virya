import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/dashboard/domain/stats_math.dart';
import 'package:virya/features/dashboard/presentation/widgets/stats_group_row.dart';

/// Overall total box + one row per sport group, since [from].
class StatsTotals extends StatelessWidget {
  final List<Activity> activities;
  final DateTime from;
  final Fmt fmt;
  const StatsTotals({
    super.key,
    required this.activities,
    required this.from,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final t = totalsByGroup(activities, from);
    final all = t.values.fold(
      Totals.zero,
      (Totals s, x) => Totals(
        s.count + x.count,
        s.distanceM + x.distanceM,
        s.movingS + x.movingS,
        s.elevationM + x.elevationM,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          InkBox(
            color: FN.ink,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: StatBlock(
                    label: 'Semua olahraga',
                    value: fmt.distance(all.distanceM, decimals: 1),
                    unit: fmt.distUnit,
                    size: 48,
                    valueColor: FN.paper,
                    labelColor: FN.onInk(FN.signal),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Fmt.durationShort(all.movingS),
                      style: FN.label(size: 13, color: FN.paper),
                    ),
                    Text(
                      '▲${fmt.elevation(all.elevationM)} ${fmt.eleUnit}',
                      style: FN.label(size: 13, color: FN.paper),
                    ),
                    Text(
                      '${all.count}× AKTIVITAS',
                      style: FN.label(size: 13, color: FN.paper),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (final g in SportGroup.values)
            StatsGroupRow(group: g, totals: t[g] ?? Totals.zero, fmt: fmt),
        ],
      ),
    );
  }
}
