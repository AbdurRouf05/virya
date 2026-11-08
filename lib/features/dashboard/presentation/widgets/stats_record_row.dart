import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/dashboard/domain/stats_math.dart';

/// One personal-record line; tap opens the activity.
class StatsRecordRow extends StatelessWidget {
  final PersonalRecord record;
  final VoidCallback onTap;
  const StatsRecordRow({super.key, required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = record;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            const SizedBox(
              width: 52,
              child: Align(
                alignment: Alignment.centerLeft,
                child: MarkLabel('PR', fontSize: 12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title.toUpperCase(),
                    style: FN
                        .label(size: 10, color: FN.ink)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${r.activity.title} · ${Fmt.dateStamp(r.activity.startTime, withTime: false)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FN.label(size: 9.5),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(r.value, style: FN.bigNumber(28)),
                const SizedBox(width: 3),
                Text(r.unit.toUpperCase(), style: FN.label(size: 9.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
