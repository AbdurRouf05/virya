import 'dart:math' as math;

import 'package:stravo/core/analytics/analysis_models.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/data/activity_repository.dart';
import 'package:stravo/core/models/track_sample.dart';

/// Photo placed along the route.
class SharePhoto {
  final String path;
  final double distanceM;
  final double lat;
  final double lon;
  final String? caption;
  const SharePhoto({
    required this.path,
    required this.distanceM,
    required this.lat,
    required this.lon,
    this.caption,
  });
}

/// Everything a share card / recap video needs, flattened from an
/// [ActivityBundle]. Falls back to sample-derived numbers when the analysis
/// is empty, so cards never render blank.
class ShareData {
  final String id;
  final String title;
  final SportType sport;
  final DateTime start;

  final double distanceM;
  final int movingTimeS;
  final double elevationGainM;
  final double avgSpeedMps;
  final double maxSpeedMps;
  final double maxEleM;
  final double minEleM;
  final int? avgHeartRate;
  final double gritScore;
  final double gravelPct;
  final Map<SurfaceType, double> surfaceDistanceM;
  final List<GravelSector> sectors;
  final List<Climb> climbs;

  /// Down-sampled aligned route series.
  final List<double> lat;
  final List<double> lon;
  final List<double> ele;
  final List<double> dist;
  final List<double> grade;
  final List<double> speed;
  final List<SurfaceType> surface;

  final List<SharePhoto> photos;

  const ShareData({
    required this.id,
    required this.title,
    required this.sport,
    required this.start,
    required this.distanceM,
    required this.movingTimeS,
    required this.elevationGainM,
    required this.avgSpeedMps,
    required this.maxSpeedMps,
    required this.maxEleM,
    required this.minEleM,
    this.avgHeartRate,
    this.gritScore = 0,
    this.gravelPct = 0,
    this.surfaceDistanceM = const {},
    this.sectors = const [],
    this.climbs = const [],
    required this.lat,
    required this.lon,
    required this.ele,
    required this.dist,
    required this.grade,
    required this.speed,
    required this.surface,
    this.photos = const [],
  });

  factory ShareData.fromBundle(ActivityBundle b) => ShareData.fromParts(
        id: b.activity.id,
        title: b.activity.title,
        sport: b.sport,
        start: b.activity.startTime,
        samples: b.samples,
        analysis: b.analysis,
        photos: [
          for (final p in b.photos)
            SharePhoto(
              path: p.filePath,
              distanceM: p.distanceFromStartMeters,
              lat: p.latitude,
              lon: p.longitude,
              caption: p.caption,
            ),
        ],
      );

  factory ShareData.fromParts({
    required String id,
    required String title,
    required SportType sport,
    required DateTime start,
    required List<TrackSample> samples,
    required ActivityAnalysis analysis,
    List<SharePhoto> photos = const [],
  }) {
    final s = analysis.series;
    late List<double> lat, lon, ele, dist, grade, speed;
    late List<SurfaceType> surface;
    if (s.length >= 2) {
      lat = s.lat;
      lon = s.lon;
      ele = s.ele;
      dist = s.distanceM;
      grade = s.gradePct;
      speed = s.speedMps;
      surface = s.surface;
    } else {
      final d = _derive(samples);
      lat = d.lat;
      lon = d.lon;
      ele = d.ele;
      dist = d.dist;
      grade = d.grade;
      speed = d.speed;
      surface = d.surface;
    }

    final distM = analysis.distanceM > 0
        ? analysis.distanceM
        : (dist.isEmpty ? 0.0 : dist.last);
    var moving = analysis.movingTimeS;
    if (moving <= 0) moving = _movingTime(samples);
    var gain = analysis.elevationGainM;
    if (gain <= 0) gain = _gain(ele);
    var avg = analysis.avgSpeedMps;
    if (avg <= 0 && moving > 0) avg = distM / moving;
    var maxSp = analysis.maxSpeedMps;
    if (maxSp <= 0 && speed.isNotEmpty) maxSp = speed.reduce(math.max);
    var maxE = analysis.maxEleM, minE = analysis.minEleM;
    if (maxE == 0 && minE == 0 && ele.isNotEmpty) {
      maxE = ele.reduce(math.max);
      minE = ele.reduce(math.min);
    }
    var surf = analysis.surfaceDistanceM;
    if (surf.isEmpty && surface.length >= 2) {
      final m = <SurfaceType, double>{};
      for (var i = 1; i < surface.length; i++) {
        m[surface[i]] = (m[surface[i]] ?? 0) + (dist[i] - dist[i - 1]);
      }
      surf = m;
    }
    var gravelPct = analysis.gravelPct;
    if (gravelPct <= 0 && distM > 0 && surf.isNotEmpty) {
      final g = surf.entries
          .where((e) =>
              e.key != SurfaceType.asphalt && e.key != SurfaceType.unknown)
          .fold<double>(0, (a, e) => a + e.value);
      gravelPct = g / distM * 100;
    }
    final hr = analysis.avgHeartRate ?? _avgHr(samples);

    return ShareData(
      id: id,
      title: title,
      sport: sport,
      start: start,
      distanceM: distM,
      movingTimeS: moving,
      elevationGainM: gain,
      avgSpeedMps: avg,
      maxSpeedMps: maxSp,
      maxEleM: maxE,
      minEleM: minE,
      avgHeartRate: hr,
      gritScore: analysis.gritScore,
      gravelPct: gravelPct,
      surfaceDistanceM: surf,
      sectors: analysis.gravelSectors,
      climbs: analysis.climbs,
      lat: lat,
      lon: lon,
      ele: ele,
      dist: dist,
      grade: grade,
      speed: speed,
      surface: surface,
      photos: photos,
    );
  }

