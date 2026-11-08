import 'dart:math' as math;

import 'package:stravo/core/analytics/analysis_models.dart';
import 'package:stravo/core/analytics/geo.dart';
import 'package:stravo/core/analytics/prepared_track.dart';

/// Zone 1..5 by % of max HR: <60, 60–70, 70–80, 80–90, ≥90.
int hrZone(int hr, int maxHr) {
  final pct = hr / maxHr * 100;
  if (pct < 60) return 1;
  if (pct < 70) return 2;
  if (pct < 80) return 3;
  if (pct < 90) return 4;
  return 5;
}

/// Seconds per HR zone (non-paused, gaps capped at 30 s).
Map<int, int> hrZoneSeconds(PreparedTrack p, AthleteParams a) {
  final acc = List<double>.filled(6, 0);
  var any = false;
  for (var i = 1; i < p.n; i++) {
    final hr = p.s[i].heartRate;
    if (hr == null || hr <= 0 || p.s[i].paused || p.dt[i] <= 0) continue;
    any = true;
    acc[hrZone(hr, a.maxHr)] += p.dt[i] > 30 ? 30 : p.dt[i];
  }
  if (!any) return const {};
  return {for (var z = 1; z <= 5; z++) z: acc[z].round()};
}

/// Banister TRIMP: Σ minutes × HRr × 0.64·e^(1.92·HRr), HRr = HR reserve.
/// Returns null when HR covers < 50% of the moving time.
double? banisterTrimp(PreparedTrack p, AthleteParams a) {
  final range = (a.maxHr - a.restHr).toDouble();
  if (range <= 0) return null;
  var trimp = 0.0, covered = 0.0;
  for (var i = 1; i < p.n; i++) {
    final hr = p.s[i].heartRate;
    if (hr == null || hr <= 0 || p.s[i].paused || p.dt[i] <= 0) continue;
    final dtc = p.dt[i] > 30 ? 30.0 : p.dt[i];
    final x = clampD((hr - a.restHr) / range, 0, 1);
    trimp += dtc / 60 * x * 0.64 * math.exp(1.92 * x);
    if (p.moving[i] == 1) covered += dtc;
  }
  if (p.movingTime <= 0 || covered < 0.5 * p.movingTime) return null;
  return trimp;
}

/// HR-free load, TSS-like: moving hours × IF² × 100 (1 h at threshold = 100).
double intensityLoad(double movingS, double intensityFactor) {
  final f = clampD(intensityFactor, 0, 1.5);
  return movingS / 3600 * f * f * 100;
}

/// Normalized power: 4th-power mean of a ~30 s rolling average.
/// [power] and [dt] are per moving interval.
double normalizedPower(List<double> power, List<double> dt) {
  final n = power.length;
  if (n == 0) return 0;
  var winSum = 0.0, winT = 0.0, acc = 0.0, accT = 0.0;
  var lo = 0;
  for (var i = 0; i < n; i++) {
    winSum += power[i] * dt[i];
    winT += dt[i];
    while (lo < i && winT - dt[lo] >= 30) {
      winSum -= power[lo] * dt[lo];
      winT -= dt[lo];
      lo++;
    }
    if (winT > 0) {
      final avg = winSum / winT;
      final a2 = avg * avg;
      acc += a2 * a2 * dt[i];
      accT += dt[i];
    }
  }
  if (accT <= 0) return 0;
  return math.pow(acc / accT, 0.25).toDouble();
}
