import 'package:flutter_test/flutter_test.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

void main() {
  const ms = 1794000000000;
  final at = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  group('TaskInboxOp.parse', () {
    test('capture valid', () {
      final op = TaskInboxOp.parse({
        'id': 'c1',
        'type': 'capture',
        'title': 'Beli susu',
        'day': '2026-11-08',
        'at': ms,
      });
      expect(op, isA<TaskCaptureOp>());
      final c = op! as TaskCaptureOp;
      expect(c.id, 'c1');
      expect(c.at, at);
      expect(c.title, 'Beli susu');
      expect(c.dueDay, '2026-11-08');
    });

    test('capture tanpa hari tetap valid', () {
      final op = TaskInboxOp.parse({
        'id': 'c2',
        'type': 'capture',
        'title': 'Tanpa hari',
        'at': ms,
      });
      expect((op! as TaskCaptureOp).dueDay, isNull);
    });

    test('done valid', () {
      final op = TaskInboxOp.parse({
        'id': 'd1',
        'type': 'done',
        'taskId': 't1',
        'at': ms,
      });
      expect(op, isA<TaskDoneOp>());
      expect((op! as TaskDoneOp).taskId, 't1');
      expect(op.at, at);
    });

    test('entri rusak menjadi null', () {
      final broken = <Map<String, dynamic>>[
        {},
        {'type': 'capture', 'title': 'x', 'at': ms},
        {'id': 'a', 'type': 'capture', 'title': 'x'},
        {'id': 'a', 'type': 'capture', 'title': 'x', 'at': 'kemarin'},
        {'id': 1, 'type': 'capture', 'title': 'x', 'at': ms},
        {'id': 'a', 'type': 'capture', 'at': ms},
        {'id': 'a', 'type': 'capture', 'title': 5, 'at': ms},
        {'id': 'a', 'type': 'done', 'at': ms},
        {'id': 'a', 'type': 'done', 'taskId': 7, 'at': ms},
      ];
      for (final m in broken) {
        expect(TaskInboxOp.parse(m), isNull, reason: '$m');
      }
    });

    test('jenis tidak dikenal menjadi null', () {
      expect(
        TaskInboxOp.parse({'id': 'a', 'type': 'hapus', 'at': ms}),
        isNull,
      );
      expect(TaskInboxOp.parse({'id': 'a', 'at': ms}), isNull);
    });
  });
}
