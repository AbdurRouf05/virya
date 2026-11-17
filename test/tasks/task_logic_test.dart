import 'package:flutter_test/flutter_test.dart';
import 'package:virya/features/tasks/domain/task_logic.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

final _today = DateTime(2026, 11, 8);

TaskItem _task(
  String id, {
  DateTime? due,
  bool important = false,
  bool pinned = false,
  DateTime? createdAt,
}) => TaskItem(
  id: id,
  title: 'Tugas $id',
  due: due,
  important: important,
  pinned: pinned,
  createdAt: createdAt ?? DateTime.utc(2026, 11, 1),
);

List<String> _ids(Iterable<TaskItem> l) => [for (final t in l) t.id];

void main() {
  group('normalizeTaskTitle', () {
    test('memangkas dan memadatkan spasi serta baris baru', () {
      expect(normalizeTaskTitle('  beli \n\n  susu\t kedelai '), 'beli susu kedelai');
    });

    test('kosong atau hanya spasi menjadi null', () {
      expect(normalizeTaskTitle(''), isNull);
      expect(normalizeTaskTitle(' \n\t '), isNull);
    });

    test('dibatasi panjang maksimum', () {
      final long = 'a' * (maxTaskTitleLength + 50);
      expect(normalizeTaskTitle(long)!.length, maxTaskTitleLength);
      final exact = 'b' * maxTaskTitleLength;
      expect(normalizeTaskTitle(exact), exact);
    });
  });

  group('taskDayKey & parseTaskDay', () {
    test('format dengan nol di depan dan bolak-balik', () {
      expect(taskDayKey(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
      expect(parseTaskDay('2026-03-07'), DateTime(2026, 3, 7));
    });

    test('null dan format tidak valid menjadi null', () {
      expect(parseTaskDay(null), isNull);
      expect(parseTaskDay(''), isNull);
      expect(parseTaskDay('besok'), isNull);
      expect(parseTaskDay('2026-3-7'), isNull);
      expect(parseTaskDay('2026-03-07T10:00'), isNull);
    });
  });

  group('compareTasks', () {
    test('urutan: pin, penting, tanggal, tanpa tanggal, terlama dibuat', () {
      final tomorrow = DateTime(2026, 11, 9);
      final list = [
        _task('undated', createdAt: DateTime.utc(2026, 1, 1)),
        _task('later', due: tomorrow),
        _task('newer', due: _today, createdAt: DateTime.utc(2026, 11, 5)),
        _task('older', due: _today, createdAt: DateTime.utc(2026, 11, 2)),
        _task('important', important: true),
        _task('pinned', pinned: true),
      ]..sort(compareTasks);
      expect(_ids(list), [
        'pinned',
        'important',
        'older',
        'newer',
        'later',
        'undated',
      ]);
    });
  });

  group('bucketTasks', () {
    test('memisahkan terlambat, hari ini, besok, tanpa tanggal, dan pin', () {
      final b = bucketTasks([
        _task('overdue', due: DateTime(2026, 11, 7)),
        _task('today', due: _today),
        _task('tomorrow', due: DateTime(2026, 11, 9)),
        _task('undated'),
        _task('pinnedFuture', due: DateTime(2026, 12, 1), pinned: true),
      ], _today);
      expect(_ids(b.today), ['pinnedFuture', 'overdue', 'today']);
      expect(_ids(b.later), ['tomorrow', 'undated']);
    });

    test('isTaskOverdue hanya untuk tugas terbuka sebelum hari ini', () {
      final yesterday = DateTime(2026, 11, 7);
      expect(isTaskOverdue(_task('a', due: yesterday), _today), isTrue);
      expect(isTaskOverdue(_task('b', due: _today), _today), isFalse);
      expect(isTaskOverdue(_task('c'), _today), isFalse);
      final done = TaskItem(
        id: 'd',
        title: 'd',
        due: yesterday,
        doneAt: DateTime.utc(2026, 11, 8),
        createdAt: DateTime.utc(2026, 11, 1),
      );
      expect(isTaskOverdue(done, _today), isFalse);
    });
  });

  group('taskWidgetSnapshot', () {
    test('tanpa tugas tak bertanggal kecuali di-pin, terurut, berisi tanggal', () {
      final snap = taskWidgetSnapshot([
        _task('undated'),
        _task('future', due: DateTime(2026, 12, 1)),
        _task('pinned', pinned: true),
        _task('imp', due: _today, important: true),
      ]);
      expect([for (final m in snap) m['id']], ['pinned', 'imp', 'future']);
      expect(snap[0]['day'], isNull);
      expect(snap[0]['pinned'], isTrue);
      expect(snap[1]['day'], '2026-11-08');
      expect(snap[1]['important'], isTrue);
      expect(snap[2]['day'], '2026-12-01');
      expect(snap[2]['title'], 'Tugas future');
    });

    test('dibatasi 100 entri', () {
      final many = [for (var i = 0; i < 150; i++) _task('$i', due: _today)];
      expect(taskWidgetSnapshot(many).length, 100);
    });
  });
}
