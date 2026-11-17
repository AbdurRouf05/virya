import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/features/recording/application/recording_controller.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/routes/data/route_providers.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/domain/route_progress.dart';
import 'package:virya/services/audio_cues/audio_cue_service.dart';

/// Keadaan mengikuti rute untuk HUD di layar rekam.
class RouteGuidance {
  final SavedRoute route;
  final double remainingM;
  final double offsetM;
  final bool offRoute;

  /// `true` setelah ada fix GPS yang terproyeksi ke rute.
  final bool tracking;

  const RouteGuidance({
    required this.route,
    required this.remainingM,
    this.offsetM = 0,
    this.offRoute = false,
    this.tracking = false,
  });

  double get fraction => route.path.distanceM <= 0
      ? 0
      : (1 - remainingM / route.path.distanceM).clamp(0.0, 1.0);
}

/// Mengikuti posisi perekaman terhadap [activeRouteProvider]: sisa jarak dan
/// peringatan keluar rute (getar + suara). Tidak menyentuh pengendali rekam.
class RouteGuidanceController extends Notifier<RouteGuidance?> {
  RouteTracker? _tracker;
  final OffRouteMonitor _monitor = OffRouteMonitor();
  DateTime? _lastFix;

  @override
  RouteGuidance? build() {
    final route = ref.watch(activeRouteProvider);
    _monitor.reset();
    _lastFix = null;
    ref.listen<RecordingState>(recordingControllerProvider, _onRecording);
    if (route == null || route.path.isEmpty) {
      _tracker = null;
      return null;
    }
    _tracker = RouteTracker(route.path.points);
    return RouteGuidance(route: route, remainingM: route.path.distanceM);
  }

  void _onRecording(RecordingState? prev, RecordingState next) {
    final wasActive = prev != null && prev.phase != RecordingPhase.idle;
    if (wasActive && next.phase == RecordingPhase.idle) {
      // Sesi selesai/dibuang: rute dilepas supaya sesi berikut bersih.
      ref.read(activeRouteProvider.notifier).state = null;
      return;
    }
    final g = state;
    final tracker = _tracker;
    final s = next.snapshot;
    if (g == null || tracker == null) return;
    if (next.phase != RecordingPhase.recording || !s.hasFix) return;
    if (_lastFix == s.timestamp) return;
    _lastFix = s.timestamp;
    final fix = tracker.update((s.latitude, s.longitude));
    if (fix == null) return;
    final ev = _monitor.update(fix.offsetM, s.timestamp);
    if (ev != null) _cue(ev);
    state = RouteGuidance(
      route: g.route,
      remainingM: fix.remainingM,
      offsetM: fix.offsetM,
      offRoute: _monitor.isOff,
      tracking: true,
    );
  }

  void _cue(OffRouteEvent ev) {
    final left = ev == OffRouteEvent.left;
    try {
      if (left) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }
      ref
          .read(audioCueServiceProvider)
          .announce(left ? 'Kamu keluar dari rute' : 'Kembali di rute');
    } catch (_) {
      // Umpan balik bersifat tambahan; jangan ganggu perekaman.
    }
  }
}

final routeGuidanceProvider =
    NotifierProvider<RouteGuidanceController, RouteGuidance?>(
        RouteGuidanceController.new);
