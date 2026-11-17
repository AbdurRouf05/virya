import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/core/time/day_key.dart';
import 'package:virya/features/body/data/body_repository.dart';
import 'package:virya/features/body/domain/body_logic.dart';
import 'package:virya/features/body/domain/body_models.dart';

/// Folder dokumen aplikasi; path foto di database relatif terhadap folder ini.
final bodyBaseDirProvider = FutureProvider<Directory>(
  (ref) => getApplicationDocumentsDirectory(),
);

final bodyRepositoryProvider = Provider<BodyRepository>(
  (ref) => BodyRepository(
    ref.watch(bodyDaoProvider),
    () => ref.read(bodyBaseDirProvider.future),
  ),
);

/// Semua check-in, terbaru dulu.
final bodyEntriesProvider = StreamProvider<List<BodyEntry>>((ref) async* {
  final base = await ref.watch(bodyBaseDirProvider.future);
  yield* ref
      .watch(bodyDaoProvider)
      .watchAll()
      .map((rows) => [for (final r in rows) bodyEntryOf(r, base.path)]);
});

/// Check-in pada satu hari (`YYYY-MM-DD`), bila ada.
final bodyEntryOnProvider = Provider.family<BodyEntry?, String>((ref, day) {
  final all = ref.watch(bodyEntriesProvider).valueOrNull ?? const <BodyEntry>[];
  for (final e in all) {
    if (dayKeyOf(e.day) == day) return e;
  }
  return null;
});

/// Jarak pengingat check-in dalam hari; `0` berarti mati.
final bodyCheckinIntervalProvider = Provider<int>(
  (ref) => bodyCheckinIntervalOf(
    ref.watch(settingsProvider)[SettingKeys.bodyCheckinDays],
  ),
);

/// Apakah sudah waktunya check-in lagi.
final bodyCheckinDueProvider = Provider<bool>((ref) {
  final today = ref.watch(currentDayProvider);
  final all = ref.watch(bodyEntriesProvider).valueOrNull ?? const <BodyEntry>[];
  return isBodyCheckinDue(
    all,
    today,
    intervalDays: ref.watch(bodyCheckinIntervalProvider),
  );
});
