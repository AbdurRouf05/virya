import 'package:drift/drift.dart';

/// Identitas sosial yang diketahui perangkat. Tepat satu baris [isLocal] adalah
/// pemilik perangkat ini; baris lain disiapkan untuk anggota circle dari luar.
class SocialIdentities extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get publicKey => text()();
  BoolColumn get isLocal => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Circle privat. Pemilik wajib adalah salah satu [SocialIdentities].
class SocialCircles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get ownerIdentityId =>
      text().references(SocialIdentities, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Keanggotaan circle. Kombinasi circle dan identitas tidak boleh ganda.
class CircleMembers extends Table {
  TextColumn get circleId =>
      text().references(SocialCircles, #id, onDelete: KeyAction.cascade)();
  TextColumn get identityId =>
      text().references(SocialIdentities, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text().withDefault(const Constant('member'))();
  DateTimeColumn get joinedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {circleId, identityId};
}
