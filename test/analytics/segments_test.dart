import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:stravo/core/analytics/geo.dart';
import 'package:stravo/core/models/track_sample.dart';
import 'package:stravo/features/segments/domain/live_segment_tracker.dart';
import 'package:stravo/features/segments/domain/segment_matcher.dart';
import 'package:stravo/features/segments/domain/segment_path.dart';

const lat0 = -6.9, lon0 = 107.6;
const _ky = earthRadiusM * math.pi / 180;
final _kx = _ky * math.cos(lat0 * math.pi / 180);

(double, double) at(double eastM, double northM) =>
    (lat0 + northM / _ky, lon0 + eastM / _kx);

/// Segment: 1 km due east, then 500 m north (L-shape), points every 20 m.
final segment = <(double, double)>[
  for (var x = 0.0; x <= 1000; x += 20) at(x, 0),
  for (var y = 20.0; y <= 500; y += 20) at(1000, y),
];

/// Position along the L at distance d (extended straight before/after).
(double, double) alongL(double d, {double wobble = 0}) {
  if (d <= 1000) return at(d, wobble);
  return at(1000 + wobble, d - 1000);
}

final t0 = DateTime.utc(2026, 6, 1, 7);

/// Ride from −200 m to L+200 m at [speed], starting at [startS] seconds.
List<TrackSample> pass(double speed, int startS, {double wobbleAmp = 4}) {
  final out = <TrackSample>[];
  for (var k = 0;; k++) {
    final d = -200 + k * speed;
    if (d > 1700) break;
    final w = wobbleAmp * math.sin(k / 7);
    final (lat, lon) = alongL(d, wobble: w);
    out.add(TrackSample(
        time: t0.add(Duration(seconds: startS + k)), lat: lat, lon: lon));
  }
  return out;
}

void main() {
  test('segment path geometry', () {
    final p = SegmentPath(segment);
    expect(p.lengthM, closeTo(1500, 2));
    expect(p.markCount, 31);
    final pr = p.project(at(500, 10).$1, at(500, 10).$2, lookAheadM: 1e9);
    expect(pr.progressM, closeTo(500, 1));
    expect(pr.deviationM, closeTo(10, 0.5));
    expect(timeAtProgress([0, 10, 30], 75), closeTo(20, 1e-9));
  });

  group('SegmentMatcher', () {
    test('finds two efforts with correct times and ghost marks', () {
      // Pass 1 at 5 m/s, then a detour far away, pass 2 at 6 m/s.
      final p1 = pass(5, 0);
      final detour = [
        for (var k = 1; k <= 60; k++)
          TrackSample(
            time: p1.last.time.add(Duration(seconds: k)),
            lat: at(2000, 3000).$1,
            lon: at(2000, 3000).$2,
          )
      ];
      final p2 = pass(6, 2000);
      final efforts =
          const SegmentMatcher().findEfforts(segment, [...p1, ...detour, ...p2]);
      expect(efforts, hasLength(2));
      expect(efforts[0].elapsedS, closeTo(300, 3));
      expect(efforts[1].elapsedS, closeTo(250, 3));
      expect(efforts[0].startedAt, t0.add(const Duration(seconds: 40)));
      final marks = efforts[0].progressS;
      expect(marks, hasLength(31));
      expect(marks.first, 0);
      expect(marks[10], closeTo(100, 2)); // 500 m at 5 m/s
      for (var i = 1; i < marks.length; i++) {
        expect(marks[i], greaterThanOrEqualTo(marks[i - 1]));
      }
    });

    test('rejects a track that leaves the course', () {
      // Starts on the segment, then goes straight east instead of north.
      final out = <TrackSample>[];
      for (var k = 0; k < 400; k++) {
        final (lat, lon) = at(-100 + k * 5.0, 0);
        out.add(TrackSample(
            time: t0.add(Duration(seconds: k)), lat: lat, lon: lon));
      }
      expect(const SegmentMatcher().findEfforts(segment, out), isEmpty);
    });

    test('rejects reversed direction', () {
      final rev = pass(5, 0).reversed.toList();
      final fixed = [
        for (var i = 0; i < rev.length; i++)
          TrackSample(
              time: t0.add(Duration(seconds: i)),
              lat: rev[i].lat,
              lon: rev[i].lon)
      ];
      expect(const SegmentMatcher().findEfforts(segment, fixed), isEmpty);
    });
  });

  group('LiveSegmentTracker', () {
    test('approach, ghost delta, finish, PR', () {
      final pr = const SegmentMatcher().findEfforts(segment, pass(5, 0)).single;
      final tracker = LiveSegmentTracker(
        polyline: segment,
        prProgressS: pr.progressS,
        prTimeS: pr.elapsedS,
      );
      final phases = <LiveSegmentPhase>[];
      LiveSegmentState? finished;
      double? midDelta;
      // Faster ride: 6 m/s, starting far away (-600 m).
      for (var k = 0;; k++) {
        final d = -600 + k * 6.0;
        if (d > 1700) break;
        final (lat, lon) = alongL(d, wobble: 3 * math.sin(k / 5));
        final s = tracker.update(lat, lon, t0.add(Duration(seconds: k)));
        if (phases.isEmpty || phases.last != s.phase) phases.add(s.phase);
        if (s.phase == LiveSegmentPhase.active &&
            (s.progressM - 750).abs() < 4) {
          midDelta = s.ghostDeltaS;
        }
        if (s.phase == LiveSegmentPhase.finished) finished = s;
      }
      expect(phases.take(4), [
        LiveSegmentPhase.idle,
        LiveSegmentPhase.approaching,
        LiveSegmentPhase.active,
        LiveSegmentPhase.finished,
      ]);
      // At 750 m: PR 150 s vs now 125 s -> ~25 s ahead.
      expect(midDelta, isNotNull);
      expect(midDelta!, closeTo(-25, 3));
      expect(finished!.finalTimeS, closeTo(250, 3));
      expect(finished.isNewPr, isTrue);
      expect(finished.ghostDeltaS!, closeTo(-50, 4));
      expect(finished.progressMarksS, hasLength(31));
    });

    test('abandons when leaving the course', () {
      final tracker = LiveSegmentTracker(polyline: segment);
      final phases = <LiveSegmentPhase>{};
      for (var k = 0; k < 300; k++) {
        final (lat, lon) = at(-100 + k * 5.0, 0); // never turns north
        phases.add(
            tracker.update(lat, lon, t0.add(Duration(seconds: k))).phase);
      }
      expect(phases, contains(LiveSegmentPhase.active));
      expect(phases, contains(LiveSegmentPhase.abandoned));
      expect(phases, isNot(contains(LiveSegmentPhase.finished)));
    });
  });
}
