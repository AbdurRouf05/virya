import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Grit score (0–100) with verdict word and bar.
class ActivityDetailGritPanel extends StatelessWidget {
  final double score;
  const ActivityDetailGritPanel({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final s = score.clamp(0, 100).toDouble();
    final word = s >= 75
        ? 'BRUTAL'
        : s >= 50
        ? 'KERAS'
        : s >= 25
        ? 'SEDANG'
        : 'RINGAN';
    return InkBox(
      color: FN.paperDeep,
      child: Row(
        children: [
          Text(s.round().toString(), style: FN.bigNumber(48, color: FN.signal)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GRIT SCORE · $word',
                  style: FN
                      .label(size: 11, color: FN.ink)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gabungan porsi gravel, kekasaran getaran, dan tanjakan di '
                  'permukaan lepas. 0 = aspal mulus, 100 = neraka makadam.',
                  style: FN.label(size: 9.5),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (_, c) => Stack(
                    children: [
                      Container(height: 6, color: FN.paperLine),
                      Container(
                        height: 6,
                        width: c.maxWidth * s / 100,
                        color: FN.ink,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
