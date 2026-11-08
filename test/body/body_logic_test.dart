import 'package:flutter_test/flutter_test.dart';
import 'package:virya/features/body/domain/body_logic.dart';
import 'package:virya/features/body/domain/body_models.dart';

BodyEntry _entry(
  DateTime day, {
  double? weight,
  Set<BodyPose> poses = const {},
}) => BodyEntry(
  id: 'c${day.toIso8601String()}',
  day: day,
  values: {BodyField.weightKg: ?weight},
  note: null,
  shots: {
    for (final p in poses)
      p: BodyShot(
        id: '${day.toIso8601String()}-${p.name}',
        pose: p,
        path: '/x/${day.month}-${day.day}-${p.name}.jpg',
      ),
  },
);

void main() {
  group('isBodyCheckinDue', () {
    final last = DateTime(2026, 11, 1);

    test('belum pernah check-in tidak diingatkan', () {
      expect(isBodyCheckinDue(const [], DateTime(2026, 11, 8)), isFalse);
    });

    test('hari ke-6 belum, hari ke-7 sudah', () {
      expect(isBodyCheckinDue([_entry(last)], DateTime(2026, 11, 7)), isFalse);
      expect(isBodyCheckinDue([_entry(last)], DateTime(2026, 11, 8)), isTrue);
    });

    test('memakai check-in terakhir tanpa peduli urutan', () {
      final today = DateTime(2026, 11, 8);
      final old = _entry(DateTime(2026, 10, 1));
      final recent = _entry(DateTime(2026, 11, 6));
      expect(isBodyCheckinDue([old, recent], today), isFalse);
      expect(isBodyCheckinDue([recent, old], today), isFalse);
    });

    test('melewati batas bulan dan tahun', () {
      expect(
        isBodyCheckinDue([_entry(DateTime(2026, 2, 25))], DateTime(2026, 3, 3)),
        isFalse,
      );
      expect(
        isBodyCheckinDue([_entry(DateTime(2026, 2, 25))], DateTime(2026, 3, 4)),
        isTrue,
      );
      expect(
        isBodyCheckinDue([
          _entry(DateTime(2026, 12, 28)),
        ], DateTime(2027, 1, 4)),
        isTrue,
      );
    });

    test('jam di dalam hari tidak memengaruhi selisih', () {
      expect(
        bodyDaysBetween(
          DateTime(2026, 3, 28, 23, 59),
          DateTime(2026, 3, 29, 0, 1),
        ),
        1,
      );
      // Rentang yang di banyak zona memuat pergantian jam musim panas.
      expect(bodyDaysBetween(DateTime(2026, 3, 25), DateTime(2026, 4, 1)), 7);
      expect(bodyDaysBetween(DateTime(2026, 10, 28), DateTime(2026, 11, 4)), 7);
    });
  });

  group('parseBodyValue', () {
    test('menerima koma, titik, dan spasi di tepi', () {
      expect(parseBodyValue(BodyField.weightKg, '72,5'), 72.5);
      expect(parseBodyValue(BodyField.weightKg, '72.5'), 72.5);
      expect(parseBodyValue(BodyField.weightKg, '  70 '), 70);
    });

    test('kosong dan bukan angka jadi null', () {
      expect(parseBodyValue(BodyField.weightKg, ''), isNull);
      expect(parseBodyValue(BodyField.weightKg, '   '), isNull);
      expect(parseBodyValue(BodyField.weightKg, 'abc'), isNull);
      expect(parseBodyValue(BodyField.weightKg, '7,2,5'), isNull);
    });

    test('NaN dan tak hingga ditolak', () {
      expect(parseBodyValue(BodyField.weightKg, 'NaN'), isNull);
      expect(parseBodyValue(BodyField.weightKg, 'Infinity'), isNull);
    });

    for (final f in BodyField.values) {
      test('batas ${f.name} inklusif', () {
        expect(parseBodyValue(f, '${f.min}'), f.min);
        expect(parseBodyValue(f, '${f.max}'), f.max);
        expect(parseBodyValue(f, '${f.min - 0.1}'), isNull);
        expect(parseBodyValue(f, '${f.max + 0.1}'), isNull);
      });
    }
  });

  test('bodyWeightSeries urut terlama dulu dan melewati berat kosong', () {
    final series = bodyWeightSeries([
      _entry(DateTime(2026, 11, 8), weight: 70),
      _entry(DateTime(2026, 11, 1)),
      _entry(DateTime(2026, 10, 25), weight: 72),
    ]);
    expect(series.map((p) => p.kg), [72, 70]);
    expect(series.first.day, DateTime(2026, 10, 25));
    expect(series.last.day, DateTime(2026, 11, 8));
  });

  test('bodyEntriesWithPose menyaring pose dan urut terlama dulu', () {
    final a = _entry(DateTime(2026, 11, 8), poses: {BodyPose.front});
    final b = _entry(DateTime(2026, 11, 1), poses: {BodyPose.side});
    final c = _entry(
      DateTime(2026, 10, 25),
      poses: {BodyPose.front, BodyPose.side},
    );
    expect(bodyEntriesWithPose([a, b, c], BodyPose.front), [c, a]);
    expect(bodyEntriesWithPose([a, b, c], BodyPose.side), [c, b]);
    expect(bodyEntriesWithPose([a, b, c], BodyPose.back), isEmpty);
  });

  group('bodyPreviousShot', () {
    final oldest = _entry(DateTime(2026, 10, 18), poses: {BodyPose.front});
    final middle = _entry(DateTime(2026, 10, 25), poses: {BodyPose.front});
    final noFront = _entry(DateTime(2026, 11, 1), poses: {BodyPose.side});
    final today = _entry(DateTime(2026, 11, 8), poses: {BodyPose.front});
    final all = [today, noFront, oldest, middle];

    test('memilih foto pose itu yang paling dekat sebelumnya', () {
      final shot = bodyPreviousShot(all, BodyPose.front, DateTime(2026, 11, 8));
      expect(shot, same(middle.shots[BodyPose.front]));
    });

    test('foto di hari yang sama tidak dipakai', () {
      final shot = bodyPreviousShot(
        all,
        BodyPose.front,
        DateTime(2026, 10, 25),
      );
      expect(shot, same(oldest.shots[BodyPose.front]));
    });

    test('tidak ada foto sebelumnya → null', () {
      expect(
        bodyPreviousShot(all, BodyPose.front, DateTime(2026, 10, 18)),
        isNull,
      );
      expect(
        bodyPreviousShot(all, BodyPose.back, DateTime(2026, 11, 8)),
        isNull,
      );
      expect(
        bodyPreviousShot(const [], BodyPose.front, DateTime(2026, 11, 8)),
        isNull,
      );
    });
  });

  test('bodyPhotoRelPath memakai garis miring maju di bawah photos/body', () {
    final rel = bodyPhotoRelPath('c1', BodyPose.side, 'p1');
    expect(rel, 'photos/body/c1/side_p1.jpg');
    expect(rel, isNot(contains(r'\')));
  });

  test('BodyPose.parse mengenali nama enum saja', () {
    for (final p in BodyPose.values) {
      expect(BodyPose.parse(p.name), p);
    }
    expect(BodyPose.parse('DEPAN'), isNull);
    expect(BodyPose.parse(''), isNull);
  });

  group('bodyTimelapseFrames', () {
    test('tanpa foto kosong', () {
      expect(bodyTimelapseFrames(0), isEmpty);
      expect(bodyTimelapseFrames(-1), isEmpty);
    });

    test('satu foto hanya ditahan dua kali hold', () {
      final frames = bodyTimelapseFrames(1, hold: 5, fade: 3);
      expect(frames, hasLength(10));
      expect(
        frames.every((f) => f.from == 0 && f.to == 0 && f.blend == 0),
        isTrue,
      );
    });

    for (final n in [2, 3, 7]) {
      test('$n foto: jumlah frame sesuai rumus', () {
        expect(
          bodyTimelapseFrames(n, hold: 12, fade: 4),
          hasLength((n - 1) * (12 + 4) + 2 * 12),
        );
      });
    }

    test('nilai bawaan hold 12 dan fade 4', () {
      expect(bodyTimelapseFrames(2), hasLength(16 + 24));
    });

    test('blend di antara 0 dan 1, naik, dan hanya ke foto berikutnya', () {
      final frames = bodyTimelapseFrames(3, hold: 2, fade: 4);
      final fades = frames.where((f) => f.from != f.to).toList();
      expect(fades, hasLength(8));
      for (final f in fades) {
        expect(f.to, f.from + 1);
        expect(f.blend, greaterThan(0));
        expect(f.blend, lessThan(1));
      }
      for (var i = 1; i < 4; i++) {
        expect(fades[i].blend, greaterThan(fades[i - 1].blend));
      }
      expect(frames.where((f) => f.from == f.to).every((f) => f.blend == 0), isTrue);
    });

    test('frame terakhir adalah foto terakhir', () {
      final last = bodyTimelapseFrames(4).last;
      expect(last.from, 3);
      expect(last.to, 3);
      expect(last.blend, 0);
    });
  });
}
