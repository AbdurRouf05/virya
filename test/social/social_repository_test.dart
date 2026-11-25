import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/social/data/social_repository.dart';

void main() {
  late AppDatabase db;
  late SocialRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = SocialRepository(db.socialDao, keyStore: MemorySocialKeyStore());
  });

  tearDown(() => db.close());

  test('identity dibuat sekali dan nama kosong ditolak', () async {
    expect(await repo.ensureIdentity('  \n '), isNull);

    final first = await repo.ensureIdentity('  Run   Pagi ');
    final second = await repo.ensureIdentity('Nama lain');
    final rows = await db.select(db.socialIdentities).get();

    expect(first, isNotNull);
    expect(second!.id, first!.id);
    expect(first.displayName, 'Run Pagi');
    expect(rows, hasLength(1));
    expect(rows.single.isLocal, isTrue);
  });

  test('circle menyimpan pemilik lokal dan menolak nama kosong', () async {
    await repo.ensureIdentity('Ayu');
    expect(await repo.createCircle('   '), isNull);

    final id = await repo.createCircle('  Sunday   Runners ');
    final circles = await db.select(db.socialCircles).get();
    final members = await db.select(db.circleMembers).get();

    expect(id, isNotNull);
    expect(circles.single.name, 'Sunday Runners');
    expect(members, hasLength(1));
    expect(members.single.circleId, id);
    expect(members.single.identityId, circles.single.ownerIdentityId);
    expect(members.single.role, 'owner');
  });

  test('menghapus identity menghapus circle dan membership terkait', () async {
    final identity = await repo.ensureIdentity('Ayu');
    final circleId = await repo.createCircle('Sunrise');

    await (db.delete(db.socialIdentities)
          ..where((row) => row.id.equals(identity!.id)))
        .go();

    expect(await db.select(db.socialCircles).get(), isEmpty);
    expect(await db.select(db.circleMembers).get(), isEmpty);
    expect(circleId, isNotNull);
  });
}
