import 'package:drift/drift.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/tables/social_tables.dart';

part 'social_dao.g.dart';

/// Akses identitas perangkat dan circle privat yang tersimpan lokal.
@DriftAccessor(tables: [SocialIdentities, SocialCircles, CircleMembers])
class SocialDao extends DatabaseAccessor<AppDatabase> with _$SocialDaoMixin {
  SocialDao(super.db);

  Future<SocialIdentity?> localIdentity() =>
      (select(socialIdentities)
        ..where((t) => t.isLocal.equals(true))).getSingleOrNull();

  Stream<List<SocialCircle>> watchOwnedCircles(String identityId) =>
      (select(socialCircles)
            ..where((t) => t.ownerIdentityId.equals(identityId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();

  Stream<List<SocialCircle>> watchCircles(String identityId) {
    final query =
        select(socialCircles).join([
            innerJoin(
              circleMembers,
              circleMembers.circleId.equalsExp(socialCircles.id),
            ),
          ])
          ..where(circleMembers.identityId.equals(identityId))
          ..orderBy([OrderingTerm.desc(socialCircles.updatedAt)]);
    return query.watch().map(
      (rows) => [for (final row in rows) row.readTable(socialCircles)],
    );
  }

  Future<void> insertIdentity(SocialIdentitiesCompanion row) =>
      into(socialIdentities).insert(row);

  Future<SocialCircle?> circleById(String id) =>
      (select(socialCircles)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> saveAcceptedInvite({
    required SocialIdentitiesCompanion issuer,
    required SocialCirclesCompanion circle,
    required CircleMembersCompanion owner,
    required CircleMembersCompanion recipient,
  }) => transaction(() async {
    await into(
      socialIdentities,
    ).insert(issuer, mode: InsertMode.insertOrIgnore);
    await into(socialCircles).insert(circle, mode: InsertMode.insertOrIgnore);
    await into(circleMembers).insert(owner, mode: InsertMode.insertOrIgnore);
    await into(
      circleMembers,
    ).insert(recipient, mode: InsertMode.insertOrIgnore);
  });

  Future<void> createOwnedCircle({
    required SocialCirclesCompanion circle,
    required CircleMembersCompanion owner,
  }) => transaction(() async {
    await into(socialCircles).insert(circle);
    await into(circleMembers).insert(owner);
  });
}
