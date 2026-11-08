import 'package:virya/core/data/activity_repository.dart';
import 'package:virya/core/widgets/route_thumbnail.dart' show downsample;

/// How the detail map colours the route line.
enum MapColorMode {
  speed('KECEPATAN'),
  grade('TANJAKAN'),
  surface('PERMUKAAN');

  final String label;
  const MapColorMode(this.label);
}

/// Map points + per-point values for [mode].
///
/// Prefers the (down-sampled) analysis series; falls back to raw samples
/// with no colour values when the series is too short.
({List<(double, double)> points, List<double>? values}) activityMapData(
  ActivityBundle b,
  MapColorMode mode,
) {
  final s = b.analysis.series;
  if (s.length >= 2) {
    return (
      points: [for (var i = 0; i < s.length; i++) (s.lat[i], s.lon[i])],
      values: switch (mode) {
        MapColorMode.speed => s.speedMps,
        MapColorMode.grade => s.gradePct,
        MapColorMode.surface => [for (final x in s.surface) x.index.toDouble()],
      },
    );
  }
  return (
    points: downsample([for (final x in b.samples) (x.lat, x.lon)], 600),
    values: null,
  );
}
