import 'dart:math' as math;

enum RecapScene { intro, route, outro }

class RecapFrame {
  final int index;
  final RecapScene scene;

  /// 0..1 progress inside the scene.
  final double local;

  /// Seconds since the scene started.
  final double sceneTimeS;

  /// Tracer progress along the route 0..1.
  final double progress;

  const RecapFrame(
      this.index, this.scene, this.local, this.sceneTimeS, this.progress);
}

/// Deterministic frame → scene mapping for the recap video.
class RecapTimeline {
  final int fps;
  final double introS;
  final double routeS;
  final double outroS;

  /// Tracer reaches the finish at this fraction of the route scene, then holds.
  final double tracerEnd;

  const RecapTimeline({
    this.fps = 30,
    this.introS = 1.5,
    this.routeS = 14,
    this.outroS = 2.5,
    this.tracerEnd = 0.92,
  });

  int get introFrames => (introS * fps).round();
  int get routeFrames => math.max(1, (routeS * fps).round());
  int get outroFrames => (outroS * fps).round();
  int get totalFrames => introFrames + routeFrames + outroFrames;
  double get durationS => totalFrames / fps;

  int get routeStart => introFrames;
  int get outroStart => introFrames + routeFrames;

  RecapFrame at(int i) {
    if (i < introFrames) {
      return RecapFrame(i, RecapScene.intro,
          introFrames <= 1 ? 1 : i / (introFrames - 1), i / fps, 0);
    }
    if (i < outroStart) {
      final k = i - introFrames;
      final local = routeFrames <= 1 ? 1.0 : k / (routeFrames - 1);
      return RecapFrame(i, RecapScene.route, local, k / fps, tracer(local));
    }
    final k = i - outroStart;
    return RecapFrame(i, RecapScene.outro,
        outroFrames <= 1 ? 1 : math.min(1, k / (outroFrames - 1)), k / fps, 1);
  }

  /// Monotonic eased tracer (gentle start/finish), holds 1 after [tracerEnd].
  double tracer(double local) {
    final x = (local / tracerEnd).clamp(0.0, 1.0);
    final ease = x < .5 ? 2 * x * x : 1 - math.pow(-2 * x + 2, 2) / 2;
    return (0.6 * x + 0.4 * ease).clamp(0.0, 1.0);
  }

  /// First global frame whose tracer progress ≥ [p] (route scene).
  int frameAtProgress(double p) {
    if (p <= 0) return routeStart;
    for (var k = 0; k < routeFrames; k++) {
      if (at(routeStart + k).progress >= p) return routeStart + k;
    }
    return outroStart - 1;
  }
}
