import 'package:drift/drift.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/tables/focus_tables.dart';

part 'focus_dao.g.dart';

/// Akses batas aplikasi dan riwayat pemakaian harian.
@DriftAccessor(tables: [AppLimits, AppUsageDays])
class FocusDao extends DatabaseAccessor<AppDatabase> with _$FocusDaoMixin {
  FocusDao(super.db);

  Stream<List<AppLimit>> watchLimits() =>
      (select(appLimits)..orderBy([(t) => OrderingTerm.asc(t.label)])).watch();

  Future<List<AppLimit>> getLimits() => select(appLimits).get();

  /// Tambah batas, atau ubah menitnya bila aplikasi sudah terdaftar.
  /// `createdAt` milik baris lama dipertahankan.
  Future<void> upsertLimit(AppLimitsCompanion row) =>
      into(appLimits).insert(
        row,
        onConflict: DoUpdate(
          (_) => AppLimitsCompanion(
            label: row.label,
            dailyMinutes: row.dailyMinutes,
            enabled: const Value(true),
          ),
        ),
      );

  Future<void> setEnabled(String packageName, bool on) =>
      (update(appLimits)..where((t) => t.packageName.equals(packageName)))
          .write(AppLimitsCompanion(enabled: Value(on)));

  Future<void> deleteLimit(String packageName) =>
      (delete(appLimits)..where((t) => t.packageName.equals(packageName))).go();

  Stream<List<AppUsageDay>> watchUsageOn(String day) =>
      (select(appUsageDays)..where((t) => t.day.equals(day))).watch();

  /// Simpan hasil baca pemakaian. Baris [today] ditimpa penuh. Hari lampau
  /// hanya boleh naik, karena Android membuang data lamanya sedikit demi
  /// sedikit, dan batas yang berlaku saat itu dipertahankan.
  Future<void> upsertUsage(List<AppUsageDaysCompanion> rows, String today) =>
      transaction(() async {
        for (final r in rows) {
          if (r.day.value == today) {
            await into(appUsageDays).insertOnConflictUpdate(r);
          } else {
            final minutes = r.minutes.value;
            await into(appUsageDays).insert(
              r,
              onConflict: DoUpdate(
                (_) => AppUsageDaysCompanion(minutes: Value(minutes)),
                where: (old) => old.minutes.isSmallerThanValue(minutes),
              ),
            );
          }
        }
      });
}
