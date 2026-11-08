import 'dart:math' as math;

import 'package:flutter/material.dart' hide Split;
import 'package:virya/app/format.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_table_styles.dart';

/// Per-km splits with a proportional tempo bar.
class SplitsTable extends StatelessWidget {
  final List<Split> splits;
  final SportType sport;
  final Fmt fmt;
  const SplitsTable({
    super.key,
    required this.splits,
    required this.sport,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final showGap = sport.isRunning && splits.any((s) => s.gapMps != null);
    final showHr = splits.any((s) => s.avgHeartRate != null);
    final speeds = splits.map((s) => s.speedMps).toList();
    final maxS = speeds.fold<double>(0, (a, b) => math.max(a, b));
    final minS = speeds.fold<double>(double.infinity, (a, b) => math.min(a, b));
    final fastest = speeds.indexOf(maxS);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(width: 34, child: Text(fmt.distUnit, style: detailTh())),
              SizedBox(
                width: 56,
                child: Text(
                  sport.isCycling ? fmt.speedUnit : 'TEMPO',
                  style: detailTh(),
                ),
              ),
              const Expanded(child: SizedBox()),
              SizedBox(
                width: 50,
                child: Text(
                  'ELEV',
                  style: detailTh(),
                  textAlign: TextAlign.right,
                ),
              ),
              if (showHr)
                SizedBox(
                  width: 40,
                  child: Text(
                    'HR',
                    style: detailTh(),
                    textAlign: TextAlign.right,
                  ),
                ),
              if (showGap)
                SizedBox(
                  width: 48,
                  child: Text(
                    'GAP',
                    style: detailTh(),
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
        ),
        const InkRule(),
        for (var i = 0; i < splits.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    '${splits[i].index}',
                    style: detailTd(color: FN.inkMuted),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    fmt.speedOrPace(splits[i].speedMps, sport).$1,
                    style: detailTd(
                      bold: i == fastest,
                      color: i == fastest ? FN.signal : FN.ink,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final range = math.max(maxS - minS, 0.01);
                      final f =
                          0.25 + 0.75 * ((splits[i].speedMps - minS) / range);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 10,
                          width: c.maxWidth * f.clamp(0.05, 1.0),
                          color: i == fastest ? FN.signal : FN.ink,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${splits[i].elevationDeltaM >= 0 ? '+' : ''}${fmt.elevation(splits[i].elevationDeltaM)}',
                    textAlign: TextAlign.right,
                    style: detailTd(),
                  ),
                ),
                if (showHr)
                  SizedBox(
                    width: 40,
                    child: Text(
                      splits[i].avgHeartRate?.toString() ?? '–',
                      textAlign: TextAlign.right,
                      style: detailTd(),
                    ),
                  ),
                if (showGap)
                  SizedBox(
                    width: 48,
                    child: Text(
                      splits[i].gapMps == null
                          ? '–'
                          : fmt.pace(splits[i].gapMps!),
                      textAlign: TextAlign.right,
                      style: detailTd(),
                    ),
                  ),
              ],
            ),
          ),
          if (i < splits.length - 1) InkRule(dashed: true, color: FN.paperLine),
        ],
      ],
    );
  }
}
