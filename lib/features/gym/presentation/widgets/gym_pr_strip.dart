import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/domain/gym_math.dart';
import 'package:virya/features/gym/domain/session_draft.dart';

/// Tiga blok PR: beban maks, e1RM (Epley), set terbaik.
class GymPrStrip extends StatelessWidget {
  final ExercisePr pr;
  const GymPrStrip({super.key, required this.pr});

  @override
  Widget build(BuildContext context) {
    return InkBox(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: StatBlock(
              label: 'Beban maks',
              value: fmtKg(pr.maxWeightKg),
              unit: 'KG ×${pr.maxWeightReps}',
              size: 28,
            ),
          ),
          Expanded(
            child: StatBlock(
              label: 'e1RM',
              value: fmtKg(pr.best1rm.roundToDouble()),
              unit: 'KG',
              size: 28,
            ),
          ),
          Expanded(
            child: StatBlock(
              label: 'Set terbaik',
              value: '${fmtKg(pr.bestSetWeightKg)}×${pr.bestSetReps}',
              unit: Fmt.number(pr.bestSetVolume),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
