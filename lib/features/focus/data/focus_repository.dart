import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/daos/focus_dao.dart';
import 'package:virya/core/time/day_key.dart';
import 'package:virya/features/focus/data/focus_bridge.dart';
import 'package:virya/features/focus/domain/focus_logic.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

FocusLimit focusLimitOf(AppLimit r) => FocusLimit(
  packageName: r.packageName,
  label: r.label,
  dailyMinutes: r.dailyMinutes,
  enabled: r.enabled,
  createdAt: r.createdAt,
);

FocusDayEntry focusDayEntryOf(AppUsageDay r) => FocusDayEntry(
  day: r.day,
  packageName: r.packageName,
  label: r.label,
  minutes: r.minutes,
  limitMinutes: r.limitMinutes,
);

/// SQLite memegang data batas dan riwayat; Android memegang salinan batas
/// untuk menegakkannya. Native tidak pernah menulis ke SQLite.
class FocusRepository {
  final FocusDao _dao;
  final FocusBridge _bridge;
  final DateTime Function() _clock;

  FocusRepository(this._dao, this._bridge, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  Future<void> saveLimit({
    required String packageName,
    required String label,
    required int dailyMinutes,
  }) => _dao.upsertLimit(
    AppLimitsCompanion.insert(
      packageName: packageName,
      label: label,
      dailyMinutes: normalizeFocusMinutes(dailyMinutes),
      createdAt: _clock().toUtc(),
    ),
  );

  Future<void> setEnabled(String packageName, bool on) =>
      _dao.setEnabled(packageName, on);

  Future<void> removeLimit(String packageName) =>
      _dao.deleteLimit(packageName);

  Future<void> pushLimits(List<FocusLimit> limits) =>
      _bridge.pushLimits(limits);

  /// Kirim batas ke Android, lalu salin pemakaian terbaru ke riwayat.
  /// Mengembalikan menit tambahan yang sudah diambil hari ini.
  Future<Map<String, int>> sync() async {
    final limits = (await _dao.getLimits()).map(focusLimitOf).toList();
    await _bridge.pushLimits(limits);
    if (limits.isEmpty) return const {};
    final read = await _bridge.readUsage(focusHistoryDays);
    final rows = focusRowsToSave(read.rows, limits);
    await _dao.upsertUsage([
      for (final e in rows)
        AppUsageDaysCompanion.insert(
          day: e.day,
          packageName: e.packageName,
          label: e.label,
          minutes: e.minutes,
          limitMinutes: e.limitMinutes,
        ),
    ], dayKeyOf(_clock()));
    return read.bonus;
  }
}
