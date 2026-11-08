import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/core/time/day_key.dart';
import 'package:virya/features/focus/data/focus_bridge.dart';
import 'package:virya/features/focus/data/focus_repository.dart';
import 'package:virya/features/focus/domain/focus_logic.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

/// Modul Fokus hanya berjalan di Android.
final focusSupportedProvider = Provider<bool>(
  (ref) => defaultTargetPlatform == TargetPlatform.android,
);

final focusRepositoryProvider = Provider<FocusRepository>(
  (ref) =>
      FocusRepository(ref.watch(focusDaoProvider), ref.watch(focusBridgeProvider)),
);

final focusLimitsProvider = StreamProvider<List<FocusLimit>>(
  (ref) => ref
      .watch(focusDaoProvider)
      .watchLimits()
      .map((rows) => rows.map(focusLimitOf).toList()),
);

/// Riwayat pemakaian pada satu hari (`YYYY-MM-DD`).
final focusUsageOnProvider = StreamProvider.autoDispose
    .family<List<FocusDayEntry>, String>(
      (ref, day) => ref
          .watch(focusDaoProvider)
          .watchUsageOn(day)
          .map((rows) => rows.map(focusDayEntryOf).toList()),
    );

/// packageName → menit tambahan hari ini. Diisi oleh sinkron `FocusHost`.
final focusBonusProvider = StateProvider<Map<String, int>>((ref) => const {});

/// Status batas aktif hari ini; dihitung ulang saat hari berganti.
final focusStatusesProvider = Provider<AsyncValue<List<FocusAppStatus>>>((ref) {
  final day = dayKeyOf(ref.watch(currentDayProvider));
  final bonus = ref.watch(focusBonusProvider);
  final usage = ref.watch(focusUsageOnProvider(day));
  return ref
      .watch(focusLimitsProvider)
      .whenData(
        (limits) => focusStatuses(
          limits: limits,
          today: usage.valueOrNull ?? const [],
          bonus: bonus,
        ),
      );
});

/// Di-`invalidate` setiap aplikasi kembali aktif, karena izin diubah di
/// layar Pengaturan Android.
final focusPermissionsProvider = FutureProvider<FocusPermissions>(
  (ref) => ref.watch(focusBridgeProvider).getPermissions(),
);

final focusInstalledAppsProvider =
    FutureProvider.autoDispose<List<FocusInstalledApp>>(
      (ref) => ref.watch(focusBridgeProvider).installedApps(),
    );
