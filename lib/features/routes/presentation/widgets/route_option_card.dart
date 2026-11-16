import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/domain/route_stats.dart';

/// Kartu satu pilihan rute: jarak, naik, perkiraan waktu, dan cirinya.
class RouteOptionCard extends ConsumerWidget {
  const RouteOptionCard({
    super.key,
    required this.candidate,
    required this.pace,
    required this.selected,
    required this.onTap,
  });

  final RouteCandidate candidate;
  final SportPace pace;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = ref.watch(fmtProvider);
    final p = candidate.path;
    final secs = estimateSeconds(p.distanceM, p.ascentM, pace).round();
    return InkBox(
      onTap: onTap,
      borderColor: selected ? FN.signal : null,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: RouteThumbnail(
              points: p.points,
              color: selected ? FN.signal : FN.inkSoft,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(fmt.distance(p.distanceM, decimals: 1),
                        style: FN.bigNumber(24, color: FN.ink)),
                    const SizedBox(width: 4),
                    Text(fmt.distUnit.toLowerCase(),
                        style: FN.label(size: 11, color: FN.inkMuted)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '↑ ${fmt.elevation(p.ascentM)} ${fmt.eleUnit.toLowerCase()}'
                  ' · ± ${Fmt.durationShort(secs)}',
                  style: FN.body(size: 13, color: FN.inkSoft),
                ),
                if (candidate.trait.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    FN.caps(candidate.trait),
                    style: FN.label(
                        size: 11, color: selected ? FN.signal : FN.inkMuted),
                  ),
                ],
              ],
            ),
          ),
          if (selected)
            Icon(Icons.chevron_right, color: FN.signal),
        ],
      ),
    );
  }
}