  /// Stable seed for procedural textures (FNV-1a of the id).
  int get seed {
    var h = 0x811c9dc5;
    for (final c in id.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h & 0x7FFFFFFF;
  }

  bool get hasRoute => lat.length >= 2;
  double get startLat => lat.isEmpty ? 0 : lat.first;
  double get startLon => lon.isEmpty ? 0 : lon.first;

  /// Index into the series for a given distance (binary search).
  int indexAtDistance(double d) {
    if (dist.isEmpty) return 0;
    var lo = 0, hi = dist.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (dist[mid] < d) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  /// Cumulative elevation gain per series index (3 m hysteresis).
  List<double> cumulativeGain() {
    final out = List<double>.filled(ele.length, 0);
    if (ele.isEmpty) return out;
    var ref = ele.first, acc = 0.0;
    for (var i = 1; i < ele.length; i++) {
      final e = ele[i];
      if (e - ref >= 3) {
        acc += e - ref;
        ref = e;
      } else if (ref - e >= 3) {
        ref = e;
      }
      out[i] = acc;
    }
    // Scale to the official total so the HUD ends on the card's number.
    final last = out.last;
    if (last > 0 && elevationGainM > 0) {
      final k = elevationGainM / last;
      for (var i = 0; i < out.length; i++) {
        out[i] *= k;
      }
    }
    return out;
  }
}

class _Derived {
  final List<double> lat, lon, ele, dist, grade, speed;
  final List<SurfaceType> surface;
  _Derived(this.lat, this.lon, this.ele, this.dist, this.grade, this.speed,
      this.surface);
}

double haversineM(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final p1 = lat1 * math.pi / 180, p2 = lat2 * math.pi / 180;
  final dp = p2 - p1, dl = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dp / 2) * math.sin(dp / 2) +
      math.cos(p1) * math.cos(p2) * math.sin(dl / 2) * math.sin(dl / 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(a)));
}

_Derived _derive(List<TrackSample> samples) {
  final n = samples.length;
  final lat = <double>[], lon = <double>[], ele = <double>[];
  final dist = <double>[], speed = <double>[];
  final surface = <SurfaceType>[];
  if (n == 0) return _Derived(lat, lon, ele, dist, [], speed, surface);
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
  return _Derived(lat, lon, se, dist, grade, speed, surface);
}

int _movingTime(List<TrackSample> s) {
  var t = 0;
  for (var i = 1; i < s.length; i++) {
    if (s[i].paused) continue;
    final dt = s[i].time.difference(s[i - 1].time).inSeconds;
    if (dt > 0 && dt <= 30) t += dt;
  }
  return t;
}

double _gain(List<double> ele) {
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

int? _avgHr(List<TrackSample> s) {
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
