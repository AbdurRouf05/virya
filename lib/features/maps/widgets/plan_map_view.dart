import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/offline_maps/map_pack_repository.dart';
import 'package:virya/features/maps/domain/route_geometry.dart';
import 'package:virya/features/maps/widgets/route_preview.dart';
import 'package:virya/features/maps/widgets/virya_map_controller.dart';

/// Jenis penanda di [PlanMapView].
enum PlanMarkKind { start, finish, via }

/// Peta perencanaan rute: rute terpilih, alternatif samar, titik bantu, dan
/// ketukan peta ([onTap]). Tanpa WebView (test/desktop) jatuh ke pratinjau.
class PlanMapView extends StatelessWidget {
  const PlanMapView({
    super.key,
    this.route = const [],
    this.ghosts = const [],
    this.marks = const [],
    this.center,
    this.onTap,
    this.interactive = true,
  });

  final List<LatLon> route;
  final List<List<LatLon>> ghosts;
  final List<(LatLon, PlanMarkKind)> marks;

  /// Titik tengah awal bila belum ada rute.
  final LatLon? center;
  final ValueChanged<LatLon>? onTap;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    if (!mapWebViewSupported) return _preview();
    return Consumer(
      builder: (context, ref, _) => ref.watch(mapConfigProvider).maybeWhen(
            data: (c) => _WebPlanMap(
              key: ValueKey(c.toJson().toString()),
              view: this,
              config: c,
            ),
            orElse: _preview,
          ),
    );
  }

  Widget _preview() => RoutePreview(
        points: route,
        currentPosition: route.isEmpty ? center : null,
      );
}

class _WebPlanMap extends StatefulWidget {
  const _WebPlanMap({super.key, required this.view, required this.config});
  final PlanMapView view;
  final MapConfig config;

  @override
  State<_WebPlanMap> createState() => _WebPlanMapState();
}

class _WebPlanMapState extends State<_WebPlanMap> {
  static const _maxPoints = 2500;
  late final ViryaMapController _map;
  StreamSubscription<Map<String, dynamic>>? _sub;

  PlanMapView get v => widget.view;

  @override
  void initState() {
    super.initState();
    final c = v.center ?? (v.route.isEmpty ? null : v.route.first);
    _map = ViryaMapController.create(
      config: widget.config,
      interactive: v.interactive,
      extra: {
        if (c != null) 'center': [c.$2, c.$1],
        'zoom': 13,
      },
    );
    _sub = _map.events.listen(_onEvent);
    _sendRoute(fit: true);
    _sendMarks();
  }

  void _onEvent(Map<String, dynamic> e) {
    if (e['type'] != 'tap') return;
    final lat = (e['lat'] as num?)?.toDouble();
    final lon = (e['lon'] as num?)?.toDouble();
    if (lat != null && lon != null) v.onTap?.call((lat, lon));
  }

  List<List<double>> _coords(List<LatLon> pts) {
    final idx = downsampleIndices(pts, _maxPoints);
    return [for (final i in idx) [pts[i].$1, pts[i].$2]];
  }

  void _sendRoute({required bool fit}) {
    _map.call('setRoute', [_coords(v.route), null, 'plain', false]);
    _map.call('setGhosts', [
      [for (final g in v.ghosts) _coords(g)],
      fit && (v.route.length > 1 || v.ghosts.isNotEmpty),
    ]);
    if (v.route.length < 2 && v.ghosts.isEmpty && v.center != null) {
      _map.call('centerOn', [v.center!.$1, v.center!.$2, 13]);
    }
  }

  void _sendMarks() {
    _map.call('setMarks', [
      [
        for (final (p, k) in v.marks) [p.$1, p.$2, k.name],
      ],
    ]);
  }

  @override
  void didUpdateWidget(_WebPlanMap old) {
    super.didUpdateWidget(old);
    final o = old.view;
    if (!identical(o.route, v.route) || !identical(o.ghosts, v.ghosts)) {
      // Pas ke layar hanya bila rutenya benar-benar baru (bukan edit kecil).
      final fresh = o.route.isEmpty ||
          v.route.isEmpty ||
          !identical(o.ghosts, v.ghosts) && v.ghosts.isNotEmpty;
      _sendRoute(fit: fresh);
    }
    if (!identical(o.marks, v.marks)) _sendMarks();
    if (o.center != v.center && v.route.isEmpty && v.center != null) {
      _map.call('centerOn', [v.center!.$1, v.center!.$2, null]);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ViryaMapWebView(controller: _map, interactive: v.interactive);
}
