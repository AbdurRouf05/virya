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

  int? ms(DateTime? d) => d?.millisecondsSinceEpoch;

  Future<TaskItem> one(String id) async => taskItemOf(
    (await db.tasksDao.watchOpen().first).singleWhere((t) => t.id == id),
  );

  test('add rutinitas menyimpan jam pengingat tanpa tanggal', () async {
    final id = await repo.add(
      'Push GitHub',
      due: DateTime(2026, 11, 16),
      repeatDaily: true,
      remindMinute: 20 * 60,
    );
    final t = await one(id!);
    expect(t.repeatDaily, isTrue);
    expect(t.remindMinute, 20 * 60);
    expect(t.due, isNull);
  });

  test('save mengosongkan tanggal & jam sesuai mode', () async {
    final id = (await repo.add('Live', due: DateTime(2026, 11, 16)))!;
    final base = await one(id);
    await repo.save(
      TaskItem(
        id: id,
        title: base.title,
        due: base.due,
        repeatDaily: true,
        remindMinute: 19 * 60,
        createdAt: base.createdAt,
      ),
    );
    var t = await one(id);
    expect(t.repeatDaily, isTrue);
    expect(t.due, isNull);
    expect(t.remindMinute, 19 * 60);

    await repo.save(
      TaskItem(
        id: id,
        title: t.title,
        remindMinute: 19 * 60,
        createdAt: t.createdAt,
      ),
    );
    t = await one(id);
    expect(t.repeatDaily, isFalse);
    expect(t.remindMinute, isNull);
  });

  test('rutinitas yang sudah dicentang tetap terbaca oleh watchOpen', () async {
    final id = (await repo.add('Rutin', repeatDaily: true))!;
    await repo.setDone(id, true);
    expect((await one(id)).isDone, isTrue);
    expect((await db.tasksDao.watchRoutines().first).single.id, id);
  });

  test('done dari luar: rutinitas kemarin bisa dicentang lagi, sekali per hari',
      () async {
    final id = (await repo.add('Rutin', repeatDaily: true))!;
    final yesterday = DateTime(2026, 11, 15, 9).toUtc();
    final morning = DateTime(2026, 11, 16, 8).toUtc();
    final later = DateTime(2026, 11, 16, 10).toUtc();
    await repo.applyOp(TaskDoneOp('a', yesterday, taskId: id));
    expect(ms((await one(id)).doneAt), yesterday.millisecondsSinceEpoch);
    await repo.applyOp(TaskDoneOp('b', morning, taskId: id));
    expect(ms((await one(id)).doneAt), morning.millisecondsSinceEpoch);
    await repo.applyOp(TaskDoneOp('c', later, taskId: id));
    expect(ms((await one(id)).doneAt), morning.millisecondsSinceEpoch);
  });

  test('done dari luar untuk tugas biasa tetap sekali saja', () async {
    final id = (await repo.add('Biasa'))!;
    final first = DateTime(2026, 11, 15, 9).toUtc();
    await repo.applyOp(TaskDoneOp('a', first, taskId: id));
    await repo.applyOp(
      TaskDoneOp('b', DateTime(2026, 11, 16, 9).toUtc(), taskId: id),
    );
    final row = (await db.tasksDao.watchDone().first).single;
    expect(ms(row.doneAt), first.millisecondsSinceEpoch);
  });
}
