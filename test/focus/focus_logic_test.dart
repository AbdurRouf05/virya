import 'package:flutter_test/flutter_test.dart';
import 'package:virya/features/focus/domain/focus_logic.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

FocusLimit limit(
  String pkg, {
  String? label,
  int minutes = 30,
  bool enabled = true,
  DateTime? createdAt,
}) => FocusLimit(
  packageName: pkg,
  label: label ?? pkg,
  dailyMinutes: minutes,
  enabled: enabled,
  createdAt: createdAt ?? DateTime(2026, 11, 1, 9),
);

FocusDayEntry entry(String pkg, int minutes) => FocusDayEntry(
  day: '2026-11-08',
  packageName: pkg,
  label: pkg,
  minutes: minutes,
  limitMinutes: 30,
);

FocusUsageRow row(String day, String pkg, int minutes) =>
    FocusUsageRow(day: day, packageName: pkg, minutes: minutes);

void main() {
  group('normalizeFocusMinutes', () {
    test('menjepit ke batas bawah dan atas', () {
      expect(normalizeFocusMinutes(0), minFocusMinutes);
      expect(normalizeFocusMinutes(-10), minFocusMinutes);
      expect(normalizeFocusMinutes(99999), maxFocusMinutes);
    });

    test('nilai di dalam rentang tidak berubah', () {
      expect(normalizeFocusMinutes(minFocusMinutes), minFocusMinutes);
      expect(normalizeFocusMinutes(45), 45);
      expect(normalizeFocusMinutes(maxFocusMinutes), maxFocusMinutes);
    });
  });

  group('formatFocusMinutes', () {
    test('di bawah satu jam', () {
      expect(formatFocusMinutes(0), '0 mnt');
      expect(formatFocusMinutes(45), '45 mnt');
      expect(formatFocusMinutes(59), '59 mnt');
    });

    test('jam bulat dan jam dengan menit', () {
      expect(formatFocusMinutes(60), '1 j');
      expect(formatFocusMinutes(120), '2 j');
      expect(formatFocusMinutes(90), '1 j 30 mnt');
    });
  });

  group('focusStatuses', () {
    test('batas nonaktif tidak ikut', () {
      final out = focusStatuses(
        limits: [limit('a'), limit('b', enabled: false)],
        today: const [],
        bonus: const {},
      );
      expect(out.map((s) => s.limit.packageName), ['a']);
    });

    test('tanpa catatan pemakaian dihitung 0', () {
      final s = focusStatuses(
        limits: [limit('a')],
        today: const [],
        bonus: const {},
      ).single;
      expect(s.usedMinutes, 0);
      expect(s.remainingMinutes, 30);
      expect(s.fraction, 0);
      expect(s.isOver, isFalse);
    });

    test('menit tambahan menaikkan kuota', () {
      final s = focusStatuses(
        limits: [limit('a')],
        today: [entry('a', 30)],
        bonus: const {'a': 5},
      ).single;
      expect(s.bonusMinutes, 5);
      expect(s.allowedMinutes, 35);
      expect(s.remainingMinutes, 5);
      expect(s.isOver, isFalse);
    });

    test('tepat di kuota dianggap habis', () {
      final s = focusStatuses(
        limits: [limit('a')],
        today: [entry('a', 30)],
        bonus: const {},
      ).single;
      expect(s.remainingMinutes, 0);
      expect(s.isOver, isTrue);
      expect(s.fraction, 1);
    });

    test('melewati kuota: sisa tidak negatif, fraksi dijepit', () {
      final s = focusStatuses(
        limits: [limit('a')],
        today: [entry('a', 95)],
        bonus: const {},
      ).single;
      expect(s.remainingMinutes, 0);
      expect(s.isOver, isTrue);
      expect(s.fraction, 1);
    });

    test('urut dari sisa paling sedikit, lalu nama', () {
      final out = focusStatuses(
        limits: [
          limit('longgar', label: 'Longgar', minutes: 60),
          limit('z', label: 'Zeta'),
          limit('a', label: 'Alfa'),
          limit('sempit', label: 'Sempit'),
        ],
        today: [entry('sempit', 25), entry('z', 10), entry('a', 10)],
        bonus: const {},
      );
      expect(out.map((s) => s.limit.label), [
        'Sempit',
        'Alfa',
        'Zeta',
        'Longgar',
      ]);
    });
  });

  group('focusRowsToSave', () {
    test('aplikasi tanpa batas dibuang', () {
      final out = focusRowsToSave(
        [row('2026-11-08', 'a', 10), row('2026-11-08', 'x', 99)],
        [limit('a')],
      );
      expect(out.map((e) => e.packageName), ['a']);
    });

    test('hari sebelum batas dibuat dibuang, hari yang sama disimpan', () {
      final out = focusRowsToSave(
        [
          row('2026-11-04', 'a', 50),
          row('2026-11-05', 'a', 20),
          row('2026-11-06', 'a', 30),
        ],
        [limit('a', createdAt: DateTime(2026, 11, 5, 23, 30))],
      );
      expect(out.map((e) => e.day), ['2026-11-05', '2026-11-06']);
    });

    test('hari batas dibuat dihitung dalam waktu lokal, bukan UTC', () {
      final createdAt = DateTime(2026, 11, 5, 0, 30).toUtc();
      final out = focusRowsToSave(
        [row('2026-11-05', 'a', 20)],
        [limit('a', createdAt: createdAt)],
      );
      expect(out.map((e) => e.day), ['2026-11-05']);
    });

    test('memakai nama dan batas saat ini', () {
      final e = focusRowsToSave(
        [row('2026-11-08', 'com.tiktok', 12)],
        [limit('com.tiktok', label: 'TikTok', minutes: 45)],
      ).single;
      expect(e.label, 'TikTok');
      expect(e.limitMinutes, 45);
      expect(e.minutes, 12);
      expect(e.isOver, isFalse);
    });
  });
}
