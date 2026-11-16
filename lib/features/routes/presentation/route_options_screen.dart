import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/maps/widgets/plan_map_view.dart';
import 'package:virya/features/routes/application/route_builder_controller.dart';
import 'package:virya/features/routes/domain/loop_planner.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/domain/route_stats.dart';
import 'package:virya/features/routes/presentation/route_flow.dart';
import 'package:virya/features/routes/presentation/widgets/route_option_card.dart';

/// Langkah 2 "Buat rute": tiga pilihan di peta (terpilih menyala, lainnya
/// samar). Ketuk pilihan yang menyala untuk melihat detail.
class RouteOptionsScreen extends ConsumerWidget {
  const RouteOptionsScreen({super.key});

  static SavedRoute toSaved(RouteCandidate c, RoutePrefs p) => SavedRoute(
        id: '',
        name: defaultRouteName(
            c.shape, p.start ?? c.path.points.first, c.path.points,
            c.path.distanceM),
        sport: p.sport,
        shape: c.shape,
        path: c.path,
        waypoints: c.waypoints,
        createdAt: DateTime.now(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(routeBuilderProvider);
    final c = ref.read(routeBuilderProvider.notifier);
    final fmt = ref.watch(fmtProvider);
    final pace = ref.watch(sportPaceProvider(s.prefs.sport)).valueOrNull ??
        SportPace.fallback(s.prefs.sport);
    final list = s.candidates;
    final sel = s.current;
    final title = s.prefs.shape == RouteShape.pointToPoint
        ? '${list.length} pilihan · ${s.prefs.shape.label}'
        : '${list.length} pilihan · ${s.prefs.shape.label.toLowerCase()} '
            '${fmt.distanceFull(s.prefs.targetM, decimals: 0)}';
    void open(RouteCandidate cand) => RouteFlow.openDetail(
        context, toSaved(cand, s.prefs),
        trait: cand.trait);

    return Scaffold(
      appBar: AppBar(title: Text(FN.caps('Pilih rute'))),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: PlanMapView(
              route: sel?.path.points ?? const [],
              ghosts: [
                for (final o in list)
                  if (!identical(o, sel)) o.path.points,
              ],
              marks: [
                if (s.prefs.start != null)
                  (s.prefs.start!, PlanMarkKind.start),
              ],
              center: s.prefs.start,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: FN.heading(size: 16, color: FN.ink)),
                    ),
                    TextButton.icon(
                      onPressed: s.loading ? null : c.generate,
                      icon: s.loading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.refresh, size: 18, color: FN.inkSoft),
                      label: Text(FN.caps('Acak lagi'),
                          style: FN.label(size: 11, color: FN.inkSoft)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (s.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(s.error!,
                        style: FN.body(size: 13, color: FN.warn)),
                  ),
                for (var i = 0; i < list.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RouteOptionCard(
                      candidate: list[i],
                      pace: pace,
                      selected: identical(list[i], sel),
                      onTap: () => identical(list[i], sel)
                          ? open(list[i])
                          : c.select(i),
                    ),
                  ),
                if (sel != null) ...[
                  const SizedBox(height: 4),
                  InkButton(
                    label: 'Lihat detail',
                    icon: Icons.arrow_forward,
                    style: InkButtonStyle.primary,
                    expand: true,
                    onPressed: () => open(sel),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  pace.fromHistory
                      ? 'Perkiraan waktu dari kecepatan rata-ratamu '
                          '(${fmt.speed(pace.speedMps)} '
                          '${fmt.speedUnit.toLowerCase()})'
                      : 'Perkiraan waktu memakai kecepatan umum '
                          '(${fmt.speed(pace.speedMps)} '
                          '${fmt.speedUnit.toLowerCase()})',
                  textAlign: TextAlign.center,
                  style: FN.body(size: 12, color: FN.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
