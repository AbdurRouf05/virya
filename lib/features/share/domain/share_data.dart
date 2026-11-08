import 'dart:math' as math;

import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/data/activity_repository.dart';
import 'package:virya/core/models/track_sample.dart';
import 'package:virya/features/share/domain/share_derive.dart';

export 'package:virya/features/share/domain/share_derive.dart' show haversineM;

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
      final d = deriveShareSeries(samples);
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
    if (moving <= 0) moving = movingTimeOf(samples);
    var gain = analysis.elevationGainM;
    if (gain <= 0) gain = elevationGainOf(ele);
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
    final hr = analysis.avgHeartRate ?? avgHeartRateOf(samples);

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
