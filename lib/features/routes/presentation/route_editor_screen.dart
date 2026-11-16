import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/maps/data/current_position.dart';
import 'package:virya/features/maps/widgets/plan_map_view.dart';
import 'package:virya/features/routes/application/route_editor_controller.dart';
import 'package:virya/features/routes/domain/loop_planner.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/presentation/route_detail_screen.dart';

/// Mode edit manual: ketuk peta untuk menambah titik; garis mengikuti jalan.
class RouteEditorScreen extends ConsumerStatefulWidget {
  const RouteEditorScreen({super.key, this.route});

  /// Rute yang diedit; `null` = mulai dari nol.
  final SavedRoute? route;

  @override
  ConsumerState<RouteEditorScreen> createState() => _RouteEditorScreenState();
}

class _RouteEditorScreenState extends ConsumerState<RouteEditorScreen> {
  LatLon? _center;

  RouteEditorController get _c => ref.read(routeEditorProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _c.load(widget.route);
      if (widget.route == null) _locate();
    });
  }

  Future<void> _locate() async {
    try {
      final p = await currentLatLon();
      if (mounted) setState(() => _center = p);
    } catch (_) {
      // Tanpa lokasi: pengguna tetap bisa menggeser peta.
    }
  }

  void _done(RouteEditorState s) {
    final path = s.path;
    if (path.isEmpty) return;
    final src = widget.route;
    final closed = s.stops.length > 2 && s.stops.first == s.stops.last;
    final shape = closed
        ? (src?.shape == RouteShape.outAndBack
            ? RouteShape.outAndBack
            : RouteShape.loop)
        : (src?.shape == RouteShape.pointToPoint
            ? RouteShape.pointToPoint
            : RouteShape.manual);
    if (src != null) {
      Navigator.of(context).pop(src.copyWith(
          path: path, waypoints: s.stops, shape: shape));
      return;
    }
    final r = SavedRoute(
      id: '',
      name: defaultRouteName(shape, s.stops.first, path.points, path.distanceM),
      sport: s.sport,
      shape: shape,
      path: path,
      waypoints: s.stops,
      createdAt: DateTime.now(),
    );
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => RouteDetailScreen(route: r)));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(routeEditorProvider);
    final fmt = ref.watch(fmtProvider);
    final path = s.path;
    final stops = s.stops;
    return Scaffold(
      appBar: AppBar(
        title: Text(FN.caps(widget.route == null ? 'Gambar rute' : 'Edit rute')),
        actions: [
          TextButton(
            onPressed: path.isEmpty || s.busy ? null : () => _done(s),
            child: Text(FN.caps('Selesai')),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                PlanMapView(
                  route: path.points,
                  center: _center ??
                      (stops.isNotEmpty ? stops.first : null),
                  marks: [
                    for (var i = 0; i < stops.length; i++)
                      (
                        stops[i],
                        i == 0
                            ? PlanMarkKind.start
                            : i == stops.length - 1
                                ? PlanMarkKind.finish
                                : PlanMarkKind.via,
                      ),
                  ],
                  onTap: _c.addPoint,
                ),
                if (s.busy)
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.route == null) ...[
                  SegmentedPick<RouteSport>(
                    options: [for (final v in RouteSport.values) (v, v.label)],
                    value: s.sport,
                    onChanged: _c.setSport,
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  stops.isEmpty
                      ? 'Ketuk peta untuk titik mulai.'
                      : path.isEmpty
                          ? 'Ketuk titik berikutnya; garis mengikuti jalan.'
                          : '${fmt.distanceFull(path.distanceM, decimals: 1)}'
                              ' · ↑ ${fmt.elevation(path.ascentM)} '
                              '${fmt.eleUnit.toLowerCase()} · '
                              '${stops.length} titik',
                  style: FN.body(size: 14, color: FN.ink),
                ),
                if (s.error != null) ...[
                  const SizedBox(height: 6),
                  Text(s.error!, style: FN.body(size: 13, color: FN.warn)),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkButton(
                        label: 'Urungkan',
                        icon: Icons.undo,
                        height: 42,
                        expand: true,
                        onPressed: s.canUndo ? _c.undo : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkButton(
                        label: 'Balik ke awal',
                        icon: Icons.loop,
                        height: 42,
                        expand: true,
                        onPressed: s.canClose ? _c.closeLoop : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkButton(
                        label: 'Putar arah',
                        icon: Icons.swap_horiz,
                        height: 42,
                        expand: true,
                        onPressed: s.canReverse ? _c.reverse : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
