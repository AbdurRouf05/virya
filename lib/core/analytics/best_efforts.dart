import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/analytics/prepared_track.dart';
import 'package:virya/core/constants/enums.dart';

const runningEfforts = <(String, double)>[
  ('400m', 400),
  ('1K', 1000),
  ('1 mile', 1609.344),
  ('5K', 5000),
  ('10K', 10000),
  ('Half', 21097.5),
  ('Marathon', 42195),
];

const cyclingEfforts = <(String, double)>[
  ('5K', 5000),
  ('10K', 10000),
  ('20K', 20000),
  ('40K', 40000),
  ('50K', 50000),
  ('100K', 100000),
];

List<(String, double)> effortTargets(SportType sport) =>
    sport.isCycling ? cyclingEfforts : runningEfforts;

/// Fastest moving time over each target distance (two pointers on the
/// cumulative distance, start point interpolated).
List<BestEffort> computeBestEfforts(PreparedTrack p, SportType sport) {
  final out = <BestEffort>[];
  final total = p.distance;
  for (final (label, target) in effortTargets(sport)) {
    if (total + 1e-6 < target) continue;
    var best = double.infinity;
    var bestStart = 0.0;
    var i = 0;
    for (var j = 1; j < p.n; j++) {
      final dStart = p.cum[j] - target;
      if (dStart < 0) continue;
      while (i + 1 < j && p.cum[i + 1] <= dStart) {
        i++;
      }
      final span = p.cum[i + 1] - p.cum[i];
      final f = span > 0 ? ((dStart - p.cum[i]) / span).clamp(0.0, 1.0) : 0.0;
      final tStart = p.mt[i] + (p.mt[i + 1] - p.mt[i]) * f;
      final time = p.mt[j] - tStart;
      if (time > 0 && time < best) {
        best = time;
        bestStart = dStart;
      }
    }
    if (best.isFinite) {
      out.add(BestEffort(
        label: label,
        distanceM: target,
        timeS: best.round(),
        startDistanceM: bestStart,
      ));
    }
  }
  return out;
}
