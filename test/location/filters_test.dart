import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/location/filters/auto_pause.dart';
import 'package:virya/core/location/filters/elevation_filter.dart';
import 'package:virya/core/location/filters/fix_gate.dart';
import 'package:virya/core/location/filters/grade_calculator.dart';
import 'package:virya/core/location/filters/kalman_filter.dart';
import 'package:virya/core/location/geo_math.dart';
import 'package:virya/core/location/location_fix.dart';

final t0 = DateTime(2026, 1, 1, 7);
DateTime at(int s) => t0.add(Duration(seconds: s));

LocationFix fix(int s, double lat, double lon, {double acc = 5}) =>
    LocationFix(time: at(s), lat: lat, lon: lon, accuracy: acc);

void main() {
  group('GeoMath', () {
    test('haversine: 1 degree latitude ~ 111.2 km', () {
      expect(GeoMath.haversine(0, 0, 1, 0), closeTo(111195, 50));
      expect(GeoMath.haversine(-6.9, 107.6, -6.9, 107.6), 0);
    });

    test('bearing cardinal directions', () {
      expect(GeoMath.bearing(0, 0, 1, 0), closeTo(0, 1e-6));
      expect(GeoMath.bearing(0, 0, 0, 1), closeTo(90, 1e-6));
      expect(GeoMath.bearing(0, 0, -1, 0), closeTo(180, 1e-6));
      expect(GeoMath.bearing(0, 0, 0, -1), closeTo(270, 1e-6));
    });

    test('pressure altitude: 1013.25 hPa = 0 m, ~899 hPa ~ 1000 m', () {
      expect(GeoMath.pressureAltitude(1013.25), closeTo(0, 1e-6));
      expect(GeoMath.pressureAltitude(898.75), closeTo(1000, 15));
    });
  });

  group('LatLonKalmanFilter', () {
    test('first fix passes through, then reduces noise', () {
      final k = LatLonKalmanFilter(processNoiseMps: 1);
      final (lat0, lon0) = k.process(-6.9, 107.6, 5, at(0));
      expect(lat0, -6.9);
      expect(lon0, 107.6);

      // Stationary truth with +/- ~5 m alternating noise.
      final rnd = math.Random(1);
      var rawErr = 0.0, filtErr = 0.0;
      for (var i = 1; i <= 120; i++) {
        final nLat = -6.9 + (rnd.nextDouble() - .5) * 0.0001;
        final nLon = 107.6 + (rnd.nextDouble() - .5) * 0.0001;
        final (fl, fo) = k.process(nLat, nLon, 5, at(i));
        if (i > 20) {
          rawErr += GeoMath.haversine(-6.9, 107.6, nLat, nLon);
          filtErr += GeoMath.haversine(-6.9, 107.6, fl, fo);
        }
      }
      expect(filtErr, lessThan(rawErr * 0.6));
    });

    test('accurate fixes weigh more than inaccurate ones', () {
      final k = LatLonKalmanFilter(processNoiseMps: 3);
      k.process(0, 0, 5, at(0));
      final (latBad, _) = k.process(0.0001, 0, 50, at(1));
      k.reset();
      k.process(0, 0, 5, at(0));
      final (latGood, _) = k.process(0.0001, 0, 3, at(1));
      expect(latGood, greaterThan(latBad));
    });
  });

  group('FixGate', () {
    test('drops fixes worse than 18 m accuracy', () {
      final g = FixGate(maxAccuracyM: 18, maxPlausibleSpeedMps: 30);
      expect(g.check(fix(0, 0, 0, acc: 25)), FixRejectReason.inaccurate);
      expect(g.check(fix(0, 0, 0, acc: 18)), isNull);
    });

    test('rejects teleports and duplicates, re-anchors after repeated rejects',
        () {
      final g = FixGate(
          maxAccuracyM: 18, maxPlausibleSpeedMps: 30, maxConsecutiveRejects: 3);
      expect(g.check(fix(0, 0, 0)), isNull);
      expect(g.check(fix(0, 0, 0)), FixRejectReason.duplicate);
      // ~1.1 km in 1 s.
      expect(g.check(fix(1, 0.01, 0)), FixRejectReason.teleport);
      expect(g.check(fix(2, 0.01, 0)), FixRejectReason.teleport);
      expect(g.check(fix(3, 0.01, 0)), FixRejectReason.teleport);
      // Fourth in a row: accept, new reference.
      expect(g.check(fix(4, 0.01, 0)), isNull);
      // Normal 8 m/s movement is fine.
      expect(g.check(fix(5, 0.01 + 8 / 111195, 0)), isNull);
    });
  });

  group('AutoPauseDetector', () {
    test('pauses after 4 s below threshold, resumes after 2 s above', () {
      final a = AutoPauseDetector(thresholdMps: 1.0);
      var s = 0;
      for (; s < 10; s++) {
        expect(a.update(5, at(s)), isFalse);
      }
      // Slow down at s=10.
      expect(a.update(0.2, at(10)), isFalse);
      expect(a.update(0.2, at(12)), isFalse);
      expect(a.update(0.2, at(13)), isFalse);
      expect(a.update(0.2, at(14)), isTrue);
      expect(a.isPaused, isTrue);
      // Brief blip does not resume.
      expect(a.update(2, at(15)), isFalse);
      expect(a.update(0.1, at(16)), isFalse);
      expect(a.isPaused, isTrue);
      expect(a.update(2, at(20)), isFalse);
      expect(a.update(2, at(21)), isFalse);
      expect(a.update(2, at(22)), isTrue);
      expect(a.isPaused, isFalse);
    });

    test('running threshold 0.5 m/s keeps slow jog moving', () {
      final a = AutoPauseDetector(thresholdMps: 0.5);
      for (var s = 0; s < 20; s++) {
        a.update(0.8, at(s));
      }
      expect(a.isPaused, isFalse);
    });

    test('disabled never pauses', () {
      final a = AutoPauseDetector(thresholdMps: 1, enabled: false);
      for (var s = 0; s < 20; s++) {
        a.update(0, at(s));
      }
      expect(a.isPaused, isFalse);
    });
  });

  group('ElevationFilter', () {
    test('GNSS noise on flat ground adds (almost) no gain', () {
      final e = ElevationFilter();
      final rnd = math.Random(3);
      for (var i = 0; i < 600; i++) {
        e.update(gnssAltitude: 800 + (rnd.nextDouble() - .5) * 6);
      }
      expect(e.gain, lessThan(5));
      expect(e.loss, lessThan(5));
    });

    test('steady climb counted, descent counted as loss', () {
      final e = ElevationFilter();
      for (var i = 0; i <= 300; i++) {
        e.update(gnssAltitude: 500 + i * 0.5); // +150 m
      }
      for (var i = 0; i <= 200; i++) {
        e.update(gnssAltitude: 650 - i * 0.5); // -100 m
      }
      for (var i = 0; i < 60; i++) {
        e.update(gnssAltitude: 550); // settle EMA
      }
      // Hysteresis may leave < 5 m uncounted at each turning point.
      expect(e.gain, closeTo(150, 9)); // peak also trimmed by EMA lag
      expect(e.loss, closeTo(100, 9));
    });

    test('barometer used when present, offset tracks GNSS level', () {
      final e = ElevationFilter();
      // 900 hPa ~ 988 m; GNSS says 1000 m.
      for (var i = 0; i < 50; i++) {
        e.update(gnssAltitude: 1000, pressureHPa: 900);
      }
      expect(e.usingBarometer, isTrue);
      expect(e.altitude, closeTo(1000, 1));
      expect(e.gain, 0);
    });

    test('paused updates track altitude without totals', () {
      final e = ElevationFilter();
      for (var i = 0; i <= 100; i++) {
        e.update(gnssAltitude: 100 + i.toDouble(), countTotals: false);
      }
      expect(e.gain, 0);
      expect(e.altitude, greaterThan(180));
    });
  });

  group('GradeCalculator', () {
    test('8 % ramp over 50 m window', () {
      final g = GradeCalculator();
      for (var d = 0; d <= 200; d += 5) {
        g.add(d.toDouble(), 100 + d * 0.08);
      }
      expect(g.gradePct, closeTo(8, 0.01));
    });

    test('needs minimum span and holds value when stationary', () {
      final g = GradeCalculator();
      g.add(0, 100);
      expect(g.add(10, 101), 0); // span < 20 m
      expect(g.add(25, 102.5), closeTo(10, 0.01));
      expect(g.add(25, 150), closeTo(10, 0.01));
    });
  });
}
