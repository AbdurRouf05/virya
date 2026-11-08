import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/core/offline_maps/map_pack_repository.dart';
import 'package:stravo/features/maps/domain/route_geometry.dart';
import 'package:stravo/features/maps/widgets/route_preview.dart';
import 'package:stravo/features/maps/widgets/stravo_map_controller.dart';

/// How the route line is coloured. `values` semantics:
/// speed (any unit), grade (%), surface (`SurfaceType.index`).
enum RouteColorMode { plain, speed, grade, surface }

/// MapLibre (WebView) route map with offline PMTiles. Falls back to a
/// paper-styled painter when no WebView is available.
class RouteMapView extends StatelessWidget {
  const RouteMapView({
    super.key,
    required this.points,
    this.values,
    this.colorMode = RouteColorMode.plain,
    this.enable3d = false,
    this.interactive = true,
    this.live = false,
    this.currentPosition,
    this.bearing,
  });

  final List<(double lat, double lon)> points;
  final List<double>? values;
  final RouteColorMode colorMode;
  final bool enable3d;
  final bool interactive;

  /// Recording mode: points only grow; new ones are appended (throttled).
  final bool live;
  final (double, double)? currentPosition;
  final double? bearing;

  @override
  Widget build(BuildContext context) {
    if (!mapWebViewSupported) return _preview();
    return _ConfigGate(view: this);
  }

  Widget _preview() => RoutePreview(
        points: points,
        colors: routeColors(values, colorMode),
        currentPosition: currentPosition,
        bearing: bearing,
      );
}

class _ConfigGate extends ConsumerWidget {
  const _ConfigGate({required this.view});
  final RouteMapView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(mapConfigProvider);
    return cfg.maybeWhen(
      data: (c) => _WebRouteMap(
        key: ValueKey(c.toJson().toString()),
        view: view,
        config: c,
      ),
      orElse: view._preview,
    );
  }
}

class _WebRouteMap extends StatefulWidget {
  const _WebRouteMap({super.key, required this.view, required this.config});
  final RouteMapView view;
  final MapConfig config;

  @override
  State<_WebRouteMap> createState() => _WebRouteMapState();
}

class _WebRouteMapState extends State<_WebRouteMap> {
  static const _maxStaticPoints = 3000;
  static const _liveThrottle = Duration(milliseconds: 800);

  late final StravoMapController _map;
  int _sent = 0; // live points already sent
  Timer? _flush;
  bool _fitOnce = false;

  RouteMapView get v => widget.view;

  @override
  void initState() {
    super.initState();
    final c = v.currentPosition ?? (v.points.isEmpty ? null : v.points.last);
    _map = StravoMapController.create(
      config: widget.config,
      interactive: v.interactive,
      enable3d: v.enable3d,
      extra: {
        if (c != null) 'center': [c.$2, c.$1],
        'zoom': 14,
      },
    );
    _sendAll();
  }

  void _sendAll() {
    if (v.live) {
      _sent = 0;
      _map.call('setRoute', [<Object>[], null, 'plain', false]);
      _sendLive();
    } else {
      final idx = downsampleIndices(v.points, _maxStaticPoints);
      final coords = [
        for (final i in idx) [v.points[i].$1, v.points[i].$2]
      ];
      final vals = v.values;
      final sel = (vals != null && vals.length == v.points.length)
          ? [for (final i in idx) vals[i].isFinite ? vals[i] : null]
          : null;
      _map.call('setRoute', [coords, sel, v.colorMode.name, true]);
    }
    _sendPosition();
  }

  void _sendLive() {
    _flush?.cancel();
    _flush = null;
    if (v.points.length <= _sent) return;
    final fresh = [
      for (final p in v.points.skip(_sent)) [p.$1, p.$2]
    ];
    _sent = v.points.length;
    _map.call('appendLivePoints', [fresh]);
    if (!_fitOnce && v.currentPosition == null && _sent > 1) {
      _fitOnce = true;
      _map.call('fitRoute', [false]);
    }
  }

  void _sendPosition() {
    final p = v.currentPosition;
    _map.call('setPosition', [p?.$1, p?.$2, v.bearing, v.live]);
  }

  @override
  void didUpdateWidget(_WebRouteMap old) {
    super.didUpdateWidget(old);
    final o = old.view;
    if (o.enable3d != v.enable3d) _map.call('set3d', [v.enable3d]);
    if (v.live != o.live) {
      _sendAll();
      return;
    }
    if (v.live) {
      if (v.points.length < _sent) {
        _sendAll(); // reset (new recording)
      } else if (v.points.length > _sent) {
        _flush ??= Timer(_liveThrottle, () {
          if (mounted) _sendLive();
        });
      }
    } else if (!identical(o.points, v.points) ||
        !identical(o.values, v.values) ||
        o.colorMode != v.colorMode) {
      final same = o.points.length == v.points.length &&
          o.colorMode == v.colorMode &&
          identical(o.values, v.values) &&
          (v.points.isEmpty ||
              (o.points.first == v.points.first &&
                  o.points.last == v.points.last));
      if (!same) _sendAll();
    }
    if (o.currentPosition != v.currentPosition || o.bearing != v.bearing) {
      _sendPosition();
    }
  }

  @override
  void dispose() {
    _flush?.cancel();
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      StravoMapWebView(controller: _map, interactive: v.interactive);
}
