import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/focus/data/focus_bridge.dart';
import 'package:virya/features/focus/data/focus_repository.dart';
import 'package:virya/features/focus/domain/focus_logic.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

class FakeBridge extends FocusBridge {
  final pushes = <List<FocusLimit>>[];
  final readDays = <int>[];
  FocusUsageRead next = FocusUsageRead.empty;

  @override
  Future<void> pushLimits(List<FocusLimit> limits) async {
    pushes.add(limits);
  }

  @override
  Future<FocusUsageRead> readUsage(int days) async {
    readDays.add(days);
    return next;
  }
}

FocusUsageRow row(String day, String pkg, int minutes) =>
    FocusUsageRow(day: day, packageName: pkg, minutes: minutes);

void main() {
  late AppDatabase db;
  late FakeBridge bridge;
  late FocusRepository repo;
  final now = DateTime(2026, 11, 8, 10);

  setUp(() {
    db = AppDatabase.memory();
    bridge = FakeBridge();
    repo = FocusRepository(db.focusDao, bridge, clock: () => now);
  });

  tearDown(() => db.close());

  Future<void> save(String pkg, {int minutes = 30}) => repo.saveLimit(
    packageName: pkg,
    label: 'Nama $pkg',
    dailyMinutes: minutes,
  );

  group('saveLimit', () {
    test('menit dijepit ke rentang yang sah', () async {
      await save('kecil', minutes: 1);
      await save('besar', minutes: 99999);
      final rows = {
        for (final r in await db.focusDao.getLimits())
          r.packageName: r.dailyMinutes,
      };
      expect(rows['kecil'], minFocusMinutes);
      expect(rows['besar'], maxFocusMinutes);
    });

    test('createdAt memakai jam saat ini', () async {
      await save('a');
      final row = (await db.focusDao.getLimits()).single;
      expect(row.createdAt.isAtSameMomentAs(now), isTrue);
    });
  });

  group('sync', () {
    test('tanpa batas: kirim daftar kosong, tidak membaca pemakaian', () async {
      bridge.next = FocusUsageRead(
        rows: [row('2026-11-08', 'a', 10)],
        bonus: const {'a': 5},
      );
      final bonus = await repo.sync();
      expect(bridge.pushes.single, isEmpty);
      expect(bridge.readDays, isEmpty);
      expect(bonus, isEmpty);
    });

    test('menyimpan pemakaian dan mengembalikan menit tambahan', () async {
      await save('a', minutes: 45);
      bridge.next = FocusUsageRead(
        rows: [row('2026-11-08', 'a', 12)],
        bonus: const {'a': 5},
      );
      final bonus = await repo.sync();

      expect(bonus, {'a': 5});
      expect(bridge.pushes.single.single.packageName, 'a');
      expect(bridge.readDays, [focusHistoryDays]);
      final stored = (await db.focusDao.watchUsageOn('2026-11-08').first).single;
      expect(stored.minutes, 12);
      expect(stored.label, 'Nama a');
      expect(stored.limitMinutes, 45);
    });

    test('hari sebelum batas dibuat tidak disimpan', () async {
      await save('a');
      bridge.next = FocusUsageRead(
        rows: [row('2026-11-07', 'a', 99), row('2026-11-08', 'a', 3)],
        bonus: const {},
      );
      await repo.sync();
      expect(await db.focusDao.watchUsageOn('2026-11-07').first, isEmpty);
      expect(await db.focusDao.watchUsageOn('2026-11-08').first, hasLength(1));
    });

    test('batas nonaktif tetap punya riwayat', () async {
      await save('a');
      await repo.setEnabled('a', false);
      bridge.next = FocusUsageRead(
        rows: [row('2026-11-08', 'a', 7)],
        bonus: const {},
      );
      await repo.sync();
      expect(
        (await db.focusDao.watchUsageOn('2026-11-08').first).single.minutes,
        7,
      );
    });

    test('sinkron kedua pada hari yang sama memakai angka terbaru', () async {
      await save('a');
      bridge.next = FocusUsageRead(
        rows: [row('2026-11-08', 'a', 7)],
        bonus: const {},
      );
      await repo.sync();
      bridge.next = FocusUsageRead(
        rows: [row('2026-11-08', 'a', 11)],
        bonus: const {},
      );
      await repo.sync();
      expect(
        (await db.focusDao.watchUsageOn('2026-11-08').first).single.minutes,
        11,
      );
    });
  });

  test('removeLimit menghapus batas', () async {
    await save('a');
    await repo.removeLimit('a');
    expect(await db.focusDao.getLimits(), isEmpty);
  });
}
