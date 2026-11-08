import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/features/segments/domain/live_segment_board.dart';
import 'package:virya/features/segments/domain/live_segment_tracker.dart';
import 'package:virya/features/segments/domain/route_measure.dart';
import 'package:virya/features/segments/domain/segment_codec.dart';
import 'package:virya/features/segments/domain/segment_cues.dart';
import 'package:virya/features/segments/domain/segment_models.dart';

import 'segment_fixtures.dart';

LiveSegmentView view(
  LiveSegmentPhase phase, {
  String id = 's',
  int elapsedS = 0,
  double? delta,
  double? toStart,
  DateTime? when,
  bool? isPr,
  int? finalS,
}) => LiveSegmentView(
  id: id,
  name: 'Tanjakan',
  at: when ?? t0,
  state: LiveSegmentState(
    phase: phase,
    segmentLengthM: 1000,
    elapsedS: elapsedS,
    ghostDeltaS: delta,
    distanceToStartM: toStart,
    isNewPr: isPr,
    finalTimeS: finalS,
  ),
);

void main() {
  group('RouteMeasure', () {
    final route = RouteMeasure.fromSamples(pass(5, 1000));

    test('mengukur panjang rute', () {
      expect(route.lengthM, closeTo(1400, 6));
    });

    test('memotong rute sesuai rentang dan menipiskan titik', () {
      final line = route.slice(200, 700);
      final full = RouteMeasure.fromSamples(pass(5, 1000));
      expect(line.first, full.points[full.indexAt(200)]);
      expect(line.last, full.points[full.indexAt(700)]);
      // 500 m dengan titik tiap 5 m ditipiskan jadi sekitar tiap 15 m.
      expect(line.length, inInclusiveRange(30, 40));
    });

    test('rentang terbalik menghasilkan potongan kosong', () {
      expect(route.slice(700, 200), isEmpty);
    });
  });

  test('draf segmen wajib bernama dan cukup panjang', () {
    expect(segmentDraftError('  ', 500), isNotNull);
    expect(segmentDraftError('Bukit', 50), isNotNull);
    expect(segmentDraftError('Bukit', 500), isNull);
  });

  test('kotak pembatas memakai margin dalam meter', () {
    final b = SegmentBounds.of(straightSegment(400));
    final (nearLat, nearLon) = at(-300, 0);
    final (farLat, farLon) = at(-500, 0);
    expect(b.contains(nearLat, nearLon, 350), isTrue);
    expect(b.contains(farLat, farLon, 350), isFalse);
  });

  test('keluarga olahraga menentukan segmen yang berlaku', () {
    expect(segmentAllowsSport('roadCycling', SportType.mountainBiking), isTrue);
    expect(segmentAllowsSport('roadCycling', SportType.roadRunning), isFalse);
    expect(segmentAllowsSport('hiking', SportType.walking), isTrue);
    expect(segmentAllowsSport(null, SportType.walking), isTrue);
    expect(segmentAllowsSport(null, SportType.strength), isFalse);
  });

  test('isi JSON yang rusak tidak melempar error', () {
    expect(decodePolyline('bukan json'), isEmpty);
    expect(decodeMarks('{"a":1}'), isEmpty);
    expect(decodeMarks(encodeMarks([10, 20])), [10, 20]);
    final line = decodePolyline(encodePolyline([(-6.9, 107.6)]));
    expect(line.single, (-6.9, 107.6));
  });

  group('LiveSegmentBoard', () {
    LiveSegmentSeed seed(String id, double eastM) => LiveSegmentSeed(
      id: id,
      name: id,
      polyline: [at(eastM, 0), at(eastM + 400, 0)],
    );

    test('segmen yang jauh tidak dihitung', () {
      final board = LiveSegmentBoard([
        seed('dekat', 0),
        for (var i = 0; i < 300; i++) seed('jauh$i', 50000.0 + i * 2000),
      ]);
      final (lat, lon) = at(-100, 0);
      final v = board.update(lat, lon, t0);
      expect(board.lastEvaluated, 1);
      expect(v?.id, 'dekat');
      expect(v?.state.phase, LiveSegmentPhase.approaching);
    });

    test('hasil ditahan 10 detik lalu hilang', () {
      final board = LiveSegmentBoard([seed('a', 0)]);
      LiveSegmentView? last;
      var done = -1;
      final samples = pass(10, 400);
      for (final (i, s) in samples.indexed) {
        last = board.update(s.lat, s.lon, s.time);
        if (last?.state.phase == LiveSegmentPhase.finished) {
          done = i;
          break;
        }
      }
      expect(done, greaterThan(0));
      expect(last?.state.isNewPr, isTrue);

      final (lat, lon) = at(600, 0);
      final doneAt = samples[done].time;
      final held = board.update(lat, lon, doneAt.add(const Duration(seconds: 5)));
      expect(held?.state.phase, LiveSegmentPhase.finished);
      expect(board.update(lat, lon, doneAt.add(const Duration(seconds: 11))), isNull);
    });

    test('segmen tanpa cukup titik diabaikan', () {
      final board = LiveSegmentBoard([
        LiveSegmentSeed(id: 'x', name: 'x', polyline: [at(0, 0)]),
      ]);
      expect(board.isEmpty, isTrue);
    });
  });

  group('kalimat suara', () {
    test('selisih ghost dalam bahasa Indonesia', () {
      expect(ghostPhrase(-2), 'Kamu 2 detik di depan ghost.');
      expect(ghostPhrase(5.4), 'Kamu 5 detik di belakang ghost.');
      expect(ghostPhrase(-65), 'Kamu 1 menit 5 detik di depan ghost.');
      expect(ghostPhrase(0.2), 'Kamu sejajar dengan ghost.');
    });

    test('label selisih untuk HUD', () {
      expect(ghostDeltaLabel(-65), '-1:05');
      expect(ghostDeltaLabel(4), '+0:04');
      expect(ghostDeltaLabel(0.3), '0:00');
    });

    test('pengumuman mendekat tidak berulang dalam 3 menit', () {
      final p = SegmentCuePlanner();
      expect(
        p.next(view(LiveSegmentPhase.approaching, toStart: 212)),
        'Segmen Tanjakan, 200 meter lagi.',
      );
      expect(p.next(view(LiveSegmentPhase.approaching, toStart: 150)), isNull);
      expect(p.next(null), isNull);
      expect(
        p.next(
          view(
            LiveSegmentPhase.approaching,
            toStart: 212,
            when: t0.add(const Duration(minutes: 1)),
          ),
        ),
        isNull,
      );
      expect(
        p.next(null),
        isNull,
      );
      expect(
        p.next(
          view(
            LiveSegmentPhase.approaching,
            toStart: 212,
            when: t0.add(const Duration(minutes: 4)),
          ),
        ),
        isNotNull,
      );
    });

    test('ghost dibacakan tiap 30 detik saja', () {
      final p = SegmentCuePlanner();
      expect(
        p.next(view(LiveSegmentPhase.active, delta: -1)),
        'Segmen Tanjakan dimulai.',
      );
      expect(p.next(view(LiveSegmentPhase.active, elapsedS: 29, delta: -1)), isNull);
      expect(
        p.next(view(LiveSegmentPhase.active, elapsedS: 30, delta: -2)),
        'Kamu 2 detik di depan ghost.',
      );
      expect(p.next(view(LiveSegmentPhase.active, elapsedS: 45, delta: -2)), isNull);
    });

    test('tanpa ghost tidak ada selisih yang dibacakan', () {
      final p = SegmentCuePlanner();
      p.next(view(LiveSegmentPhase.active));
      expect(p.next(view(LiveSegmentPhase.active, elapsedS: 60)), isNull);
    });

    test('hasil dibacakan sekali dan sesuai rekor', () {
      final p = SegmentCuePlanner();
      final fin = view(
        LiveSegmentPhase.finished,
        delta: -7,
        isPr: true,
        finalS: 120,
      );
      expect(
        p.next(fin),
        'Rekor baru di Tanjakan! Waktumu 2 menit, lebih cepat 7 detik.',
      );
      expect(p.next(fin), isNull);

      final slower = SegmentCuePlanner().next(
        view(LiveSegmentPhase.finished, delta: 7, isPr: false, finalS: 120),
      );
      expect(slower, contains('7 detik lebih lambat'));
      final first = SegmentCuePlanner().next(
        view(LiveSegmentPhase.finished, isPr: true, finalS: 120),
      );
      expect(first, contains('ghost berikutnya'));
    });
  });
}
