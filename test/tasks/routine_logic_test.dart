import 'package:flutter_test/flutter_test.dart';
import 'package:virya/features/tasks/domain/task_logic.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

final _today = DateTime(2026, 11, 16);

TaskItem _t(
  String id, {
  bool routine = false,
  int? remind,
  DateTime? doneAt,
  bool pinned = false,
  DateTime? due,
}) => TaskItem(
  id: id,
  title: 'T $id',
  repeatDaily: routine,
  remindMinute: remind,
  doneAt: doneAt,
  pinned: pinned,
  due: due,
  createdAt: DateTime.utc(2026, 11, 1),
);

void main() {
  group('isRoutineDoneOn', () {
    test('hanya bila dicentang pada hari lokal yang sama', () {
      final today = _t('a', routine: true, doneAt: DateTime(2026, 11, 16, 7));
      final yesterday = _t(
        'b',
        routine: true,
        doneAt: DateTime(2026, 11, 15, 23, 59),
      );
      expect(isRoutineDoneOn(today, _today), isTrue);
      expect(isRoutineDoneOn(yesterday, _today), isFalse);
      expect(isRoutineDoneOn(_t('c', routine: true), _today), isFalse);
    });

    test('waktu UTC dibandingkan sebagai waktu lokal', () {
      final local = DateTime(2026, 11, 16, 0, 30);
      final t = _t('a', routine: true, doneAt: local.toUtc());
      expect(isRoutineDoneOn(t, _today), isTrue);
    });
  });

  group('openTasksOn', () {
    test('rutinitas kemarin terbuka lagi tanpa doneAt, hari ini disembunyikan',
        () {
      final rows = [
        _t('task'),
        _t('doneTask', doneAt: DateTime(2026, 11, 16, 8)),
        _t('rYesterday', routine: true, doneAt: DateTime(2026, 11, 15, 9)),
        _t('rToday', routine: true, doneAt: DateTime(2026, 11, 16, 9)),
        _t('rNever', routine: true),
      ];
      final open = openTasksOn(rows, _today);
      expect([for (final t in open) t.id], ['task', 'rYesterday', 'rNever']);
      expect(open.every((t) => !t.isDone), isTrue);
      expect(open[1].repeatDaily, isTrue);
    });
  });

  test('rutinitas selalu di Hari Ini, setelah pin, urut jam pengingat', () {
    final b = bucketTasks([
      _t('later', due: DateTime(2026, 11, 20)),
      _t('r9', routine: true, remind: 9 * 60),
      _t('rNone', routine: true),
      _t('r7', routine: true, remind: 7 * 60),
      _t('pin', pinned: true),
    ], _today);
    expect([for (final t in b.today) t.id], ['pin', 'r7', 'r9', 'rNone']);
    expect([for (final t in b.later) t.id], ['later']);
  });

  test('taskWidgetSnapshot tidak memuat rutinitas', () {
    final snap = taskWidgetSnapshot([
      _t('r', routine: true),
      _t('p', pinned: true),
    ]);
    expect([for (final m in snap) m['id']], ['p']);
  });

  test('routineSnapshot memuat jam dan hari terakhir dicentang', () {
    final snap = routineSnapshot([
      _t('task'),
      _t('r2', routine: true, doneAt: DateTime(2026, 11, 15, 21).toUtc()),
      _t('r1', routine: true, remind: 450),
    ]);
    expect(snap, [
      {'id': 'r1', 'title': 'T r1', 'remind': 450, 'doneDay': null},
      {'id': 'r2', 'title': 'T r2', 'remind': null, 'doneDay': '2026-11-15'},
    ]);
  });

  test('formatRemindMinute', () {
    expect(formatRemindMinute(0), '00:00');
    expect(formatRemindMinute(7 * 60 + 5), '07:05');
    expect(formatRemindMinute(22 * 60), '22:00');
  });
}
