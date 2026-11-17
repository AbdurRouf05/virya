import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/domain/route_stats.dart';

/// Grafik ketinggian rute rencana.
class RouteElevationCard extends ConsumerWidget {
  const RouteElevationCard({super.key, required this.path});

  final RoutePath path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = ref.watch(fmtProvider);
    final prof = routeProfile(path);
    return InkBox(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(FN.caps('Ketinggian'),
              style: FN.label(size: 11, color: FN.inkMuted)),
          const SizedBox(height: 8),
          if (prof.hasData)
            ElevationProfile(
              distanceM: prof.distanceM,
              ele: prof.ele,
              gradePct: prof.gradePct,
              height: 140,
              formatX: (m) => fmt.distanceFull(m, decimals: 0),
              formatY: (m) =>
                  '${fmt.elevation(m)} ${fmt.eleUnit.toLowerCase()}',
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Data ketinggian tidak tersedia untuk rute ini.',
                  style: FN.body(size: 13, color: FN.inkMuted)),
            ),
        ],
      ),
    );
  }
}
