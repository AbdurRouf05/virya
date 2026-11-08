import 'dart:typed_data';

import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/analytics/geo.dart';
import 'package:virya/core/analytics/prepared_track.dart';

/// Per-km splits. [gapCum] (cumulative grade-adjusted distance over moving
/// intervals) is optional; when given each split gets a GAP speed.
List<Split> computeSplits(PreparedTrack p, {Float64List? gapCum,
    double splitM = 1000}) {
  final total = p.distance;
  if (total < 10) return const [];
  final count = (total / splitM).ceil();
  final hrSum = Float64List(count), hrT = Float64List(count);
  for (var i = 1; i < p.n; i++) {
    final hr = p.s[i].heartRate;
    if (hr == null || hr <= 0 || p.s[i].paused || p.dt[i] <= 0) continue;
    final dtc = p.dt[i] > 30 ? 30.0 : p.dt[i];
    var k = (p.cum[i] / splitM).floor();
    if (k >= count) k = count - 1;
    hrSum[k] += hr * dtc;
    hrT[k] += dtc;
  }
  final out = <Split>[];
  for (var k = 0; k < count; k++) {
    final d0 = k * splitM;
    final d1 = k == count - 1 ? total : (k + 1) * splitM;
    final len = d1 - d0;
    if (len < 10 && k > 0) break;
    final m0 = interpOn(p.cum, p.mt, d0), m1 = interpOn(p.cum, p.mt, d1);
    final mtS = (m1 - m0).round();
    double? gap;
    if (gapCum != null && m1 - m0 > 0) {
      gap = (interpOn(p.cum, gapCum, d1) - interpOn(p.cum, gapCum, d0)) /
          (m1 - m0);
    }
    out.add(Split(
      index: k + 1,
      distanceM: len,
      movingTimeS: mtS,
      elevationDeltaM: p.hasEle
          ? interpOn(p.cum, p.ele, d1) - interpOn(p.cum, p.ele, d0)
          : 0,
      gapMps: gap,
      avgHeartRate: hrT[k] > 0 ? (hrSum[k] / hrT[k]).round() : null,
    ));
  }
  return out;
}
