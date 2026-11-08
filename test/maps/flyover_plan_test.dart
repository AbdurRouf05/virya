import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:stravo/core/data/demo_data.dart';
import 'package:stravo/core/models/track_sample.dart';
import 'package:stravo/features/maps/domain/flyover_plan.dart';
import 'package:stravo/features/maps/domain/route_geometry.dart';

void main() {
  group('geometry', () {
    test('haversine ~111 km per degree latitude', () {
      expect(haversineM(0, 0, 1, 0), closeTo(111195, 50));
    });
    test('bearing cardinal directions', () {
      expect(bearingDeg(0, 0, 1, 0), closeTo(0, 1e-6));
      expect(bearingDeg(0, 0, 0, 1), closeTo(90, 1e-6));
      expect(bearingDeg(0, 0, -1, 0), closeTo(180, 1e-6));
      expect(bearingDeg(0, 0, 0, -1), closeTo(270, 1e-6));
    });
    test('Douglas–Peucker keeps endpoints and corners, drops collinear', () {
      final pts = <LatLon>[
        for (var i = 0; i <= 10; i++) (0.0, i * 0.001), // east
        for (var i = 1; i <= 10; i++) (i * 0.001, 0.01), // north
      ];
      final idx = simplifyIndices(pts, 1);
      expect(idx, [0, 10, 20]);
    });
    test('downsampleIndices caps size', () {
      final pts = [
        for (var i = 0; i < 5000; i++)
          (math.sin(i / 50) * 0.01, i * 0.0001)
      ];
      final idx = downsampleIndices(pts, 300);
      expect(idx.length, lessThanOrEqualTo(300));
      expect(idx.first, 0);
      expect(idx.last, 4999);
      for (var i = 1; i < idx.length; i++) {
        expect(idx[i], greaterThan(idx[i - 1]));
      }
    });
    test('Catmull–Rom passes through control points', () {
      const a = (0.0, 0.0), b = (1.0, 1.0), c = (2.0, 0.0), d = (3.0, 1.0);
      expect(catmullRom(a, b, c, d, 0), b);
      final end = catmullRom(a, b, c, d, 1);
      expect(end.$1, closeTo(2, 1e-9));
      expect(end.$2, closeTo(0, 1e-9));
      final path = catmullRomPath([a, b, c, d], steps: 4);
      expect(path.first, a);
      expect(path.last, d);
      expect(path.length, 3 * 4 + 1);
    });
    test('unwrapAngles removes 360° jumps', () {
      expect(unwrapAngles([350, 10, 30, 340]), [350, 370, 390, 340]);
      expect(unwrapAngles([10, 350]), [10, -10]);
    });
    test('gaussianSmooth keeps constants and reduces noise', () {
      expect(gaussianSmooth([5, 5, 5, 5, 5], 2), everyElement(closeTo(5, 1e-9)));
      final noisy = [for (var i = 0; i < 100; i++) i.isEven ? 1.0 : -1.0];
      final sm = gaussianSmooth(noisy, 3);
      expect(sm.sublist(10, 90).every((v) => v.abs() < 0.05), isTrue);
    });
    test('interpAt', () {
      expect(interpAt([0, 10], [0, 100], 2.5), 25);
      expect(interpAt([0, 10], [0, 100], -1), 0);
      expect(interpAt([0, 10], [0, 100], 11), 100);
    });
    test('base zoom shrinks with distance', () {
      final short = baseZoomForDistance(5000, -6.8);
      final long = baseZoomForDistance(100000, -6.8);
      expect(short, greaterThan(long));
      expect(long, greaterThanOrEqualTo(11.5));
      expect(short, lessThanOrEqualTo(16.3));
    });
  });

  group('buildFlyoverPlan', () {
    final ride = demoGravelRide(seconds: 3600);
    final plan = buildFlyoverPlan(ride);

    test('demo gravel ride completes under 3s and is not empty', () {
      final samples = demoGravelRide(seconds: 3600);
      final sw = Stopwatch()..start();
      final p = buildFlyoverPlan(samples);
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(3000));
      expect(p.isEmpty, isFalse);
    });

    test('timeline is monotonic 0..1', () {
      expect(plan.frames.first.u, 0);
      expect(plan.frames.last.u, closeTo(1, 1e-9));
      for (var i = 1; i < plan.frames.length; i++) {
        expect(plan.frames[i].u, greaterThanOrEqualTo(plan.frames[i - 1].u));
      }
    });

    test('progress and distance never go backwards', () {
      for (var i = 1; i < plan.frames.length; i++) {
        expect(plan.frames[i].progress,
            greaterThanOrEqualTo(plan.frames[i - 1].progress - 1e-9));
        expect(plan.frames[i].distM,
            greaterThanOrEqualTo(plan.frames[i - 1].distM - 1e-6));
      }
      expect(plan.frames.last.progress, 1);
      expect(plan.frames.last.distM, closeTo(plan.totalDistM, 1));
    });

    test('bearing is smooth (no jitter) outside the orbit', () {
      final f = plan.frames;
      final orbitEnd = plan.summitFrame + 72;
      for (var i = 1; i < f.length; i++) {
        if (i > plan.summitFrame && i <= orbitEnd) continue;
        final du = f[i].u - f[i - 1].u;
        if (du <= 0) continue;
        // < 10° per keyframe step (~1/700 of the flight).
        expect((f[i].bearing - f[i - 1].bearing).abs(), lessThan(10),
            reason: 'frame $i');
      }
    });

    test('orbits once at the highest point', () {
      expect(plan.hasElevation, isTrue);
      expect(plan.summitFrame, greaterThan(0));
      final s = plan.frames[plan.summitFrame];
      final after = plan.frames[plan.summitFrame + 72];
      expect(after.bearing - s.bearing, closeTo(360, 1e-6));
      expect(after.lat, s.lat);
      final maxEle = plan.frames.map((f) => f.eleM).reduce(math.max);
      expect(s.eleM, closeTo(maxEle, 15));
    });

    test('camera stays near the route and pitch/zoom are sane', () {
      for (final f in plan.frames) {
        expect(f.pitch, inInclusiveRange(0, 75));
        expect(f.zoom, inInclusiveRange(10, 17.5));
        expect(f.lat, closeTo(-6.835, 0.1));
        expect(f.lon, closeTo(107.62, 0.1));
      }
    });

    test('at() interpolates and JSON columns align', () {
      final mid = plan.at(0.5);
      expect(mid.u, 0.5);
      final j = plan.toJson();
      final n = plan.frames.length;
      for (final k in ['u', 'lat', 'lon', 'b', 'pt', 'z', 'ov', 'p', 'd', 'e', 's', 'g', 't']) {
        expect((j[k] as List).length, n, reason: k);
      }
      expect((j['route'] as List).length, lessThanOrEqualTo(2500));
    });

    test('flat track: no orbit; empty/single sample handled', () {
      final flat = [
        for (var i = 0; i < 300; i++)
          TrackSample(
            time: DateTime(2026, 1, 1).add(Duration(seconds: i)),
            lat: -6.9,
            lon: 107.6 + i * 0.0001,
            ele: 700,
            speedMps: 5,
          )
      ];
      final p = buildFlyoverPlan(flat);
      expect(p.summitFrame, -1);
      expect(p.frames.last.u, closeTo(1, 1e-9));
      // Straight east → bearing ≈ 90 during travel.
      expect(p.at(0.5).bearing % 360, closeTo(90, 2));
      expect(buildFlyoverPlan(const []).isEmpty, isTrue);
      expect(buildFlyoverPlan([flat.first]).frames.length, 2);
    });
  });
}
