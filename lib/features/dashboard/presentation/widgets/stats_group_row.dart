import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/dashboard/domain/stats_math.dart';

/// Per-sport-group totals line (dimmed when empty).
class StatsGroupRow extends StatelessWidget {
  final SportGroup group;
  final Totals totals;
  final Fmt fmt;
  const StatsGroupRow({
    super.key,
    required this.group,
    required this.totals,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final t = totals;
    final dim = t.count == 0;
    return Opacity(
      opacity: dim ? 0.45 : 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: FN.ink, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 92,
              child: Text(
                group.label,
                style: FN
                    .label(size: 11, color: FN.ink)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: StatBlock(
                label: 'Jarak',
                value: fmt.distance(t.distanceM, decimals: 1),
                unit: fmt.distUnit,
                size: 26,
              ),
            ),
            Expanded(
              child: StatBlock(
                label: 'Waktu',
                value: Fmt.durationShort(t.movingS),
                size: 18,
              ),
            ),
            Expanded(
              child: StatBlock(
                label: 'Naik',
                value: fmt.elevation(t.elevationM),
                unit: fmt.eleUnit,
                size: 18,
              ),
            ),
            SizedBox(
              width: 36,
              child: StatBlock(
                label: 'n',
                value: '${t.count}',
                size: 18,
                align: CrossAxisAlignment.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
