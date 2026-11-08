import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// "Ringkasan" stat grid: distance, time, climbing, speed, HR, effort…
class ActivityDetailSummary extends StatelessWidget {
  final ActivityAnalysis analysis;
  final SportType sport;
  final Fmt fmt;
  const ActivityDetailSummary({
    super.key,
    required this.analysis,
    required this.sport,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    final (avgV, avgU) = fmt.speedOrPace(a.avgSpeedMps, sport);
    final (maxV, maxU) = fmt.speedOrPace(a.maxSpeedMps, sport);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StatGrid(
        children: [
          StatBlock(
            label: 'Jarak',
            value: fmt.distance(a.distanceM),
            unit: fmt.distUnit,
            size: 46,
          ),
          StatBlock(
            label: 'Waktu bergerak',
            value: Fmt.duration(a.movingTimeS),
            size: 46,
          ),
          StatBlock(
            label: 'Tanjakan',
            value: fmt.elevation(a.elevationGainM),
            unit: fmt.eleUnit,
            size: 34,
          ),
          StatBlock(
            label: sport.isCycling ? 'Kec. rata-rata' : 'Tempo rata-rata',
            value: avgV,
            unit: avgU,
            size: 34,
          ),
          StatBlock(
            label: 'Waktu total',
            value: Fmt.duration(a.elapsedTimeS),
            size: 24,
          ),
          StatBlock(
            label: sport.isCycling ? 'Kec. maks' : 'Tempo terbaik',
            value: maxV,
            unit: maxU,
            size: 24,
          ),
          if (a.avgGapMps != null)
            StatBlock(
              label: 'GAP',
              value: fmt.pace(a.avgGapMps!),
              unit: fmt.paceUnit,
              size: 24,
            ),
          StatBlock(
            label: 'Elev maks',
            value: fmt.elevation(a.maxEleM),
            unit: fmt.eleUnit,
            size: 24,
          ),
          if (a.avgHeartRate != null)
            StatBlock(
              label: 'HR rata / maks',
              value: '${a.avgHeartRate}/${a.maxHeartRate ?? '–'}',
              unit: 'bpm',
              size: 24,
            ),
          if (a.avgCadence != null)
            StatBlock(
              label: 'Kadens',
              value: '${a.avgCadence}',
              unit: sport.isCycling ? 'rpm' : 'spm',
              size: 24,
            ),
          StatBlock(
            label: 'Upaya relatif',
            value: a.relativeEffort.round().toString(),
            size: 24,
          ),
          if (a.gritScore > 0)
            StatBlock(
              label: 'Grit',
              value: a.gritScore.round().toString(),
              unit: '/100',
              size: 24,
            ),
        ],
      ),
    );
  }
}
