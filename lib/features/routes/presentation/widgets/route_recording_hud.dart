import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/recording/application/recording_controller.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/routes/application/route_guidance.dart';
import 'package:virya/features/routes/data/route_providers.dart';
import 'package:virya/features/routes/presentation/route_flow.dart';

/// Strip rute di layar rekam: "Ikuti rute" sebelum mulai, lalu sisa jarak
/// dan peringatan keluar rute selama merekam.
class RouteRecordingHud extends ConsumerWidget {
  const RouteRecordingHud({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final flag = ref.read(routesFromRecordingProvider.notifier);
    flag.state = true;
    try {
      await RouteFlow.openHome(context);
    } finally {
      flag.state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(routeGuidanceProvider);
    final phase = ref.watch(recordingControllerProvider.select((s) => s.phase));
    final idle = phase == RecordingPhase.idle;
    if (g == null) {
      if (!idle) return const SizedBox.shrink();
      return InkWell(
        onTap: () => _pick(context, ref),
        child: Container(
          height: 40,
          color: FN.nightSurface,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(Icons.route, size: 18, color: FN.onNightMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(FN.caps('Ikuti rute'),
                    style: FN.label(size: 11, color: FN.onNight)),
              ),
              Icon(Icons.chevron_right, size: 18, color: FN.onNightMuted),
            ],
          ),
        ),
      );
    }
    final fmt = ref.watch(fmtProvider);
    final off = g.offRoute;
    final color = off ? FN.warn : FN.onNight;
    final kicker = off
        ? 'Keluar dari rute · ${g.offsetM.round()} m'
        : g.tracking
            ? 'Mengikuti rute'
            : 'Rute siap';
    return Container(
      height: 56,
      color: FN.nightSurface,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 4),
              child: Row(
                children: [
                  Icon(off ? Icons.wrong_location_outlined : Icons.route,
                      size: 18, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(FN.caps(kicker),
                            style: FN.label(size: 10, color: off
                                ? FN.warn
                                : FN.onNightMuted)),
                        const SizedBox(height: 2),
                        Text(g.route.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FN.heading(size: 14, color: FN.onNight)),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(fmt.distanceFull(g.remainingM, decimals: 1),
                          style: FN.label(size: 18, color: color)),
                      Text(FN.caps('Sisa'),
                          style: FN.label(size: 9, color: FN.onNightMuted)),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Lepas rute',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close, size: 18, color: FN.onNightMuted),
                    onPressed: () =>
                        ref.read(activeRouteProvider.notifier).state = null,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: g.fraction,
                heightFactor: 1,
                child: ColoredBox(color: off ? FN.warn : FN.signal),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
