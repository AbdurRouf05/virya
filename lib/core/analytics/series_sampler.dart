import 'package:stravo/core/analytics/analysis_models.dart';
import 'package:stravo/core/analytics/prepared_track.dart';
import 'package:stravo/core/constants/enums.dart';

/// Pick ≤ [maxPoints] sample indices: evenly spaced, with the global
/// highest / lowest elevation swapped in for their nearest pick.
List<int> pickSeriesIndices(PreparedTrack p, {int maxPoints = 600}) {
  final n = p.n;
  if (n <= maxPoints) return List<int>.generate(n, (i) => i);
  final idx = List<int>.generate(
      maxPoints, (k) => (k * (n - 1) / (maxPoints - 1)).round());
  void force(int target) {
    final step = (n - 1) / (maxPoints - 1);
    final k = (target / step).round().clamp(1, maxPoints - 2);
    if (idx[k - 1] < target && target < idx[k + 1]) idx[k] = target;
  }

  if (p.hasEle) {
    var hi = 0, lo = 0;
    for (var i = 1; i < n; i++) {
      if (p.ele[i] > p.ele[hi]) hi = i;
      if (p.ele[i] < p.ele[lo]) lo = i;
    }
    force(hi);
    force(lo);
  }
  return idx;
}

ActivitySeries buildSeries(PreparedTrack p, {int maxPoints = 600}) {
  if (p.n == 0) return ActivitySeries.empty;
  final idx = pickSeriesIndices(p, maxPoints: maxPoints);
  // Display speed: ~5-sample centered mean.
  double sp(int i) {
    final a = i - 2 < 0 ? 0 : i - 2;
    final b = i + 2 >= p.n ? p.n - 1 : i + 2;
    var s = 0.0;
    for (var k = a; k <= b; k++) {
      s += p.speed[k];
    }
    return s / (b - a + 1);
  }

  return ActivitySeries(
    distanceM: [for (final i in idx) p.cum[i]],
    elapsedS: [for (final i in idx) p.t[i].round()],
    lat: [for (final i in idx) p.s[i].lat],
    lon: [for (final i in idx) p.s[i].lon],
    ele: [for (final i in idx) p.ele[i]],
    speedMps: [for (final i in idx) p.s[i].paused ? 0.0 : sp(i)],
    gradePct: [for (final i in idx) p.grade[i] * 100],
    heartRate: <int?>[for (final i in idx) p.s[i].heartRate],
    surface: <SurfaceType>[for (final i in idx) p.s[i].surface],
  );
}
