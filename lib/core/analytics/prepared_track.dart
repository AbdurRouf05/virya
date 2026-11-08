import 'dart:typed_data';

import 'package:virya/core/analytics/elevation.dart';
import 'package:virya/core/analytics/geo.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/models/track_sample.dart';

/// Minimum speed (m/s) to count time as moving.
double movingThreshold(SportType sport) {
  if (sport.isCycling) return 1.0;
  if (sport.isRunning) return 0.6;
  return 0.3;
}

/// Plausibility cap (m/s) for max speed.
double maxPlausibleSpeed(SportType sport) {
  if (sport.isCycling) return 30;
  if (sport.isRunning) return 12;
  return 8;
}

/// Per-sample arrays shared by all analysis passes. Index `i` of an
/// "interval" array describes the stretch from sample i-1 to sample i.
class PreparedTrack {
  final List<TrackSample> s;
  final int n;
  final Float64List t; // seconds since start
  final Float64List cum; // cumulative distance (paused stretches excluded)
  final Float64List mt; // cumulative moving time
  final Float64List dd; // interval distance
  final Float64List dt; // interval duration
  final Uint8List moving; // interval counts as moving
  final Float64List ele; // smoothed elevation (0 when unknown)
  final bool hasEle;
  final Float64List speed; // per-sample speed, 0 when paused
  final Float64List speed3; // 3-sample centered average
  final Float64List grade; // fraction, ~80 m window

  PreparedTrack._(this.s, this.n, this.t, this.cum, this.mt, this.dd, this.dt,
      this.moving, this.ele, this.hasEle, this.speed, this.speed3, this.grade);

  double get distance => n == 0 ? 0 : cum[n - 1];
  double get movingTime => n == 0 ? 0 : mt[n - 1];

  factory PreparedTrack.build(List<TrackSample> input, SportType sport) {
    final s = _sorted(input);
    final n = s.length;
    final t = Float64List(n);
    final cum = Float64List(n);
    final mt = Float64List(n);
    final dd = Float64List(n);
    final dt = Float64List(n);
    final moving = Uint8List(n);
    final speed = Float64List(n);
    final thr = movingThreshold(sport);
    if (n == 0) {
      return PreparedTrack._(s, 0, t, cum, mt, dd, dt, moving, Float64List(0),
          false, speed, Float64List(0), Float64List(0));
    }
    final t0 = s[0].time.microsecondsSinceEpoch;
    for (var i = 0; i < n; i++) {
      t[i] = (s[i].time.microsecondsSinceEpoch - t0) / 1e6;
      if (i == 0) {
        speed[0] = s[0].paused ? 0 : (s[0].speedMps ?? 0);
        continue;
      }
      final a = s[i - 1], b = s[i];
      final d = b.paused ? 0.0 : haversineM(a.lat, a.lon, b.lat, b.lon);
      final dti = t[i] - t[i - 1];
      var dist = d;
      // GPS teleport: implausibly fast jump.
      if (dti > 0 && dist > 200 && dist / dti > 60) dist = 0;
      if (dti <= 0 && dist > 50) dist = 0;
      dd[i] = dist;
      dt[i] = dti > 0 ? dti : 0;
      double v;
      if (dti <= 0) {
        v = 0;
      } else if (dti <= 5 && b.speedMps != null && !b.speedMps!.isNaN) {
        v = b.speedMps!;
      } else {
        v = dist / dti;
      }
      if (b.paused) v = 0;
      speed[i] = v < 0 ? 0 : v;
      final mov = !b.paused && dti > 0 && v >= thr;
      moving[i] = mov ? 1 : 0;
      cum[i] = cum[i - 1] + dist;
      mt[i] = mt[i - 1] + (mov ? dti : 0);
    }

    final filled = fillElevation([for (final x in s) x.ele]);
    final hasEle = filled != null;
    final ele = hasEle ? smoothElevation(filled) : Float64List(n);

    final speed3 = Float64List(n);
    for (var i = 0; i < n; i++) {
      final a = i > 0 ? i - 1 : i;
      final b = i < n - 1 ? i + 1 : i;
      var sum = 0.0;
      for (var k = a; k <= b; k++) {
        sum += speed[k];
      }
      speed3[i] = sum / (b - a + 1);
    }

    final grade = Float64List(n);
    if (hasEle) {
      const half = 40.0;
      var lo = 0, hi = 0;
      var last = 0.0;
      for (var i = 0; i < n; i++) {
        while (lo < i && cum[lo + 1] <= cum[i] - half) {
          lo++;
        }
        if (hi < i) hi = i;
        while (hi < n - 1 && cum[hi] < cum[i] + half) {
          hi++;
        }
        final span = cum[hi] - cum[lo];
        if (span >= 10) {
          last = clampD((ele[hi] - ele[lo]) / span, -0.4, 0.4);
        }
        grade[i] = last;
      }
    }
    return PreparedTrack._(
        s, n, t, cum, mt, dd, dt, moving, ele, hasEle, speed, speed3, grade);
  }

  static List<TrackSample> _sorted(List<TrackSample> input) {
    final valid = input
        .where((x) =>
            !x.lat.isNaN &&
            !x.lon.isNaN &&
            x.lat.abs() <= 90 &&
            x.lon.abs() <= 180)
        .toList();
    for (var i = 1; i < valid.length; i++) {
      if (valid[i].time.isBefore(valid[i - 1].time)) {
        final idx = List<int>.generate(valid.length, (k) => k);
        idx.sort((a, b) {
          final c = valid[a].time.compareTo(valid[b].time);
          return c != 0 ? c : a - b;
        });
        return [for (final k in idx) valid[k]];
      }
    }
    return valid;
  }
}
