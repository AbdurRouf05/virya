import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/calendar/domain/calendar_stats.dart';

/// Three boxed numbers: current streak, longest streak, % active days.
class CalendarStatsRow extends StatelessWidget {
  final CalendarStats stats;

  const CalendarStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: FN.frame(color: FN.ink, width: 2), borderRadius: FN.boxRadius,),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Cell(value: '${stats.currentStreak}', label: FN.caps('Streak · hari')),
            VerticalDivider(width: 2, thickness: 2, color: FN.ink),
            _Cell(value: '${stats.longestStreak}', label: FN.caps('Terpanjang')),
            VerticalDivider(width: 2, thickness: 2, color: FN.ink),
            _Cell(
              value: '${stats.activePercent}',
              unit: '%',
              label: FN.caps('Hari aktif'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final String? unit;
  final String label;

  const _Cell({required this.value, required this.label, this.unit});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: FN.bigNumber(40)),
                if (unit != null)
                  Text(unit!, style: FN.bigNumber(20, color: FN.inkSoft)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FN.label(size: 9.5, color: FN.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
