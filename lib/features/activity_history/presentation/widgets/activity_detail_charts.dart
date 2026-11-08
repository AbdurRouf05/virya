import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Elevation profile, speed/pace chart and (when [hrNumber] is set) the
/// heart-rate chart, each under its own numbered section header.
class ActivityDetailCharts extends StatelessWidget {
  final ActivityAnalysis analysis;
  final SportType sport;
  final Fmt fmt;
  final String elevationNumber;
  final String speedNumber;
  final String? hrNumber;
  const ActivityDetailCharts({
    super.key,
    required this.analysis,
    required this.sport,
    required this.fmt,
    required this.elevationNumber,
    required this.speedNumber,
    this.hrNumber,
  });

  String _fx(double m) {
    final v = fmt.distanceValue(m);
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    final s = a.series;
    final (avgV, avgU) = fmt.speedOrPace(a.avgSpeedMps, sport);
    const pad = EdgeInsets.symmetric(horizontal: 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          number: elevationNumber,
          title: 'Profil elevasi',
          trailing: Text(
            '▲${fmt.elevation(a.elevationGainM)} ▼${fmt.elevation(a.elevationLossM)} ${fmt.eleUnit}',
            style: FN.label(size: 10, color: FN.ink),
          ),
        ),
        Padding(
          padding: pad,
          child: Column(
            children: [
              ElevationProfile(
                distanceM: s.distanceM,
                ele: s.ele,
                gradePct: s.gradePct,
                marks: [
                  for (final c in a.climbs)
                    if (c.category != ClimbCategory.flat)
                      ChartMark(
                        c.startDistanceM,
                        c.endDistanceM,
                        climbCategoryShort(c.category) == 'HC'
                            ? 'HC'
                            : 'KAT ${climbCategoryShort(c.category)}',
                        color: FN.grade(c.avgGradePct),
                      ),
                ],
                formatX: _fx,
                formatY: (m) => fmt.elevation(m),
              ),
              const SizedBox(height: 10),
              const GradeLegend(),
            ],
          ),
        ),
        SectionHeader(
          number: speedNumber,
          title: sport.isCycling ? 'Kecepatan' : 'Tempo',
          trailing: Text(
            '$avgV ${avgU.toLowerCase()}',
            style: FN.label(size: 10, color: FN.ink),
          ),
        ),
        Padding(
          padding: pad,
          child: sport.isCycling
              ? InkLineChart(
                  x: s.distanceM,
                  y: [for (final v in s.speedMps) fmt.speedValue(v)],
                  average: fmt.speedValue(a.avgSpeedMps),
                  formatY: (v) => v.toStringAsFixed(0),
                  formatX: _fx,
                  color: FN.ink,
                )
              : InkLineChart(
                  x: s.distanceM,
                  y: [for (final v in s.speedMps) v < 0.5 ? null : v],
                  average: a.avgSpeedMps,
                  formatY: fmt.pace,
                  formatX: _fx,
                  clampMin: 1.2,
                ),
        ),
        if (hrNumber != null) ...[
          SectionHeader(
            number: hrNumber,
            title: 'Detak jantung',
            trailing: Text(
              '${a.avgHeartRate ?? '–'} bpm',
              style: FN.label(size: 10, color: FN.ink),
            ),
          ),
          Padding(
            padding: pad,
            child: InkLineChart(
              x: s.distanceM,
              y: [for (final h in s.heartRate) h?.toDouble()],
              color: FN.signal,
              average: a.avgHeartRate?.toDouble(),
              formatY: (v) => v.round().toString(),
              formatX: _fx,
              height: 120,
            ),
          ),
        ],
      ],
    );
  }
}
