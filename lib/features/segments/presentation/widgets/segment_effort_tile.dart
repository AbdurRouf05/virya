import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/segments/domain/segment_models.dart';

/// Satu baris riwayat upaya, atau segmen yang dilewati sebuah aktivitas.
class SegmentEffortTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int elapsedS;
  final bool isBest;
  final VoidCallback onTap;

  const SegmentEffortTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.elapsedS,
    required this.isBest,
    required this.onTap,
  });

  factory SegmentEffortTile.effort(
    SegmentEffortRow row, {
    required VoidCallback onTap,
  }) => SegmentEffortTile(
    title: row.activityTitle,
    subtitle: Fmt.dateStamp(row.startedAt),
    elapsedS: row.elapsedS,
    isBest: row.isBest,
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FN.sans,
                      fontSize: 15,
                      color: FN.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: FN.label(size: 10)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (isBest) ...[
              Text('REKOR', style: FN.label(size: 10, color: FN.signal)),
              const SizedBox(width: 8),
            ],
            Text(
              Fmt.duration(elapsedS),
              style: FN.label(size: 15, color: FN.ink),
            ),
          ],
        ),
      ),
    );
  }
}
