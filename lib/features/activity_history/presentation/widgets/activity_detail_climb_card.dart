import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Climb card: grade-colored category block + figures.
class ClimbCard extends StatelessWidget {
  final Climb climb;
  final int index;
  final Fmt fmt;
  const ClimbCard({
    super.key,
    required this.climb,
    required this.index,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final c = climb;
    final color = FN.grade(c.avgGradePct);
    final cat = climbCategoryShort(c.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(border: Border.all(color: FN.ink, width: 1)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 64,
              color: color,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('KAT', style: FN.label(size: 8.5, color: FN.paper)),
                  Text(cat, style: FN.bigNumber(34, color: FN.paper)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TANJAKAN ${index + 1} · ${fmt.distUnit} ${fmt.distance(c.startDistanceM, decimals: 1)} → ${fmt.distance(c.endDistanceM, decimals: 1)}',
                      style: FN.label(size: 9.5),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        StatBlock(
                          label: 'Panjang',
                          value: fmt.distance(c.lengthM),
                          unit: fmt.distUnit,
                          size: 22,
                        ),
                        StatBlock(
                          label: 'Naik',
                          value: fmt.elevation(c.gainM),
                          unit: fmt.eleUnit,
                          size: 22,
                        ),
                        StatBlock(
                          label: 'Rata / maks',
                          value:
                              '${c.avgGradePct.toStringAsFixed(1)}/${c.maxGradePct.toStringAsFixed(0)}',
                          unit: '%',
                          size: 22,
                        ),
                        StatBlock(
                          label: 'VAM',
                          value: Fmt.number(c.vam),
                          unit: 'm/j',
                          size: 22,
                        ),
                        StatBlock(
                          label: 'Waktu',
                          value: Fmt.duration(c.durationS),
                          size: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
