import 'package:drift/drift.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/tables/body_tables.dart';

part 'body_dao.g.dart';

typedef BodyCheckinRow = ({BodyCheckin checkin, List<BodyPhoto> photos});

/// Akses check-in dan foto progres tubuh.
@DriftAccessor(tables: [BodyCheckins, BodyPhotos])
class BodyDao extends DatabaseAccessor<AppDatabase> with _$BodyDaoMixin {
  BodyDao(super.db);

  /// Semua check-in beserta fotonya, terbaru dulu.
  Stream<List<BodyCheckinRow>> watchAll() {
    final q = select(bodyCheckins).join([
      leftOuterJoin(
        bodyPhotos,
        bodyPhotos.checkinId.equalsExp(bodyCheckins.id),
      ),
    ])..orderBy([OrderingTerm.desc(bodyCheckins.day)]);
    return q.watch().map((rows) {
      final byId = <String, BodyCheckinRow>{};
      for (final r in rows) {
        final c = r.readTable(bodyCheckins);
        final row = byId.putIfAbsent(c.id, () => (checkin: c, photos: []));
        final photo = r.readTableOrNull(bodyPhotos);
        if (photo != null) row.photos.add(photo);
      }
      return byId.values.toList();
    });
  }

  Future<BodyCheckin?> findByDay(String day) =>
      (select(bodyCheckins)..where((t) => t.day.equals(day))).getSingleOrNull();

  Future<void> insertCheckin(BodyCheckinsCompanion row) =>
      into(bodyCheckins).insert(row, mode: InsertMode.insertOrIgnore);

  Future<void> updateCheckin(String id, BodyCheckinsCompanion row) =>
      (update(bodyCheckins)..where((t) => t.id.equals(id))).write(row);

  /// Foto-fotonya ikut terhapus lewat foreign key.
  Future<void> deleteCheckin(String id) =>
      (delete(bodyCheckins)..where((t) => t.id.equals(id))).go();

  Future<List<BodyPhoto>> photosOf(String checkinId) =>
      (select(bodyPhotos)..where((t) => t.checkinId.equals(checkinId))).get();

  Future<BodyPhoto?> findPhoto(String id) =>
      (select(bodyPhotos)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Ganti foto pose tersebut. Mengembalikan baris lama, agar berkasnya bisa
  /// dihapus setelah penggantian berhasil.
  Future<BodyPhoto?> replacePhoto(BodyPhotosCompanion row) =>
      transaction(() async {
        final old =
            await (select(bodyPhotos)..where(
                  (t) =>
                      t.checkinId.equals(row.checkinId.value) &
                      t.pose.equals(row.pose.value),
                ))
                .getSingleOrNull();
        if (old != null) {
          await (delete(bodyPhotos)..where((t) => t.id.equals(old.id))).go();
        }
        await into(bodyPhotos).insert(row);
        return old;
      });

  Future<void> deletePhoto(String id) =>
      (delete(bodyPhotos)..where((t) => t.id.equals(id))).go();
}
