import 'dart:math' as math;

import 'package:virya/core/analytics/analysis_models.dart';

class RacePrediction {
  final String label;
  final double distanceM;
  final int timeS;

  /// The best effort the prediction was derived from.
  final BestEffort basis;
  const RacePrediction({
    required this.label,
    required this.distanceM,
    required this.timeS,
    required this.basis,
  });
  double get paceSPerKm => timeS / (distanceM / 1000);
}

/// Riegel: T2 = T1 × (D2 / D1)^1.06.
double riegelTime(double t1, double d1, double d2, {double exponent = 1.06}) =>
    t1 * math.pow(d2 / d1, exponent);

const raceTargets = <(String, double)>[
  ('5K', 5000),
  ('10K', 10000),
  ('Half', 21097.5),
  ('Marathon', 42195),
];

/// For each target, use the best effort (≥ 1 km) whose distance is closest
/// on a log scale — short efforts over-predict long races less that way.
List<RacePrediction> predictRaces(Iterable<BestEffort> efforts,
    {List<(String, double)> targets = raceTargets}) {
  final usable =
      efforts.where((e) => e.distanceM >= 1000 && e.timeS > 0).toList();
  if (usable.isEmpty) return const [];
  final out = <RacePrediction>[];
  for (final (label, d) in targets) {
    BestEffort? basis;
    var bestScore = double.infinity;
    double? bestTime;
    for (final e in usable) {
      final score = (math.log(d / e.distanceM)).abs();
      final t = riegelTime(e.timeS.toDouble(), e.distanceM, d);
      if (score < bestScore - 1e-9 ||
          ((score - bestScore).abs() <= 1e-9 && t < bestTime!)) {
        bestScore = score;
        basis = e;
        bestTime = t;
      }
    }
    out.add(RacePrediction(
      label: label,
      distanceM: d,
      timeS: bestTime!.round(),
      basis: basis!,
    ));
  }
  return out;
}
