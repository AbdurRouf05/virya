import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Classic-race style "Secteur" card for a gravel sector.
class GravelSectorCard extends StatelessWidget {
  final GravelSector sector;
  final Fmt fmt;
  const GravelSectorCard({super.key, required this.sector, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final s = sector;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: FN.paper,
        border: Border.fromBorderSide(BorderSide(color: FN.ink, width: 2)),
        boxShadow: [BoxShadow(color: FN.ink, offset: const Offset(3, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: FN.ink,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Text('SEKTOR', style: FN.label(size: 10, color: FN.paper)),
                const SizedBox(width: 8),
                Text('${s.number}', style: FN.bigNumber(30, color: FN.paper)),
                const Spacer(),
                StarRating(stars: s.stars, size: 16, emptyColor: FN.inkMuted),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  style: TextStyle(
                    fontFamily: FN.sans,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: FN.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${fmt.distUnit} ${fmt.distance(s.startDistanceM, decimals: 1)} → ${fmt.distance(s.endDistanceM, decimals: 1)}',
                  style: FN.label(size: 10),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: StatBlock(
                        label: 'Panjang',
                        value: fmt.distance(s.lengthM),
                        unit: fmt.distUnit,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: StatBlock(
                        label: 'Tanjakan',
                        value: s.avgGradePct.toStringAsFixed(1),
                        unit: '%',
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: StatBlock(
                        label: 'Kekasaran',
                        value: s.roughness.toStringAsFixed(1),
                        unit: 'm/s²',
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: FN.surface[s.dominantSurface],
                        border: Border.all(color: FN.ink, width: 0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.dominantSurface.label.toUpperCase(),
                      style: FN.label(size: 10, color: FN.ink),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
