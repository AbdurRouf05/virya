import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/features/gym/data/gym_providers.dart';
import 'package:virya/features/gym/domain/gym_math.dart';
import 'package:virya/features/gym/domain/gym_models.dart';

/// PR per gerakan dari semua sesi selesai.
final gymPrsProvider = Provider<Map<String, ExercisePr>>(
  (ref) => personalRecordsByExercise(
    ref.watch(loggedSetsProvider).valueOrNull ?? const [],
  ),
);

/// Volume 8 minggu terakhir (lama → baru).
final gymWeeklyVolumeProvider = Provider<List<(DateTime, double)>>((ref) {
  ref.watch(currentDayProvider);
  return weeklyVolume(
    ref.watch(loggedSetsProvider).valueOrNull ?? const [],
    DateTime.now(),
  );
});

/// Kelompok otot terakhir dilatih (`null` = belum pernah).
final gymLastTrainedProvider = Provider<Map<MuscleGroup, DateTime?>>((ref) {
  final lib = ref.watch(exerciseMapProvider);
  return lastTrained(
    ref.watch(loggedSetsProvider).valueOrNull ?? const [],
    (id) => lib[id]?.muscle ?? MuscleGroup.lainnya,
  );
});

/// Set selesai satu gerakan (terbaru dulu), untuk layar riwayat.
final exerciseHistoryProvider = Provider.family<List<SetRecord>, String>(
  (ref, exerciseId) => [
    for (final s in ref.watch(loggedSetsProvider).valueOrNull ?? const [])
      if (s.exerciseId == exerciseId) s,
  ],
);
