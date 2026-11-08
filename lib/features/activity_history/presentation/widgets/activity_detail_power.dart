import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Estimated power, energy and calories (physics model, no power meter).
class ActivityDetailPower extends StatelessWidget {
  final ActivityAnalysis analysis;
  const ActivityDetailPower({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatGrid(
            columns: 3,
            children: [
              StatBlock(
                label: 'Daya rata²',
                value: a.avgPowerW?.round().toString() ?? '–',
                unit: 'W',
                size: 28,
              ),
              StatBlock(
                label: 'Energi',
                value: a.energyKj == null ? '–' : Fmt.number(a.energyKj!),
                unit: 'kJ',
                size: 28,
              ),
              StatBlock(
                label: 'Kalori ≈',
                value: a.energyKj == null
                    ? '–'
                    // ~24% gross efficiency: kJ mech ≈ kcal burned
                    : Fmt.number(a.energyKj! / 4.184 / 0.24),
                unit: 'kcal',
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Estimasi dari model fisika (berat, kemiringan, hambatan '
            'udara & permukaan) — tanpa power meter.',
            style: FN.label(size: 9.5),
          ),
        ],
      ),
    );
  }
}
