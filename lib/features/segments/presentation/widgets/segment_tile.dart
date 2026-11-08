import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/segments/domain/segment_models.dart';

/// Satu baris di daftar segmen.
class SegmentTile extends StatelessWidget {
  final SegmentSummary segment;
  final Fmt fmt;
  final VoidCallback onTap;

  const SegmentTile({
    super.key,
    required this.segment,
    required this.fmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final best = segment.bestS;
    return InkBox(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: RouteThumbnail(points: segment.polyline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  segment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FN.sans,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FN.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${fmt.distanceFull(segment.distanceM, decimals: 2)} · '
                  '${segment.effortCount} upaya',
                  style: FN.label(size: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('REKOR', style: FN.label(size: 9)),
              Text(
                best == null ? '-' : Fmt.duration(best),
                style: FN.label(size: 16, color: FN.ink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
