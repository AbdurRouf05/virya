import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/analytics/activity_analyzer.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/analytics/heatmap_grid.dart';
import 'package:virya/core/analytics/race_predictor.dart';

void main() {
  group('fitnessTimeline', () {
    const an = ActivityAnalyzer();

    test('empty input', () {
      expect(an.fitnessTimeline({}), isEmpty);
    });

    test('fills zero days and applies EWMA', () {
      final tl = an.fitnessTimeline({
        DateTime(2026, 3, 1, 7, 30): 100,
        DateTime(2026, 3, 1, 18): 20, // same day sums
        DateTime(2026, 3, 4): 50,
      }, until: DateTime(2026, 3, 10, 23));
      expect(tl, hasLength(10));
      expect(tl.first.day, DateTime(2026, 3, 1));
      expect(tl.last.day, DateTime(2026, 3, 10));
      expect(tl[0].load, 120);
      expect(tl[1].load, 0);
      expect(tl[3].load, 50);
      final kc = 1 - math.exp(-1 / 42), ka = 1 - math.exp(-1 / 7);
      expect(tl[0].fitness, closeTo(120 * kc, 1e-9));
      expect(tl[0].fatigue, closeTo(120 * ka, 1e-9));
      // Replay manually.
      var ctl = 0.0, atl = 0.0;
      for (final d in tl) {
        ctl += (d.load - ctl) * kc;
        atl += (d.load - atl) * ka;
        expect(d.fitness, closeTo(ctl, 1e-9));
        expect(d.fatigue, closeTo(atl, 1e-9));
        expect(d.form, closeTo(ctl - atl, 1e-9));
      }
      // Fatigue reacts faster: after a load-free week form turns positive.
      expect(tl.last.form, greaterThan(tl[3].form));
    });

    test('steady load converges to the load', () {
      final loads = {
        for (var i = 0; i < 400; i++) DateTime(2025, 1, 1 + i): 60.0,
      };
      final tl = an.fitnessTimeline(loads, until: DateTime(2026, 2, 4));
      expect(tl.last.fitness, closeTo(60, 0.5));
      expect(tl.last.fatigue, closeTo(60, 0.01));
    });

    test('until before first day gives empty', () {
      expect(
          an.fitnessTimeline({DateTime(2026, 5, 1): 10},
              until: DateTime(2026, 4, 1)),
          isEmpty);
    });

    test('lead-in preserves at least 8 days for single activity', () {
      final today = DateTime.now();
      final dayKey = DateTime(today.year, today.month, today.day);
      final load = <DateTime, double>{dayKey: 42.0};
      final first = load.keys.reduce((a, b) => a.isBefore(b) ? a : b);
      load.putIfAbsent(
          DateTime(first.year, first.month, first.day - 7), () => 0);
      final tl = an.fitnessTimeline(load, until: dayKey);
      expect(tl.length, greaterThanOrEqualTo(8));
      expect(tl.first.day, DateTime(first.year, first.month, first.day - 7));
      expect(tl.last.day, dayKey);
      expect(tl.last.load, 42.0);
    });
  });

  group('race predictor', () {
    test('riegel', () {
      expect(riegelTime(1200, 5000, 10000), closeTo(1200 * math.pow(2, 1.06), 1e-6));
    });

    test('picks closest effort', () {
      final preds = predictRaces(const [
        BestEffort(label: '400m', distanceM: 400, timeS: 80, startDistanceM: 0),
        BestEffort(label: '5K', distanceM: 5000, timeS: 1500, startDistanceM: 0),
        BestEffort(label: '10K', distanceM: 10000, timeS: 3200, startDistanceM: 0),
      ]);
      expect(preds.map((p) => p.label), ['5K', '10K', 'Half', 'Marathon']);
      expect(preds[0].timeS, 1500);
      expect(preds[1].timeS, 3200);
      expect(preds[2].basis.label, '10K');
      expect(preds[3].timeS, greaterThan(3200 * 4));
      expect(predictRaces(const []), isEmpty);
    });
  });

  group('heatmap grid', () {
    test('counts tracks once per pixel and fills gaps', () {
      final g = HeatmapGrid(zoom: 16);
      final track = [for (var i = 0; i <= 100; i++) (-6.9 + i * 0.0001, 107.6)];
      g.addTrack(track);
      g.addTrack(track);
      g.addTrack([(-6.9, 107.6), (-6.9, 107.6)]);
      expect(g.trackCount, 3);
      expect(g.maxCount, 3);
      final (x, y) = g.project(-6.9, 107.6);
      expect(g.countAtPixel(x.floor(), y.floor()), 3);
      // Continuous line: ~ 0.01° lat at z16 ≈ 1.8 k px → as many cells.
      final (_, y2) = g.project(-6.89, 107.6);
      expect(g.cellCount, greaterThanOrEqualTo((y - y2).abs().floor()));
      final (lat, lon) = g.pixelToLatLon(x, y);
      expect(lat, closeTo(-6.9, 1e-6));
      expect(lon, closeTo(107.6, 1e-6));
    });

    test('tile density aggregates to lower zoom', () {
      final g = HeatmapGrid(zoom: 14);
      g.addTrack([(-6.9, 107.6), (-6.91, 107.61)]);
      final (x, y) = g.project(-6.9, 107.6);
      final z = 12, shift = 2;
      final tx = (x.floor() >> shift) >> 8, ty = (y.floor() >> shift) >> 8;
      final tile = g.tileDensity(z, tx, ty);
      final sum = tile.fold<int>(0, (a, b) => a + b);
      expect(sum, greaterThan(0));
      expect(sum, lessThanOrEqualTo(g.cellCount));
    });
  });
}
