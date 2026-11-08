import 'package:flutter_test/flutter_test.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

void main() {
  group('FocusUsageRead.fromJson', () {
    test('membaca baris dan menit tambahan', () {
      final read = FocusUsageRead.fromJson({
        'rows': [
          {'day': '2026-11-08', 'packageName': 'a', 'minutes': 12},
          {'day': '2026-11-07', 'packageName': 'b', 'minutes': 3},
        ],
        'bonus': {'a': 5},
      });
      expect(read.rows.length, 2);
      expect(read.rows.first.day, '2026-11-08');
      expect(read.rows.first.packageName, 'a');
      expect(read.rows.first.minutes, 12);
      expect(read.bonus, {'a': 5});
    });

    test('angka desimal dari JSON menjadi int', () {
      final read = FocusUsageRead.fromJson({
        'rows': [
          {'day': '2026-11-08', 'packageName': 'a', 'minutes': 12.0},
        ],
        'bonus': {'a': 5.0},
      });
      expect(read.rows.single.minutes, isA<int>());
      expect(read.rows.single.minutes, 12);
      expect(read.bonus['a'], isA<int>());
      expect(read.bonus['a'], 5);
    });

    test('kosong', () {
      final read = FocusUsageRead.fromJson({
        'rows': <dynamic>[],
        'bonus': <String, dynamic>{},
      });
      expect(read.rows, isEmpty);
      expect(read.bonus, isEmpty);
    });
  });

  test('FocusInstalledApp.fromJson', () {
    final app = FocusInstalledApp.fromJson({
      'packageName': 'com.tiktok',
      'label': 'TikTok',
    });
    expect(app.packageName, 'com.tiktok');
    expect(app.label, 'TikTok');
  });

  test('FocusLimit.toNative hanya mengirim kolom yang dipakai Android', () {
    final native = FocusLimit(
      packageName: 'com.tiktok',
      label: 'TikTok',
      dailyMinutes: 30,
      enabled: false,
      createdAt: DateTime.utc(2026, 11, 1),
    ).toNative();
    expect(native, {
      'packageName': 'com.tiktok',
      'label': 'TikTok',
      'dailyMinutes': 30,
      'enabled': false,
    });
  });

  test('FocusPermissions.ready butuh kedua izin', () {
    expect(FocusPermissions.none.ready, isFalse);
    expect(
      const FocusPermissions(usageAccess: true, accessibility: false).ready,
      isFalse,
    );
    expect(
      const FocusPermissions(usageAccess: true, accessibility: true).ready,
      isTrue,
    );
  });

  test('FocusDayEntry.isOver mulai tepat di batas', () {
    FocusDayEntry e(int m) => FocusDayEntry(
      day: '2026-11-08',
      packageName: 'a',
      label: 'A',
      minutes: m,
      limitMinutes: 30,
    );
    expect(e(29).isOver, isFalse);
    expect(e(30).isOver, isTrue);
  });
}
