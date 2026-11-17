import 'package:virya/core/time/day_key.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

const minFocusMinutes = 5;
const maxFocusMinutes = 720;

/// Jumlah hari riwayat yang dibaca dari Android pada tiap sinkron.
const focusHistoryDays = 7;

int normalizeFocusMinutes(int minutes) =>
    minutes.clamp(minFocusMinutes, maxFocusMinutes);

/// `45 mnt`, `1 j`, `1 j 30 mnt`.
String formatFocusMinutes(int minutes) {
  if (minutes < 60) return '$minutes mnt';
  final m = minutes % 60;
  return m == 0 ? '${minutes ~/ 60} j' : '${minutes ~/ 60} j $m mnt';
}

/// Status batas yang aktif, paling sedikit sisa waktunya dulu.
List<FocusAppStatus> focusStatuses({
  required Iterable<FocusLimit> limits,
  required Iterable<FocusDayEntry> today,
  required Map<String, int> bonus,
}) {
  final used = {for (final e in today) e.packageName: e.minutes};
  final out = [
    for (final l in limits)
      if (l.enabled)
        FocusAppStatus(
          limit: l,
          usedMinutes: used[l.packageName] ?? 0,
          bonusMinutes: bonus[l.packageName] ?? 0,
        ),
  ];
  out.sort((a, b) {
    final c = a.remainingMinutes.compareTo(b.remainingMinutes);
    return c != 0 ? c : a.limit.label.compareTo(b.limit.label);
  });
  return out;
}

/// Baris yang layak jadi riwayat: aplikasinya punya batas, dan harinya tidak
/// lebih awal dari saat batas dibuat. Tanpa syarat kedua, batas yang baru
/// dipasang langsung menandai hari-hari lalu sebagai "melewati batas".
List<FocusDayEntry> focusRowsToSave(
  Iterable<FocusUsageRow> rows,
  Iterable<FocusLimit> limits,
) {
  final byPackage = {for (final l in limits) l.packageName: l};
  return [
    for (final r in rows)
      if (byPackage[r.packageName] case final l?)
        if (r.day.compareTo(dayKeyOf(l.createdAt.toLocal())) >= 0)
          FocusDayEntry(
            day: r.day,
            packageName: r.packageName,
            label: l.label,
            minutes: r.minutes,
            limitMinutes: l.dailyMinutes,
          ),
  ];
}
