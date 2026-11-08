import 'dart:math' as math;

import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/data/demo_data.dart';
import 'package:virya/features/share/domain/share_data.dart';

/// Hand-built analysis from `demoGravelRide()` (independent of the analyzer).
ActivityAnalysis fakeAnalysis() {
  final s = demoGravelRide();
  const stride = 10;
  final lat = <double>[], lon = <double>[], ele = <double>[];
  final dist = <double>[], speed = <double>[], grade = <double>[];
  final elapsed = <int>[];
  final hr = <int?>[];
  final surf = <SurfaceType>[];
  var acc = 0.0;
  for (var i = 0; i < s.length; i++) {
    if (i > 0) acc += haversineM(s[i - 1].lat, s[i - 1].lon, s[i].lat, s[i].lon);
    if (i % stride == 0) {
      lat.add(s[i].lat);
      lon.add(s[i].lon);
      ele.add(s[i].ele ?? 0);
      dist.add(acc);
      speed.add(s[i].speedMps ?? 0);
      elapsed.add(i);
      hr.add(s[i].heartRate);
      surf.add(s[i].surface);
      final n = dist.length;
      grade.add(n < 2 || dist[n - 1] - dist[n - 2] < 1
          ? 0
          : (ele[n - 1] - ele[n - 2]) / (dist[n - 1] - dist[n - 2]) * 100);
    }
  }
  final total = acc;
  double at(double t) => total * t;
  return ActivityAnalysis(
    sport: SportType.gravelCycling,
    distanceM: total,
    movingTimeS: 5300,
    elapsedTimeS: 5400,
    elevationGainM: 740,
    elevationLossM: 735,
    maxEleM: ele.reduce(math.max),
    minEleM: ele.reduce(math.min),
    avgSpeedMps: total / 5300,
    maxSpeedMps: 10.4,
    avgHeartRate: 146,
    gritScore: 68,
    gravelPct: 60,
    surfaceDistanceM: {
      SurfaceType.asphalt: at(0.4),
      SurfaceType.smoothGravel: at(0.3),
      SurfaceType.roughGravel: at(0.15),
      SurfaceType.dirt: at(0.15),
    },
    gravelSectors: [
      GravelSector(number: 4, name: 'Sektor 4 · Kebun Teh', startDistanceM: at(0.15), endDistanceM: at(0.3), dominantSurface: SurfaceType.smoothGravel, stars: 2, avgGradePct: 3.1, roughness: 2.4),
      GravelSector(number: 3, name: 'Sektor 3 · Tanjakan Batu', startDistanceM: at(0.3), endDistanceM: at(0.45), dominantSurface: SurfaceType.roughGravel, stars: 5, avgGradePct: 6.8, roughness: 5.0),
      GravelSector(number: 2, name: 'Sektor 2 · Jalur Tanah', startDistanceM: at(0.45), endDistanceM: at(0.6), dominantSurface: SurfaceType.dirt, stars: 3, avgGradePct: -2.0, roughness: 3.3),
      GravelSector(number: 1, name: 'Sektor 1 · Pinus', startDistanceM: at(0.6), endDistanceM: at(0.75), dominantSurface: SurfaceType.smoothGravel, stars: 2, avgGradePct: 0.5, roughness: 2.3),
    ],
    climbs: [
      Climb(startDistanceM: at(0.22), endDistanceM: at(0.35), gainM: 360, avgGradePct: 7.4, maxGradePct: 12, category: ClimbCategory.cat2, durationS: 900, vam: 1440),
      Climb(startDistanceM: at(0.05), endDistanceM: at(0.1), gainM: 80, avgGradePct: 4.1, maxGradePct: 6, category: ClimbCategory.cat4, durationS: 300, vam: 960),
    ],
    series: ActivitySeries(
      distanceM: dist,
      elapsedS: elapsed,
      lat: lat,
      lon: lon,
      ele: ele,
      speedMps: speed,
      gradePct: grade,
      heartRate: hr,
      surface: surf,
    ),
    minLat: lat.reduce(math.min),
    minLon: lon.reduce(math.min),
    maxLat: lat.reduce(math.max),
    maxLon: lon.reduce(math.max),
  );
}

ShareData fakeShareData({List<SharePhoto> photos = const []}) =>
    ShareData.fromParts(
      id: 'demo-activity-0001',
      title: 'Demo · Gravel Lembang Loop',
      sport: SportType.gravelCycling,
      start: DateTime(2026, 11, 1, 6),
      samples: demoGravelRide(),
      analysis: fakeAnalysis(),
      photos: photos,
    );
