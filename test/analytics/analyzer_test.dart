import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:stravo/core/analytics/activity_analyzer.dart';
import 'package:stravo/core/analytics/elevation.dart';
import 'package:stravo/core/analytics/gap.dart';
import 'package:stravo/core/analytics/geo.dart';
import 'package:stravo/core/analytics/gravel.dart';
import 'package:stravo/core/analytics/power.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/data/demo_data.dart';
import 'package:stravo/core/models/track_sample.dart';

const _an = ActivityAnalyzer();
final _t0 = DateTime.utc(2026, 1, 1, 6);

/// Straight line heading north at [speed] m/s, [grade] fraction, 1 Hz.
List<TrackSample> line({
  required int seconds,
  required double speed,
  double grade = 0,
  int? hr,
  double startEle = 100,
  SurfaceType surface = SurfaceType.asphalt,
  double vibration = 0.5,
}) {
  const metersPerDegLat = earthRadiusM * math.pi / 180;
  return [
    for (var i = 0; i <= seconds; i++)
      TrackSample(
        time: _t0.add(Duration(seconds: i)),
        lat: -6.9 + i * speed / metersPerDegLat,
        lon: 107.6,
        ele: startEle + i * speed * grade,
        speedMps: speed,
        heartRate: hr,
        surface: surface,
        vibration: vibration,
      ),
  ];
}

