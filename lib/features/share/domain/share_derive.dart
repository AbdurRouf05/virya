import 'dart:math' as math;

import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/models/track_sample.dart';

/// Fallback route series derived straight from raw samples (used when the
/// analysis series is empty).
class DerivedShareSeries {
  final List<double> lat, lon, ele, dist, grade, speed;
  final List<SurfaceType> surface;
  DerivedShareSeries(this.lat, this.lon, this.ele, this.dist, this.grade,
      this.speed, this.surface);
}

double haversineM(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final p1 = lat1 * math.pi / 180, p2 = lat2 * math.pi / 180;
  final dp = p2 - p1, dl = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dp / 2) * math.sin(dp / 2) +
      math.cos(p1) * math.cos(p2) * math.sin(dl / 2) * math.sin(dl / 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(a)));
}

/// Down-samples [samples] to ~500 points with smoothed elevation and grade.
DerivedShareSeries deriveShareSeries(List<TrackSample> samples) {
  final n = samples.length;
  final lat = <double>[], lon = <double>[], ele = <double>[];
  final dist = <double>[], speed = <double>[];
  final surface = <SurfaceType>[];
  if (n == 0) return DerivedShareSeries(lat, lon, ele, dist, [], speed, surface);
  final stride = math.max(1, (n / 500).ceil());
  var acc = 0.0;
  for (var i = 0; i < n; i++) {
    if (i > 0) {
      final a = samples[i - 1], b = samples[i];
      acc += haversineM(a.lat, a.lon, b.lat, b.lon);
    }
    if (i % stride == 0 || i == n - 1) {
      final s = samples[i];
      lat.add(s.lat);
      lon.add(s.lon);
      ele.add(s.ele ?? 0);
      dist.add(acc);
      speed.add(s.speedMps ?? 0);
      surface.add(s.surface);
    }
  }
  // Light smoothing of elevation, then grade.
  final se = List<double>.from(ele);
  for (var i = 1; i < ele.length - 1; i++) {
    se[i] = (ele[i - 1] + 2 * ele[i] + ele[i + 1]) / 4;
  }
  final grade = List<double>.filled(se.length, 0);
  for (var i = 1; i < se.length; i++) {
    final dd = dist[i] - dist[i - 1];
    grade[i] = dd > 1 ? (se[i] - se[i - 1]) / dd * 100 : grade[i - 1];
  }
  return DerivedShareSeries(lat, lon, se, dist, grade, speed, surface);
}

/// Moving time (s) from samples, skipping pauses and gaps > 30 s.
int movingTimeOf(List<TrackSample> s) {
  var t = 0;
  for (var i = 1; i < s.length; i++) {
    if (s[i].paused) continue;
    final dt = s[i].time.difference(s[i - 1].time).inSeconds;
    if (dt > 0 && dt <= 30) t += dt;
  }
  return t;
}

/// Elevation gain with 3 m hysteresis.
double elevationGainOf(List<double> ele) {
  if (ele.isEmpty) return 0;
  var ref = ele.first, acc = 0.0;
  for (final e in ele) {
    if (e - ref >= 3) {
      acc += e - ref;
      ref = e;
    } else if (ref - e >= 3) {
      ref = e;
    }
  }
  return acc;
}

/// Average heart rate over samples that have one, or null.
int? avgHeartRateOf(List<TrackSample> s) {
  var sum = 0, n = 0;
  for (final x in s) {
    final hr = x.heartRate;
    if (hr != null && hr > 0) {
      sum += hr;
      n++;
    }
  }
  return n == 0 ? null : (sum / n).round();
}
