import 'package:flutter_test/flutter_test.dart';
import 'package:virya/features/gym/domain/gym_math.dart';
import 'package:virya/features/gym/domain/gym_models.dart';
import 'package:virya/features/gym/domain/session_draft.dart';

SetRecord _s(
  String ex,
  double w,
  int r, {
  DateTime? at,
  bool warmup = false,
  String session = 's1',
}) => SetRecord(
  sessionId: session,
  exerciseId: ex,
  sessionStart: at ?? DateTime(2026, 11, 2, 18),
  weightKg: w,
  reps: r,
  isWarmup: warmup,
);

void main() {
  group('epley1rm', () {
    test('rumus Epley', () {
      expect(epley1rm(100, 10), closeTo(133.33, 0.01));
      expect(epley1rm(60, 5), closeTo(70, 0.001));
    });
    test('satu repetisi = beban itu sendiri', () {
      expect(epley1rm(140, 1), 140);
    });
    test('input tidak valid = 0', () {
      expect(epley1rm(0, 5), 0);
      expect(epley1rm(80, 0), 0);
    });
  });

  test('totalVolume mengabaikan pemanasan kecuali diminta', () {
    final sets = [_s('a', 20, 10, warmup: true), _s('a', 60, 8), _s('a', 60, 6)];
    expect(totalVolume(sets), 840);
    expect(totalVolume(sets, includeWarmup: true), 1040);
  });

  group('personalRecords', () {
    test('null bila tidak ada set kerja', () {
      expect(personalRecords([_s('a', 40, 10, warmup: true)]), isNull);
      expect(personalRecords(const []), isNull);
    });

    test('beban maks, e1RM, dan set volume terbaik terpisah', () {
      final pr = personalRecords([
        _s('a', 100, 3), // maks beban; e1RM 110
        _s('a', 80, 12), // volume 960; e1RM 112
        _s('a', 90, 8), // volume 720; e1RM 114
        _s('a', 120, 5, warmup: true), // diabaikan
      ])!;
      expect(pr.maxWeightKg, 100);
      expect(pr.maxWeightReps, 3);
      expect(pr.best1rm, closeTo(114, 0.001));
      expect(pr.bestSetWeightKg, 80);
      expect(pr.bestSetReps, 12);
      expect(pr.bestSetVolume, 960);
    });

    test('per gerakan', () {
      final m = personalRecordsByExercise([
        _s('a', 50, 5),
        _s('b', 30, 10),
        _s('c', 10, 10, warmup: true),
      ]);
      expect(m.keys, unorderedEquals(['a', 'b']));
      expect(m['b']!.maxWeightKg, 30);
    });
  });

  group('weeklyVolume', () {
    test('minggu dimulai Senin', () {
      // 8 Nov 2026 = Minggu.
      expect(gymWeekStart(DateTime(2026, 11, 8, 20)), DateTime(2026, 11, 2));
      expect(gymWeekStart(DateTime(2026, 11, 2)), DateTime(2026, 11, 2));
    });

    test('dikelompokkan per minggu, lama → baru, kosong = 0', () {
      final now = DateTime(2026, 11, 8, 12);
      final w = weeklyVolume([
        _s('a', 100, 5, at: DateTime(2026, 11, 3, 18)),
        _s('a', 100, 5, at: DateTime(2026, 11, 7, 18)),
        _s('a', 50, 10, at: DateTime(2026, 10, 27, 18)),
        _s('a', 50, 10, at: DateTime(2026, 11, 4), warmup: true),
        _s('a', 50, 10, at: DateTime(2025, 1, 1)), // di luar jendela
      ], now, weeks: 3);
      expect(w.length, 3);
      expect(w.map((e) => e.$1).toList(), [
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 26),
        DateTime(2026, 11, 2),
      ]);
      expect(w.map((e) => e.$2).toList(), [0, 500, 1000]);
    });
  });

  group('otot', () {
    MuscleGroup muscleOf(String id) => switch (id) {
      'bench' => MuscleGroup.dada,
      'squat' => MuscleGroup.kaki,
      'row' => MuscleGroup.punggung,
      _ => MuscleGroup.lainnya,
    };
    final now = DateTime(2026, 11, 8, 12);
    final sets = [
      _s('bench', 60, 8, at: DateTime(2026, 11, 6)),
      _s('bench', 60, 8, at: DateTime(2026, 10, 1)),
      _s('squat', 80, 5, at: DateTime(2026, 10, 28)),
      _s('row', 50, 10, at: DateTime(2026, 10, 10)),
      _s('misc', 5, 5, at: DateTime(2026, 11, 7)),
    ];

    test('lastTrained memakai sesi terbaru, lainnya diabaikan', () {
      final last = lastTrained(sets, muscleOf);
      expect(last[MuscleGroup.dada], DateTime(2026, 11, 6));
      expect(last[MuscleGroup.kaki], DateTime(2026, 10, 28));
      expect(last[MuscleGroup.bahu], isNull);
      expect(last.containsKey(MuscleGroup.lainnya), isFalse);
    });

    test('neglectedMuscles 7 dan 14 hari', () {
      final n7 = neglectedMuscles(sets, muscleOf, now);
      expect(n7, isNot(contains(MuscleGroup.dada)));
      expect(n7, containsAll([MuscleGroup.kaki, MuscleGroup.punggung]));
      expect(n7, containsAll([MuscleGroup.bahu, MuscleGroup.lengan, MuscleGroup.core]));
      final n14 = neglectedMuscles(sets, muscleOf, now, days: 14);
      expect(n14, isNot(contains(MuscleGroup.kaki)));
      expect(n14, contains(MuscleGroup.punggung));
    });
  });

  group('session_draft', () {
    test('fmtKg & parseKg', () {
      expect(fmtKg(60), '60');
      expect(fmtKg(62.5), '62,5');
      expect(fmtKg(1.25), '1,25');
      expect(parseKg('62,5'), 62.5);
      expect(parseKg(' 80 '), 80);
      expect(parseKg(''), isNull);
      expect(parseKg('abc'), isNull);
      expect(parseKg('-5'), isNull);
    });

    test('gymSessionTitle', () {
      expect(gymSessionTitle(DateTime(2026, 1, 1, 7)), 'Gym · Pagi');
      expect(gymSessionTitle(DateTime(2026, 1, 1, 13)), 'Gym · Siang');
      expect(gymSessionTitle(DateTime(2026, 1, 1, 16)), 'Gym · Sore');
      expect(gymSessionTitle(DateTime(2026, 1, 1, 20)), 'Gym · Malam');
      expect(
        gymSessionTitle(DateTime(2026, 1, 1, 20), templateName: ' Push day '),
        'Gym · Push day',
      );
    });

    test('DraftSummary hanya menghitung set kerja yang dicentang', () {
      const ex = ExerciseInfo(id: 'a', name: 'A', muscle: MuscleGroup.dada);
      final done = DateTime(2026, 1, 1);
      final list = [
        DraftExercise(
          exercise: ex,
          sets: [
            DraftSet(id: '1', weightKg: 20, reps: 10, isWarmup: true, completedAt: done),
            DraftSet(id: '2', weightKg: 60, reps: 8, completedAt: done),
            const DraftSet(id: '3', weightKg: 60, reps: 8),
          ],
        ),
        DraftExercise(
          exercise: ex,
          sets: [DraftSet(id: '4', weightKg: 10, reps: 10, completedAt: done)],
        ),
      ];
      final s = DraftSummary.of(list);
      expect(s.volumeKg, 580);
      expect(s.doneSets, 3);
      expect(s.totalSets, 4);
      expect(s.doneExercises, 1);
      expect(s.totalExercises, 2);
    });
  });
}
