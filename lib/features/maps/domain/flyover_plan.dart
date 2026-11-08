import 'dart:math' as math;

import 'package:virya/core/models/track_sample.dart';
import 'package:virya/features/maps/domain/flyover_model.dart';
import 'package:virya/features/maps/domain/route_geometry.dart';

export 'package:virya/features/maps/domain/flyover_model.dart';

/// Builds the flyover plan from raw samples. Pure & isolate-friendly.
FlyoverPlan buildFlyoverPlan(
  List<TrackSample> samples, {
  int travelFrames = 600,
  double pitch = 60,
}) {
  final s = [
    for (final x in samples)
      if (!x.paused && x.lat.abs() <= 90 && x.lon.abs() <= 180 &&
          !(x.lat == 0 && x.lon == 0))
        x
  ];
  if (s.length < 2) {
    if (s.isEmpty) {
      return const FlyoverPlan(
          route: [], frames: [], totalDistM: 0, hasElevation: false);
    }
    final f = FlyKeyframe(
      u: 0, lat: s.first.lat, lon: s.first.lon, bearing: 0, pitch: pitch,
      zoom: 15, overview: 0, progress: 1, distM: 0, eleM: s.first.ele ?? 0,
      speedKmh: 0, gradePct: 0, elapsedS: 0,
    );
    return FlyoverPlan(
        route: [(s.first.lat, s.first.lon)],
        frames: [f, _copyU(f, 1)],
        totalDistM: 0,
        hasElevation: false);
  }

  // Raw series.
  final pts = [for (final x in s) (x.lat, x.lon)];
  final dist = cumulativeDistance(pts);
  final total = dist.last;
  final t0 = s.first.time;
  final elapsed = [
    for (final x in s) x.time.difference(t0).inMilliseconds / 1000.0
  ];
  final hasEle = s.where((x) => x.ele != null).length > s.length / 2;
  final eleRaw = _fillNulls([for (final x in s) x.ele]);
  final ele = gaussianSmooth(eleRaw, 4);
  final spdRaw = <double>[];
  for (var i = 0; i < s.length; i++) {
    final v = s[i].speedMps;
    if (v != null && v >= 0) {
      spdRaw.add(v * 3.6);
    } else {
      final j = math.max(0, i - 1), k = math.min(s.length - 1, i + 1);
      final dt = elapsed[k] - elapsed[j];
      spdRaw.add(dt > 0 ? (dist[k] - dist[j]) / dt * 3.6 : 0);
    }
  }
  final spd = gaussianSmooth(spdRaw, 5);
  double gradeAt(double d) {
    final h = math.max(40.0, math.min(150.0, total / 200));
    final a = math.max(0.0, d - h), b = math.min(total, d + h);
    if (b - a < 10) return 0;
    return (interpAt(dist, ele, b) - interpAt(dist, ele, a)) / (b - a) * 100;
  }

  // Smooth path: simplify then Catmull–Rom densify.
  final eps = (total / 3000).clamp(3.0, 25.0);
  final ctrlIdx = simplifyIndices(pts, eps);
  final ctrl = [for (final i in ctrlIdx) pts[i]];
  final smooth = catmullRomPath(ctrl, steps: ctrl.length > 1500 ? 2 : 6);
  final sd = cumulativeDistance(smooth);
  final sTotal = sd.last <= 0 ? 1.0 : sd.last;
  final sLat = [for (final p in smooth) p.$1];
  final sLon = [for (final p in smooth) p.$2];
  LatLon posAt(double f) {
    final d = f.clamp(0.0, 1.0) * sTotal;
    return (interpAt(sd, sLat, d), interpAt(sd, sLon, d));
  }

  final n = math.max(2, travelFrames);
  final fr = [for (var k = 0; k < n; k++) k / (n - 1)];
  final pos = [for (final f in fr) posAt(f)];

  // Look-ahead bearing, unwrapped and smoothed (no jitter).
  final look = (total * 0.03).clamp(120.0, 2000.0) / sTotal;
  final rawB = <double>[];
  for (var k = 0; k < n; k++) {
    var a = pos[k];
    var b = posAt(fr[k] + look);
    if (fr[k] + look > 1) {
      a = posAt(math.max(0, 1 - look));
      b = posAt(1);
    }
    rawB.add(haversineM(a.$1, a.$2, b.$1, b.$2) < 1
        ? (rawB.isEmpty ? 0 : rawB.last)
        : bearingDeg(a.$1, a.$2, b.$1, b.$2));
  }
  final unB = unwrapAngles(rawB);
  final bearing = gaussianSmooth(unB, n / 60);

  // Zoom: route length sets the base, curvature/speed modulate.
  final latMid = pts.map((e) => e.$1).reduce((a, b) => a + b) / pts.length;
  final z0 = baseZoomForDistance(total, latMid);
  final medSpd = _median(spd.where((v) => v > 1).toList());
  final zRaw = <double>[];
  for (var k = 0; k < n; k++) {
    final a = unB[math.max(0, k - 3)], b = unB[math.min(n - 1, k + 3)];
    final km = math.max(0.05, (6 / (n - 1)) * total / 1000);
    final curv = ((b - a).abs() / km / 360).clamp(0.0, 1.0);
    final sp = interpAt(dist, spd, fr[k] * total);
    final ratio = medSpd > 0 ? (sp / medSpd - 1).clamp(-1.0, 1.0) : 0.0;
    zRaw.add(z0 + 0.4 * curv - 0.35 * ratio);
  }
  final zoom = gaussianSmooth(zRaw, n / 40);

  // Summit for the orbit.
  var summitK = -1;
  if (hasEle) {
    final maxE = ele.reduce(math.max), minE = ele.reduce(math.min);
    if (maxE - minE > 30) {
      final iMax = ele.indexOf(maxE);
      final f = dist[iMax] / (total <= 0 ? 1 : total);
      summitK = (f * (n - 1)).round().clamp(1, n - 2);
    }
  }

  // Timeline allocation.
  const intro = 0.07, outro = 0.07;
  final orbit = summitK >= 0 ? 0.10 : 0.0;
  final travel = 1 - intro - outro - orbit;
  const introN = 40, outroN = 40, orbitN = 72;

  FlyKeyframe kf(double u, int k,
      {double? b, double? pt, double? z, double ov = 0, double? prog}) {
    final f = fr[k];
    final d = f * total;
    return FlyKeyframe(
      u: u,
      lat: pos[k].$1,
      lon: pos[k].$2,
      bearing: b ?? bearing[k],
      pitch: pt ?? pitch,
      zoom: z ?? zoom[k],
      overview: ov,
      progress: prog ?? f,
      distM: d,
      eleM: interpAt(dist, ele, d),
      speedKmh: interpAt(dist, spd, d),
      gradePct: gradeAt(d),
      elapsedS: interpAt(dist, elapsed, d),
    );
  }

  final frames = <FlyKeyframe>[];
  // Intro: overview → follow cam, sweeping bearing, pitch rising.
  for (var i = 0; i < introN; i++) {
    final e = easeInOut(i / introN);
    frames.add(kf(intro * i / introN, 0,
        b: bearing[0] - 40 * (1 - e),
        pt: 20 + (pitch - 20) * e,
        ov: 1 - e,
        prog: 0));
  }
  var summitFrame = -1;
  for (var k = 0; k < n; k++) {
    final pastOrbit = summitK >= 0 && k > summitK;
    final u = intro + travel * fr[k] + (pastOrbit ? orbit : 0);
    frames.add(kf(u, k, b: bearing[k] + (pastOrbit ? 360 : 0)));
    if (k == summitK) {
      summitFrame = frames.length - 1;
      final u0 = u;
      for (var i = 1; i <= orbitN; i++) {
        final sP = i / orbitN;
        final e = easeInOut(sP);
        frames.add(kf(u0 + orbit * sP, k,
            b: bearing[k] + 360 * e,
            pt: pitch + 5 * math.sin(math.pi * sP),
            z: zoom[k] + 0.5 * math.sin(math.pi * sP)));
      }
    }
  }
  // Outro: pull back to overview.
  final last = n - 1;
  final bEnd = bearing[last] + (summitK >= 0 ? 360 : 0);
  for (var i = 1; i <= outroN; i++) {
    final e = easeInOut(i / outroN);
    frames.add(kf(1 - outro + outro * i / outroN, last,
        b: bEnd + 30 * e, pt: pitch - 25 * e, ov: e, prog: 1));
  }

  final routeIdx = downsampleIndices(pts, 2500);
  return FlyoverPlan(
    route: [for (final i in routeIdx) pts[i]],
    frames: frames,
    totalDistM: total,
    hasElevation: hasEle,
    summitFrame: summitFrame,
  );
}

/// Zoom (512px tiles) so the follow cam crosses ~half a screen per second
/// for a 30 s flight, clamped to sensible limits.
double baseZoomForDistance(double totalM, double lat) {
  if (totalM <= 0) return 15;
  final z = math.log(4.7e8 * math.cos(lat * math.pi / 180) / totalM) / math.ln2;
  return z.clamp(11.5, 16.3);
}

FlyKeyframe _copyU(FlyKeyframe f, double u) => FlyKeyframe(
      u: u, lat: f.lat, lon: f.lon, bearing: f.bearing, pitch: f.pitch,
      zoom: f.zoom, overview: f.overview, progress: f.progress,
      distM: f.distM, eleM: f.eleM, speedKmh: f.speedKmh,
      gradePct: f.gradePct, elapsedS: f.elapsedS,
    );

List<double> _fillNulls(List<double?> v) {
  final firstValid = v.firstWhere((e) => e != null, orElse: () => 0) ?? 0;
  var last = firstValid;
  return [
    for (final e in v)
      if (e != null) (last = e) else last
  ];
}

double _median(List<double> v) {
  if (v.isEmpty) return 0;
  final c = List.of(v)..sort();
  return c[c.length ~/ 2];
}
