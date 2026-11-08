import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/daos/focus_dao.dart';

const today = '2026-11-08';
const past = '2026-11-05';

AppLimitsCompanion limit(
  String pkg, {
  String? label,
  int minutes = 30,
  DateTime? createdAt,
}) => AppLimitsCompanion.insert(
  packageName: pkg,
  label: label ?? pkg,
  dailyMinutes: minutes,
  createdAt: createdAt ?? DateTime.utc(2026, 11, 1),
);

AppUsageDaysCompanion usage(
  String day,
  String pkg,
  int minutes, {
  String? label,
  int limitMinutes = 30,
}) => AppUsageDaysCompanion.insert(
  day: day,
  packageName: pkg,
  label: label ?? pkg,
  minutes: minutes,
  limitMinutes: limitMinutes,
);

void main() {
  late AppDatabase db;
  late FocusDao dao;

  setUp(() {
    db = AppDatabase.memory();
    dao = db.focusDao;
  });

  tearDown(() => db.close());

  group('batas aplikasi', () {
    test('batas baru aktif secara bawaan', () async {
      await dao.upsertLimit(limit('a'));
      expect((await dao.getLimits()).single.enabled, isTrue);
    });

    test('upsert mempertahankan createdAt, mengubah nama dan menit', () async {
      final first = DateTime.utc(2026, 11, 1);
      await dao.upsertLimit(
        limit('a', label: 'Lama', minutes: 30, createdAt: first),
      );
      await dao.upsertLimit(
        limit(
          'a',
          label: 'Baru',
          minutes: 45,
          createdAt: DateTime.utc(2026, 11, 7),
        ),
      );
      final row = (await dao.getLimits()).single;
      expect(row.label, 'Baru');
      expect(row.dailyMinutes, 45);
      expect(row.createdAt.isAtSameMomentAs(first), isTrue);
    });

    test('upsert mengaktifkan lagi batas yang nonaktif', () async {
      await dao.upsertLimit(limit('a'));
      await dao.setEnabled('a', false);
      await dao.upsertLimit(limit('a', minutes: 60));
      expect((await dao.getLimits()).single.enabled, isTrue);
    });

    test('setEnabled hanya menyentuh aplikasi yang dimaksud', () async {
      await dao.upsertLimit(limit('a'));
      await dao.upsertLimit(limit('b'));
      await dao.setEnabled('a', false);
      final rows = {for (final r in await dao.getLimits()) r.packageName: r};
      expect(rows['a']!.enabled, isFalse);
      expect(rows['b']!.enabled, isTrue);
    });

    test('menghapus batas tidak menghapus riwayat', () async {
      await dao.upsertLimit(limit('a'));
      await dao.upsertUsage([usage(past, 'a', 20)], today);
      await dao.deleteLimit('a');
      expect(await dao.getLimits(), isEmpty);
      expect((await dao.watchUsageOn(past).first).single.minutes, 20);
    });

    test('watchLimits urut menurut nama', () async {
      await dao.upsertLimit(limit('1', label: 'YouTube'));
      await dao.upsertLimit(limit('2', label: 'Instagram'));
      await dao.upsertLimit(limit('3', label: 'TikTok'));
      final rows = await dao.watchLimits().first;
      expect(rows.map((r) => r.label), ['Instagram', 'TikTok', 'YouTube']);
    });
  });

  group('upsertUsage', () {
    test('baris hari ini ditimpa penuh, termasuk bila turun', () async {
      await dao.upsertUsage([
        usage(today, 'a', 40, label: 'Lama', limitMinutes: 30),
      ], today);
      await dao.upsertUsage([
        usage(today, 'a', 15, label: 'Baru', limitMinutes: 60),
      ], today);
      final row = (await dao.watchUsageOn(today).first).single;
      expect(row.minutes, 15);
      expect(row.label, 'Baru');
      expect(row.limitMinutes, 60);
    });

    test('hari lampau bisa naik', () async {
      await dao.upsertUsage([usage(past, 'a', 20)], today);
      await dao.upsertUsage([usage(past, 'a', 25)], today);
      expect((await dao.watchUsageOn(past).first).single.minutes, 25);
    });

    test('hari lampau tidak turun', () async {
      await dao.upsertUsage([usage(past, 'a', 20)], today);
      await dao.upsertUsage([usage(past, 'a', 5)], today);
      expect((await dao.watchUsageOn(past).first).single.minutes, 20);
    });

    test('hari lampau mempertahankan nama dan batas saat menit naik', () async {
      await dao.upsertUsage([
        usage(past, 'a', 20, label: 'Lama', limitMinutes: 30),
      ], today);
      await dao.upsertUsage([
        usage(past, 'a', 50, label: 'Baru', limitMinutes: 90),
      ], today);
      final row = (await dao.watchUsageOn(past).first).single;
      expect(row.minutes, 50);
      expect(row.label, 'Lama');
      expect(row.limitMinutes, 30);
    });

    test('watchUsageOn hanya hari yang diminta', () async {
      await dao.upsertUsage([
        usage(today, 'a', 1),
        usage(past, 'a', 2),
        usage(today, 'b', 3),
      ], today);
      final rows = await dao.watchUsageOn(today).first;
      expect(rows.map((r) => r.packageName).toSet(), {'a', 'b'});
    });
  });
}
