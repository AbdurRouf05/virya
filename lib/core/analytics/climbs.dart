import 'dart:typed_data';

import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/analytics/geo.dart';
import 'package:virya/core/analytics/prepared_track.dart';
import 'package:virya/core/constants/enums.dart';

const double _step = 10; // resample spacing (m)

/// Strava-like category from score = length(m) × avg grade(%).
ClimbCategory climbCategory(double lengthM, double gradePct) {
  final score = lengthM * gradePct;
  if (score >= 80000) return ClimbCategory.hc;
  if (score >= 64000) return ClimbCategory.cat1;
  if (score >= 32000) return ClimbCategory.cat2;
  if (score >= 16000) return ClimbCategory.cat3;
  if (score >= 8000) return ClimbCategory.cat4;
  return ClimbCategory.flat;
}

/// Climbs on a 10 m resampled profile: start at a local minimum, extend to
/// the highest point while dips stay within max(8 m, 15% of gain so far).
/// Kept when gain ≥ [minGain], length ≥ [minLength] and grade ≥ 3%.
List<Climb> detectClimbs(PreparedTrack p,
    {double minGain = 20, double minLength = 300}) {
  if (!p.hasEle || p.distance < minLength) return const [];
  final m = (p.distance / _step).floor() + 1;
  final e = Float64List(m), mt = Float64List(m), el = Float64List(m);
  var j = 0;
  for (var k = 0; k < m; k++) {
    final d = k * _step;
    while (j < p.n - 1 && p.cum[j + 1] < d) {
      j++;
    }
    final a = j, b = j < p.n - 1 ? j + 1 : j;
    final span = p.cum[b] - p.cum[a];
    final f = span > 0 ? clampD((d - p.cum[a]) / span, 0, 1) : 0.0;
    e[k] = p.ele[a] + (p.ele[b] - p.ele[a]) * f;
    mt[k] = p.mt[a] + (p.mt[b] - p.mt[a]) * f;
    el[k] = p.t[a] + (p.t[b] - p.t[a]) * f;
  }
  final out = <Climb>[];
  var i = 0;
  while (i < m - 1) {
    if (e[i + 1] <= e[i]) {
      i++;
      continue;
    }
    final start = i;
    var peak = i;
    var k = i + 1;
    for (; k < m; k++) {
      if (e[k] >= e[peak]) {
        peak = k;
      } else {
        final gain = e[peak] - e[start];
        var tol = gain * 0.15;
        if (tol < 8) tol = 8;
        if (tol > 40) tol = 40;
        if (e[peak] - e[k] > tol || e[k] < e[start]) break;
      }
    }
    final gain = e[peak] - e[start];
    final len = (peak - start) * _step;
    if (gain >= minGain && len >= minLength && gain / len >= 0.03) {
      var maxG = 0.0;
      const w = 10; // 100 m grade window
      for (var q = start; q + w <= peak; q++) {
        final g = (e[q + w] - e[q]) / (w * _step);
        if (g > maxG) maxG = g;
      }
      if (peak - start < w) maxG = gain / len;
      final avg = gain / len * 100;
      final dur = (el[peak] - el[start]).round();
      final mov = mt[peak] - mt[start];
      final hours = (mov > 0 ? mov : dur.toDouble()) / 3600;
      out.add(Climb(
        startDistanceM: start * _step,
        endDistanceM: peak * _step,
        gainM: gain,
        avgGradePct: avg,
        maxGradePct: maxG * 100,
        category: climbCategory(len, avg),
        durationS: dur,
        vam: hours > 0 ? gain / hours : 0,
      ));
    }
    i = peak > i ? peak : i + 1;
  }
  return out;
}