void main() {
  group('demo gravel ride', () {
    final samples = demoGravelRide();
    final a = _an.analyze(samples, SportType.gravelCycling);

    test('basic totals are plausible', () {
      expect(a.distanceM, inInclusiveRange(25000, 45000));
      expect(a.elapsedTimeS, 5399);
      expect(a.movingTimeS, lessThan(a.elapsedTimeS));
      expect(a.movingTimeS, greaterThan(5000));
      expect(a.elevationGainM, greaterThan(400));
      expect(a.elevationLossM, greaterThan(400));
      expect(a.maxEleM, greaterThan(a.minEleM + 300));
      expect(a.avgSpeedMps, inInclusiveRange(4, 9));
      expect(a.maxSpeedMps, greaterThan(a.avgSpeedMps));
      expect(a.maxSpeedMps, lessThan(12));
      expect(a.avgHeartRate, isNotNull);
      expect(a.maxHeartRate, greaterThanOrEqualTo(a.avgHeartRate!));
      expect(a.avgCadence, inInclusiveRange(70, 90));
    });

    test('gravel sectors and grit', () {
      expect(a.gravelPct, inInclusiveRange(40, 90));
      expect(a.gravelSectors, isNotEmpty);
      for (final s in a.gravelSectors) {
        expect(s.stars, inInclusiveRange(1, 5));
        expect(s.lengthM, greaterThanOrEqualTo(300));
        expect(s.name, startsWith('Sektor ${s.number} · '));
      }
      // Numbered down to the finish.
      final nums = a.gravelSectors.map((s) => s.number).toList();
      expect(nums.last, 1);
      expect(nums.first, a.gravelSectors.length);
      final rough = a.gravelSectors
          .firstWhere((s) => s.dominantSurface == SurfaceType.roughGravel);
      expect(rough.name, contains('Makadam'));
      expect(rough.roughness, greaterThan(4));
      expect(a.gritScore, inInclusiveRange(30, 100));
      final total = a.surfaceDistanceM.values.fold<double>(0, (x, y) => x + y);
      expect(total, closeTo(a.distanceM, 1));
    });

    test('grit score on 100% asphalt is zero regardless of elevation', () {
      final grit = gritScore(
        gravelPct: 0,
        unpavedRoughness: 0,
        gainM: 1000,
        distanceM: 20000,
        sectors: const [],
      );
      expect(grit, 0.0);

      final mixedGrit = gritScore(
        gravelPct: 50,
        unpavedRoughness: 2.5,
        gainM: 500,
        distanceM: 20000,
        sectors: const [],
      );
      expect(mixedGrit, greaterThan(0));
    });

    test('climbs', () {
      expect(a.climbs, isNotEmpty);
      final big = a.climbs.reduce((x, y) => x.gainM > y.gainM ? x : y);
      expect(big.gainM, greaterThan(200));
      expect(big.category, isNot(ClimbCategory.flat));
      expect(big.vam, greaterThan(300));
      expect(big.maxGradePct, greaterThanOrEqualTo(big.avgGradePct));
    });

    test('power, effort, zones', () {
      expect(a.avgPowerW, inInclusiveRange(80, 350));
      expect(a.normalizedPowerW, greaterThanOrEqualTo(a.avgPowerW! * 0.95));
      expect(a.energyKj, greaterThan(300));
      expect(a.relativeEffort, inInclusiveRange(60, 300));
      final zoneTotal = a.hrZoneSeconds.values.fold<int>(0, (x, y) => x + y);
      expect(zoneTotal, closeTo(a.movingTimeS, 120));
      expect(a.avgGapMps, isNull);
    });

    test('splits, efforts, series, bbox', () {
      expect(a.splits.length, (a.distanceM / 1000).ceil());
      expect(a.splits.first.distanceM, closeTo(1000, 1e-6));
      final st = a.splits.fold<int>(0, (x, y) => x + y.movingTimeS);
      expect(st, closeTo(a.movingTimeS, a.splits.length));
      expect(a.splits.first.avgHeartRate, isNotNull);
      expect(a.bestEfforts.map((e) => e.label), containsAll(['5K', '10K', '20K']));
      final s = a.series;
      expect(s.length, lessThanOrEqualTo(600));
      expect(s.length, greaterThan(500));
      for (final l in [
        s.elapsedS.length,
        s.lat.length,
        s.lon.length,
        s.ele.length,
        s.speedMps.length,
        s.gradePct.length,
        s.heartRate.length,
        s.surface.length,
      ]) {
        expect(l, s.length);
      }
      expect(s.distanceM.last, closeTo(a.distanceM, 1e-6));
      expect(s.ele.reduce(math.max), closeTo(a.maxEleM, 1e-9));
      expect(a.minLat, lessThan(a.maxLat));
      expect(a.minLon, lessThan(a.maxLon));
    });

    test('fast enough: 5 h at 1 Hz < 300 ms', () {
      final big = demoGravelRide(seconds: 18000);
      _an.analyze(big, SportType.gravelCycling); // warm-up
      final sw = Stopwatch()..start();
      final r = _an.analyze(big, SportType.gravelCycling);
      sw.stop();
      expect(r.series.length, lessThanOrEqualTo(600));
      expect(sw.elapsedMilliseconds, lessThan(300));
    });
  });

  group('running / GAP', () {
    test('flat run: GAP ≈ pace', () {
      final a = _an.analyze(line(seconds: 1800, speed: 3.0), SportType.roadRunning);
      expect(a.distanceM, closeTo(5400, 5));
      expect(a.avgGapMps!, closeTo(3.0, 0.03));
      expect(a.splits.length, 6);
      expect(a.splits.last.distanceM, closeTo(400, 5));
      expect(a.splits.first.gapMps!, closeTo(3.0, 0.05));
      expect(a.splits.first.movingTimeS, closeTo(333, 2));
      final k1 = a.bestEfforts.firstWhere((e) => e.label == '1K');
      expect(k1.timeS, closeTo(333, 1));
      final k5 = a.bestEfforts.firstWhere((e) => e.label == '5K');
      expect(k5.timeS, closeTo(1667, 1));
      expect(a.bestEfforts.any((e) => e.label == '10K'), isFalse);
      // No HR -> pace-based effort: 0.5 h × (3/3.5)² × 100 ≈ 36.7
      expect(a.relativeEffort, closeTo(36.7, 1.5));
    });

    test('steep uphill run: GAP faster than pace', () {
      final a = _an.analyze(
          line(seconds: 900, speed: 2.0, grade: 0.10), SportType.trailRunning);
      expect(a.avgGapMps!, greaterThan(a.avgSpeedMps * 1.4));
      expect(a.elevationGainM, greaterThan(150));
      expect(a.climbs, hasLength(1));
      expect(a.climbs.single.avgGradePct, closeTo(10, 0.8));
      expect(a.splits.first.elevationDeltaM, closeTo(100, 5));
    });

    test('best effort picks the fastest stretch', () {
      final slow = line(seconds: 600, speed: 2.5);
      final last = slow.last;
      final fast = line(seconds: 400, speed: 5.0).skip(1).map((s) => TrackSample(
            time: s.time.add(const Duration(seconds: 600)),
            lat: s.lat + (last.lat - -6.9),
            lon: s.lon,
            ele: 100,
            speedMps: 5,
          ));
      final a = _an.analyze([...slow, ...fast], SportType.roadRunning);
      final k1 = a.bestEfforts.firstWhere((e) => e.label == '1K');
      expect(k1.timeS, closeTo(200, 1));
      expect(k1.startDistanceM, greaterThanOrEqualTo(1490));
    });
  });

  group('HR effort', () {
    test('1.5 h moderate ride ≈ 80–120 relative effort', () {
      // HR 136 → HRr 0.6 with max 190 / rest 55.
      final a = _an.analyze(
          line(seconds: 5400, speed: 7, hr: 136), SportType.roadCycling);
      expect(a.relativeEffort, inInclusiveRange(80, 120));
      expect(a.hrZoneSeconds[3], closeTo(5400, 1)); // 136/190 = 72%
    });

    test('1.5 h moderate ride without HR ≈ 80–120', () {
      final a = _an.analyze(
          line(seconds: 5400, speed: 8.0), SportType.roadCycling);
      expect(a.relativeEffort, inInclusiveRange(80, 120));
    });
  });

  group('edge cases', () {
    test('empty', () {
      final a = _an.analyze(const [], SportType.roadCycling);
      expect(a.distanceM, 0);
      expect(a.series.length, 0);
      expect(_an.analyze(const [], SportType.roadRunning).splits, isEmpty);
    });

    test('single sample', () {
      final a = _an.analyze([TrackSample(time: _t0, lat: 1, lon: 2)],
          SportType.roadRunning);
      expect(a.distanceM, 0);
      expect(a.series.length, 1);
      expect(a.minLat, 1);
      expect(a.maxLon, 2);
    });

    test('null elevation and speed, duplicates, gaps, unsorted', () {
      final base = line(seconds: 600, speed: 4);
      final samples = <TrackSample>[
        for (var i = 0; i < base.length; i++)
          TrackSample(
            time: i > 300 ? base[i].time.add(const Duration(minutes: 20)) : base[i].time,
            lat: base[i].lat,
            lon: base[i].lon,
            ele: i % 3 == 0 ? null : base[i].ele,
          ),
        // duplicate timestamp
        TrackSample(time: base[100].time, lat: base[100].lat, lon: base[100].lon),
      ];
      final shuffled = samples.reversed.toList();
      final a = _an.analyze(shuffled, SportType.roadCycling);
      expect(a.distanceM, closeTo(2400, 10));
      expect(a.elapsedTimeS, 600 + 1200);
      // The 20-min stop (no distance) is not moving time.
      expect(a.movingTimeS, closeTo(600, 5));
      expect(a.avgSpeedMps, closeTo(4, 0.1));
      expect(a.maxSpeedMps, lessThan(5));
    });

    test('no elevation at all', () {
      final s = [
        for (final x in line(seconds: 300, speed: 3))
          TrackSample(time: x.time, lat: x.lat, lon: x.lon, speedMps: 3)
      ];
      final a = _an.analyze(s, SportType.roadRunning);
      expect(a.elevationGainM, 0);
      expect(a.climbs, isEmpty);
      expect(a.avgGapMps!, closeTo(3, 0.05));
    });

    test('paused samples excluded', () {
      final s = line(seconds: 600, speed: 5)
          .map((x) => x.time.difference(_t0).inSeconds.isEven
              ? x
              : x.copyWith(paused: x.time.difference(_t0).inSeconds > 300))
          .toList();
      final a = _an.analyze(s, SportType.roadCycling);
      expect(a.movingTimeS, lessThan(500));
    });
  });

  group('building blocks', () {
    test('haversine', () {
      expect(haversineM(0, 0, 0, 1), closeTo(111195, 10));
    });

    test('hysteresis ignores noise', () {
      final noisy = [for (var i = 0; i < 1000; i++) 100 + (i.isEven ? 1.0 : -1.0)];
      expect(gainLoss(noisy).gain, 0);
      final ramp = [for (var i = 0; i <= 100; i++) i.toDouble()] +
          [for (var i = 99; i >= 50; i--) i.toDouble()];
      final gl = gainLoss(ramp);
      expect(gl.gain, 100);
      expect(gl.loss, 50);
    });

    test('gap factor', () {
      expect(gapFactor(0), 1);
      expect(gapFactor(0.1), closeTo(1.66, 0.02));
      expect(gapFactor(-0.1), greaterThanOrEqualTo(0.65));
      expect(gapFactor(0.9), gapFactor(0.30));
    });

    test('power model', () {
      final flat = cyclingPowerW(
          speed: 8, grade: 0, massKg: 80, surface: SurfaceType.asphalt);
      // roll 80*9.81*0.005*8 = 31.4, aero 0.5*1.15*0.4*512 = 117.8; /0.97
      expect(flat, closeTo((31.38 + 117.76) / 0.97, 1));
      final gravel = cyclingPowerW(
          speed: 8, grade: 0, massKg: 80, surface: SurfaceType.roughGravel);
      expect(gravel, greaterThan(flat));
      expect(
          cyclingPowerW(
              speed: 15, grade: -0.08, massKg: 80, surface: SurfaceType.asphalt),
          0);
    });
  });
}
