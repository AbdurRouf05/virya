import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/tasks/data/task_repository.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = TaskRepository(db.tasksDao);
  });

  tearDown(() => db.close());

  Future<List<TaskItem>> open() async =>
      (await db.tasksDao.watchOpen().first).map(taskItemOf).toList();

  Future<List<TaskItem>> done() async =>
      (await db.tasksDao.watchDone().first).map(taskItemOf).toList();

  group('TaskRepository', () {
    test('add menolak judul kosong', () async {
      expect(await repo.add('   \n '), isNull);
      expect(await open(), isEmpty);
    });

    test('add merapikan judul dan menyimpan pilihan', () async {
      final id = await repo.add(
        '  beli   susu ',
        due: DateTime(2026, 11, 8),
        important: true,
        pinned: true,
      );
      final t = (await open()).single;
      expect(t.id, id);
      expect(t.title, 'beli susu');
      expect(t.due, DateTime(2026, 11, 8));
      expect(t.important, isTrue);
      expect(t.pinned, isTrue);
      expect(t.isDone, isFalse);
    });

    test('add tanpa tanggal menjadi tugas Nanti', () async {
      await repo.add('kapan-kapan');
      expect((await open()).single.due, isNull);
    });

    test('save mengubah kolom; judul kosong mempertahankan yang lama', () async {
      await repo.add('lama', due: DateTime(2026, 11, 8));
      final t = (await open()).single;

      await repo.save(
        TaskItem(
          id: t.id,
          title: '   ',
          note: '  catatan  ',
          important: true,
          pinned: true,
          createdAt: t.createdAt,
        ),
      );
      var s = (await open()).single;
      expect(s.title, 'lama');
      expect(s.note, 'catatan');
      expect(s.due, isNull);
      expect(s.important, isTrue);
      expect(s.pinned, isTrue);

      await repo.save(
        TaskItem(id: t.id, title: 'baru', note: '  ', createdAt: t.createdAt),
      );
      s = (await open()).single;
      expect(s.title, 'baru');
      expect(s.note, isNull);
      expect(s.important, isFalse);
    });

    test('setDone memindahkan tugas dan bisa dibatalkan', () async {
      final id = (await repo.add('a'))!;
      await repo.setDone(id, true);
      expect(await open(), isEmpty);
      expect((await done()).single.isDone, isTrue);

      await repo.setDone(id, false);
      expect((await open()).single.id, id);
      expect(await done(), isEmpty);
    });

    test('delete menghapus tugas', () async {
      final id = (await repo.add('a'))!;
      await repo.delete(id);
      expect(await open(), isEmpty);
      expect(await done(), isEmpty);
    });
  });

  group('applyOp', () {
    final at = DateTime.utc(2026, 11, 8, 7);

    test('capture dua kali tidak membuat tugas ganda', () async {
      final op = TaskCaptureOp(
        'c1',
        at,
        title: '  dari   notifikasi ',
        dueDay: '2026-11-08',
      );
      await repo.applyOp(op);
      await repo.applyOp(op);
      final t = (await open()).single;
      expect(t.id, 'c1');
      expect(t.title, 'dari notifikasi');
      expect(t.due, DateTime(2026, 11, 8));
      expect(t.createdAt.isAtSameMomentAs(at), isTrue);
    });

    test('capture judul kosong diabaikan', () async {
      await repo.applyOp(TaskCaptureOp('c2', at, title: '   '));
      expect(await open(), isEmpty);
    });

    test('capture dengan hari rusak menjadi tanpa tanggal', () async {
      await repo.applyOp(TaskCaptureOp('c3', at, title: 'x', dueDay: 'besok'));
      expect((await open()).single.due, isNull);
    });

    test('capture ulang tidak menimpa tugas yang sudah diedit', () async {
      final op = TaskCaptureOp('c4', at, title: 'asli');
      await repo.applyOp(op);
      final t = (await open()).single;
      await repo.save(
        TaskItem(id: t.id, title: 'diedit', createdAt: t.createdAt),
      );
      await repo.applyOp(op);
      expect((await open()).single.title, 'diedit');
    });

    test('done mempertahankan waktu selesai pertama', () async {
      await repo.applyOp(TaskCaptureOp('c5', at, title: 'x'));
      final first = DateTime.utc(2026, 11, 8, 9);
      final second = DateTime.utc(2026, 11, 8, 12);
      await repo.applyOp(TaskDoneOp('d1', first, taskId: 'c5'));
      await repo.applyOp(TaskDoneOp('d2', second, taskId: 'c5'));
      expect((await done()).single.doneAt!.isAtSameMomentAs(first), isTrue);
    });

    test('done untuk tugas yang sudah dihapus tidak gagal', () async {
      await repo.applyOp(TaskDoneOp('d3', at, taskId: 'tidak-ada'));
      expect(await done(), isEmpty);
    });

    test('capture lalu done berurutan berakhir selesai', () async {
      await repo.applyOp(TaskCaptureOp('c6', at, title: 'x'));
      await repo.applyOp(TaskDoneOp('d4', at, taskId: 'c6'));
      expect(await open(), isEmpty);
      expect((await done()).single.id, 'c6');
    });
  });

  group('watchDoneBetween', () {
    test('batas awal inklusif, batas akhir eksklusif', () async {
      final from = DateTime.utc(2026, 11, 7, 17);
      final to = DateTime.utc(2026, 11, 8, 17);
      final cases = <String, DateTime>{
        'sebelum': from.subtract(const Duration(seconds: 1)),
        'awal': from,
        'tengah': DateTime.utc(2026, 11, 8, 3),
        'akhir': to,
        'sesudah': to.add(const Duration(seconds: 1)),
      };
      for (final e in cases.entries) {
        final id = (await repo.add(e.key))!;
        await db.tasksDao.setDoneAt(id, e.value);
      }
      await repo.add('terbuka');

      final rows = await db.tasksDao.watchDoneBetween(from, to).first;
      expect([for (final r in rows) r.title], ['awal', 'tengah']);
    });
  });

  test('watchDone terbaru dulu dan menghormati limit', () async {
    for (var i = 0; i < 3; i++) {
      final id = (await repo.add('t$i'))!;
      await db.tasksDao.setDoneAt(id, DateTime.utc(2026, 11, 1 + i));
    }
    final rows = await db.tasksDao.watchDone(limit: 2).first;
    expect([for (final r in rows) r.title], ['t2', 't1']);
  });
}
