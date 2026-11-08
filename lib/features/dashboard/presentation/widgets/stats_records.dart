import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/dashboard/domain/stats_math.dart';
import 'package:virya/features/dashboard/presentation/widgets/stats_record_row.dart';

/// Personal records ledger (longest, highest, fastest…).
class StatsRecords extends StatelessWidget {
  final List<Activity> activities;
  final Fmt fmt;
  final ValueChanged<Activity> onOpen;
  const StatsRecords({
    super.key,
    required this.activities,
    required this.fmt,
    required this.onOpen,
  });

  List<PersonalRecord> _records() {
    final list = activities;
    final rides = list.where((a) => sportFromName(a.sportType).isCycling);
    final runs = list.where((a) => sportFromName(a.sportType).isRunning);
    return [
      if (best(rides, (a) => a.totalDistanceMeters) case final a?)
        PersonalRecord(
          'Gowes terjauh',
          fmt.distance(a.totalDistanceMeters),
          fmt.distUnit,
          a,
        ),
      if (best(runs, (a) => a.totalDistanceMeters) case final a?)
        PersonalRecord(
          'Lari terjauh',
          fmt.distance(a.totalDistanceMeters),
          fmt.distUnit,
          a,
        ),
      if (best(list, (a) => a.elevationGainMeters) case final a?)
        PersonalRecord(
          'Tanjakan terbanyak',
          fmt.elevation(a.elevationGainMeters),
          fmt.eleUnit,
          a,
        ),
      if (best(list, (a) => a.gritScore) case final a?)
        PersonalRecord(
          'Grit tertinggi',
          a.gritScore.round().toString(),
          'grit',
          a,
        ),
      if (best(
            rides.where((a) => a.totalDistanceMeters >= 5000),
            (a) => a.avgSpeedMps,
          )
          case final a?)
        PersonalRecord(
          'Gowes tercepat',
          fmt.speed(a.avgSpeedMps),
          fmt.speedUnit,
          a,
        ),
      if (best(
            runs.where((a) => a.totalDistanceMeters >= 3000),
            (a) => a.avgSpeedMps,
          )
          case final a?)
        PersonalRecord(
          'Lari tercepat',
          fmt.pace(a.avgSpeedMps),
          fmt.paceUnit,
          a,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final recs = _records();
    if (recs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Rekor muncul setelah aktivitas pertamamu.',
          style: FN.label(size: 11),
        ),
      );
    }
    return Column(
      children: [
        for (final r in recs)
          StatsRecordRow(record: r, onTap: () => onOpen(r.activity)),
      ],
    );
  }
}
