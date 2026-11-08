import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/tasks/application/task_inbox_sync.dart';
import 'package:virya/features/tasks/data/task_bridge.dart';
import 'package:virya/features/tasks/data/task_repository.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

/// Antrean native tiruan: entri hilang hanya setelah dikonfirmasi.
class _FakeBridge implements TaskBridge {
  final inbox = <TaskInboxOp>[];
  final acks = <List<String>>[];
  int peeks = 0;

  /// Bila diisi, peek berikutnya menunggu sampai selesai.
  Completer<void>? gate;

  @override
  Future<List<TaskInboxOp>> peekInbox() async {
    peeks++;
    final g = gate;
    if (g != null) {
      gate = null;
      await g.future;
    }
    return List.of(inbox);
  }

  @override
  Future<void> ackInbox(List<String> ids) async {
    acks.add(ids);
    inbox.removeWhere((op) => ids.contains(op.id));
  }

  @override
  void listen(VoidCallback? onChanged) {}
  @override
  Future<void> pushSnapshot(List<Map<String, Object?>> tasks) async {}
  @override
  Future<String?> takeLaunchAction() async => null;
  @override
  Future<bool> isQuickCaptureOn() async => false;
  @override
  Future<void> setQuickCapture(bool on) async {}
  @override
  Future<bool> canPinWidget() async => false;
  @override
  Future<void> requestPinWidget() async {}
}

/// Gagal saat menerapkan op dengan id [failOn], satu kali.
class _FlakyRepository extends TaskRepository {
  final _FakeBridge bridge;
  String? failOn;
  int ackCountAtLastApply = 0;

  _FlakyRepository(super.dao, this.bridge);

  @override
  Future<void> applyOp(TaskInboxOp op) async {
    ackCountAtLastApply = bridge.acks.length;
    if (op.id == failOn) {
      failOn = null;
      throw StateError('gagal menulis');
    }
    await super.applyOp(op);
  }
}

void main() {
  final at = DateTime.utc(2026, 11, 8, 7);
  late AppDatabase db;
  late _FakeBridge bridge;
  late _FlakyRepository repo;
  late TaskInboxSync sync;

  setUp(() {
    db = AppDatabase.memory();
    bridge = _FakeBridge();
    repo = _FlakyRepository(db.tasksDao, bridge);
    sync = TaskInboxSync(repo, bridge);
  });

  tearDown(() => db.close());

  Future<List<String>> openTitles() async {
    final rows = await db.tasksDao.watchOpen().first;
    return [for (final r in rows) r.title]..sort();
  }

  TaskCaptureOp capture(String id) => TaskCaptureOp(id, at, title: 'Tugas $id');

  test('antrean kosong tidak memanggil ack', () async {
    await sync.drain();
    expect(bridge.peeks, 1);
    expect(bridge.acks, isEmpty);
  });

  test('ack dipanggil sekali setelah semua op diterapkan', () async {
    bridge.inbox.addAll([capture('a'), capture('b')]);
    await sync.drain();
    expect(repo.ackCountAtLastApply, 0);
    expect(bridge.acks, [
      ['a', 'b'],
    ]);
    expect(bridge.inbox, isEmpty);
    expect(await openTitles(), ['Tugas a', 'Tugas b']);
  });

  test('op capture dan done dari satu antrean diterapkan berurutan', () async {
    bridge.inbox.addAll([capture('a'), TaskDoneOp('d', at, taskId: 'a')]);
    await sync.drain();
    expect(await openTitles(), isEmpty);
    expect((await db.tasksDao.watchDone().first).single.id, 'a');
  });

  test('gagal menerapkan: tanpa ack, lalu diulang tanpa duplikat', () async {
    bridge.inbox.addAll([capture('a'), capture('b')]);
    repo.failOn = 'b';

    await expectLater(sync.drain(), throwsStateError);
    expect(bridge.acks, isEmpty);
    expect(bridge.inbox.length, 2);
    expect(await openTitles(), ['Tugas a']);

    await sync.drain();
    expect(bridge.acks, [
      ['a', 'b'],
    ]);
    expect(await openTitles(), ['Tugas a', 'Tugas b']);
  });

  test('drain bersamaan digabung menjadi satu putaran tambahan', () async {
    bridge.inbox.add(capture('a'));
    final gate = bridge.gate = Completer<void>();

    final first = sync.drain();
    await Future<void>.delayed(Duration.zero);
    expect(bridge.peeks, 1);

    bridge.inbox.add(capture('b'));
    await sync.drain();
    await sync.drain();
    expect(bridge.peeks, 1, reason: 'peek kedua menunggu putaran pertama');

    gate.complete();
    await first;

    expect(bridge.peeks, 2);
    expect(bridge.inbox, isEmpty);
    expect(await openTitles(), ['Tugas a', 'Tugas b']);
  });

  test('op yang datang selama putaran tidak hilang', () async {
    bridge.inbox.add(capture('a'));
    final gate = bridge.gate = Completer<void>();
    final first = sync.drain();
    await Future<void>.delayed(Duration.zero);
    gate.complete();
    await Future<void>.delayed(Duration.zero);

    bridge.inbox.add(capture('b'));
    await sync.drain();
    await first;
    await sync.drain();

    expect(bridge.inbox, isEmpty);
    expect(await openTitles(), ['Tugas a', 'Tugas b']);
  });
}
