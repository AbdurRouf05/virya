import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:virya/core/data/activity_repository.dart';
import 'package:virya/core/offline_maps/map_pack_repository.dart';
import 'package:virya/features/maps/domain/flyover_plan.dart';
import 'package:virya/features/maps/widgets/virya_map_controller.dart';

/// Flyover playback state: drives the WebView flyover (when available) or a
/// Flutter [Ticker] fallback, and mirrors position/play state for the HUD.
class FlyoverPlayback extends ChangeNotifier {
  FlyoverPlayback(TickerProvider vsync, {required this.baseDuration}) {
    _ticker = vsync.createTicker(_onTick);
  }

  /// Seconds for a full flight at 1×.
  final double baseDuration;

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  ViryaMapController? _map;
  StreamSubscription<Map<String, dynamic>>? _sub;

  ViryaMapController? get map => _map;
  bool flyReady = false;
  double u = 0;
  bool playing = false;
  double speed = 1;
  bool is3d = true;

  /// While true, WebView `progress` events are ignored (export drives frames).
  bool exporting = false;

  /// Creates the WebView map once and loads [plan] into it.
  void ensureMap(MapConfig cfg, FlyoverPlan plan, ActivityBundle b) {
    if (_map != null || !mapWebViewSupported || plan.isEmpty) return;
    final m = ViryaMapController.create(
      config: cfg,
      interactive: false,
      enable3d: is3d,
      extra: {
        'center': [plan.frames.first.lon, plan.frames.first.lat],
        'zoom': plan.frames.first.zoom,
      },
    );
    _map = m;
    _sub = m.events.listen(_onEvent);
    m.call('flySetDuration', [baseDuration]);
    m.call('flySetSpeed', [speed]);
    m.call('flyLoad', [plan.toJson()]);
    if (b.photos.isNotEmpty) {
      m.call('setPhotos', [
        for (final ph in b.photos) {'lat': ph.latitude, 'lon': ph.longitude},
      ]);
    }
  }

  void _onEvent(Map<String, dynamic> e) {
    switch (e['type']) {
      case 'flyLoaded':
        flyReady = true;
        notifyListeners();
      case 'progress':
        if (exporting) return;
        u = (e['u'] as num).toDouble();
        playing = e['playing'] == true;
        notifyListeners();
      case 'ended':
        playing = false;
        u = 1;
        notifyListeners();
    }
  }

  void togglePlay() {
    final play = !playing;
    playing = play;
    if (play && u >= 1) u = 0;
    notifyListeners();
    if (_map != null) {
      _map!.call(play ? 'flyPlay' : 'flyPause');
    } else if (play) {
      _lastTick = Duration.zero;
      if (!_ticker.isActive) _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero
        ? 0.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final next = (u + dt * speed / baseDuration).clamp(0.0, 1.0);
    u = next;
    if (next >= 1) {
      playing = false;
      _ticker.stop();
    }
    notifyListeners();
  }

  void seek(double v) {
    u = v;
    notifyListeners();
    _map?.call('flySeek', [v]);
  }

  void setSpeed(double s) {
    speed = s;
    notifyListeners();
    _map?.call('flySetSpeed', [s]);
  }

  void toggle3d() {
    is3d = !is3d;
    notifyListeners();
    _map?.call('set3d', [is3d]);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sub?.cancel();
    _map?.dispose();
    super.dispose();
  }
}
