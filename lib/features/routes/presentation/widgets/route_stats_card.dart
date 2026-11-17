import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/routes/application/route_builder_controller.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/domain/route_stats.dart';

/// Jarak, total naik, perkiraan waktu, dan tanjakan maksimum.
class RouteStatsCard extends ConsumerWidget {
  const RouteStatsCard({super.key, required this.route});

  final SavedRoute route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = ref.watch(fmtProvider);
    final pace = ref.watch(sportPaceProvider(route.sport)).valueOrNull ??
        SportPace.fallback(route.sport);
    final p = route.path;
    final secs = estimateSeconds(p.distanceM, p.ascentM, pace).round();
    final grade = maxGradePct(p);
    final hasEle = p.ele.any((e) => e.isFinite);
    return InkBox(
      padding: const EdgeInsets.all(12),
      child: StatGrid(
        columns: 2,
        children: [
          StatBlock(
            label: 'Jarak',
            value: fmt.distance(p.distanceM, decimals: 1),
            unit: fmt.distUnit.toLowerCase(),
            size: 26,
          ),
          StatBlock(
            label: 'Total naik',
            value: hasEle ? fmt.elevation(p.ascentM) : '–',
            unit: hasEle ? fmt.eleUnit.toLowerCase() : null,
            size: 26,
          ),
          StatBlock(
            label: 'Perkiraan',
            value: Fmt.durationShort(secs),
            size: 26,
          ),
          StatBlock(
            label: 'Tanjakan maks',
            value: hasEle ? grade.round().toString() : '–',
            unit: hasEle ? '%' : null,
            size: 26,
          ),
        ],
      ),
    );
  }
}
