import 'dart:math' as math;

import 'package:virya/features/maps/domain/route_geometry.dart';

/// One camera keyframe of the flyover timeline (u = 0..1 playback position).
class FlyKeyframe {
  final double u;
  final double lat, lon;
  final double bearing; // unwrapped degrees
  final double pitch;
  final double zoom;
  final double overview; // 0 = follow cam, 1 = whole-route overview
  final double progress; // 0..1 fraction of route revealed
  final double distM, eleM, speedKmh, gradePct, elapsedS;

  const FlyKeyframe({
    required this.u,
    required this.lat,
    required this.lon,
    required this.bearing,
    required this.pitch,
    required this.zoom,
    required this.overview,
    required this.progress,
    required this.distM,
    required this.eleM,
    required this.speedKmh,
    required this.gradePct,
    required this.elapsedS,
  });
}

/// Precomputed cinematic camera path. Built in Dart (testable), the JS
/// side only interpolates between dense keyframes.
class FlyoverPlan {
  final List<LatLon> route; // simplified display geometry
  final List<FlyKeyframe> frames;
  final double totalDistM;
  final bool hasElevation;
  final int summitFrame; // -1 when no orbit

  const FlyoverPlan({
    required this.route,
    required this.frames,
    required this.totalDistM,
    required this.hasElevation,
    this.summitFrame = -1,
  });

  bool get isEmpty => frames.isEmpty;

  /// Linear interpolation of the HUD values at [u] (for the Flutter HUD).
  FlyKeyframe at(double u) {
    if (frames.isEmpty) throw StateError('empty plan');
    if (u <= frames.first.u) return frames.first;
    if (u >= frames.last.u) return frames.last;
    var lo = 0, hi = frames.length - 1;
    while (hi - lo > 1) {
      final m = (lo + hi) >> 1;
      if (frames[m].u <= u) {
        lo = m;
      } else {
        hi = m;
      }
    }
    final a = frames[lo], b = frames[hi];
    final span = b.u - a.u;
    final t = span <= 0 ? 0.0 : (u - a.u) / span;
    double l(double x, double y) => x + (y - x) * t;
    return FlyKeyframe(
      u: u,
      lat: l(a.lat, b.lat),
      lon: l(a.lon, b.lon),
      bearing: l(a.bearing, b.bearing),
      pitch: l(a.pitch, b.pitch),
      zoom: l(a.zoom, b.zoom),
      overview: l(a.overview, b.overview),
      progress: l(a.progress, b.progress),
      distM: l(a.distM, b.distM),
      eleM: l(a.eleM, b.eleM),
      speedKmh: l(a.speedKmh, b.speedKmh),
      gradePct: l(a.gradePct, b.gradePct),
      elapsedS: l(a.elapsedS, b.elapsedS),
    );
  }

  /// Compact column-wise JSON for `ViryaMap.flyLoad`.
  Map<String, Object> toJson() {
    List<double> col(double Function(FlyKeyframe f) g, int dp) {
      final m = math.pow(10, dp);
      return [for (final f in frames) (g(f) * m).roundToDouble() / m];
    }

    return {
      'route': [
        for (final p in route)
          [(p.$2 * 1e6).round() / 1e6, (p.$1 * 1e6).round() / 1e6]
      ],
      'u': col((f) => f.u, 5),
      'lat': col((f) => f.lat, 6),
      'lon': col((f) => f.lon, 6),
      'b': col((f) => f.bearing, 2),
      'pt': col((f) => f.pitch, 1),
      'z': col((f) => f.zoom, 3),
      'ov': col((f) => f.overview, 3),
      'p': col((f) => f.progress, 5),
      'd': col((f) => f.distM, 0),
      'e': col((f) => f.eleM, 0),
      's': col((f) => f.speedKmh, 1),
      'g': col((f) => f.gradePct, 1),
      't': col((f) => f.elapsedS, 0),
      'hasEle': hasElevation,
    };
  }
}
