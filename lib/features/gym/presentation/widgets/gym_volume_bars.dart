import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Batang volume mingguan (lama → baru); minggu ini diberi warna sinyal.
class GymVolumeBars extends StatelessWidget {
  final List<(DateTime, double)> weeks;
  const GymVolumeBars({super.key, required this.weeks});

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) return const SizedBox.shrink();
    final max = weeks.map((w) => w.$2).fold<double>(0, (a, b) => b > a ? b : a);
    final current = weeks.last.$2;
    return InkBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: StatBlock(
                  label: 'Minggu ini',
                  value: Fmt.number(current),
                  unit: 'KG',
                  size: 28,
                ),
              ),
              Text('${weeks.length} MINGGU', style: FN.label(size: 9.5)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (i, w) in weeks.indexed)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: max <= 0
                            ? 0.02
                            : (w.$2 / max).clamp(0.02, 1.0),
                        child: Container(
                          color: i == weeks.length - 1 ? FN.signal : FN.ink,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final w in weeks)
                Expanded(
                  child: Text(
                    '${w.$1.day}/${w.$1.month}',
                    textAlign: TextAlign.center,
                    style: FN.label(size: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
