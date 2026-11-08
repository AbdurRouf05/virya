import 'package:virya/features/gym/domain/gym_models.dart';

/// Perkiraan 1RM (rumus Epley). 1 rep = beban itu sendiri.
double epley1rm(double weightKg, int reps) {
  if (reps <= 0 || weightKg <= 0) return 0;
  if (reps == 1) return weightKg;
  return weightKg * (1 + reps / 30);
}

/// Total volume (kg × reps) set kerja; set pemanasan diabaikan.
double totalVolume(Iterable<SetRecord> sets, {bool includeWarmup = false}) {
  var v = 0.0;
  for (final s in sets) {
    if (s.isWarmup && !includeWarmup) continue;
    v += s.volume;
  }
  return v;
}

/// Rekor pribadi untuk satu gerakan.
class ExercisePr {
  /// Beban terberat + reps-nya.
  final double maxWeightKg;
  final int maxWeightReps;

  /// Perkiraan 1RM terbaik (Epley).
  final double best1rm;

  /// Set dengan volume (kg × reps) terbesar.
  final double bestSetWeightKg;
  final int bestSetReps;

  /// Waktu sesi tempat beban maks dicapai.
  final DateTime achievedAt;

  const ExercisePr({
    required this.maxWeightKg,
    required this.maxWeightReps,
    required this.best1rm,
    required this.bestSetWeightKg,
    required this.bestSetReps,
    required this.achievedAt,
  });

  double get bestSetVolume => bestSetWeightKg * bestSetReps;
}

/// PR dari set-set satu gerakan (set kerja saja). `null` bila kosong.
ExercisePr? personalRecords(Iterable<SetRecord> sets) {
  SetRecord? heaviest;
  SetRecord? bestVolume;
  var best1rm = 0.0;
  for (final s in sets) {
    if (s.isWarmup || s.reps <= 0) continue;
    if (heaviest == null ||
        s.weightKg > heaviest.weightKg ||
        (s.weightKg == heaviest.weightKg && s.reps > heaviest.reps)) {
      heaviest = s;
    }
    if (bestVolume == null || s.volume > bestVolume.volume) bestVolume = s;
    final e = epley1rm(s.weightKg, s.reps);
    if (e > best1rm) best1rm = e;
  }
  if (heaviest == null || bestVolume == null) return null;
  return ExercisePr(
    maxWeightKg: heaviest.weightKg,
    maxWeightReps: heaviest.reps,
    best1rm: best1rm,
    bestSetWeightKg: bestVolume.weightKg,
    bestSetReps: bestVolume.reps,
    achievedAt: heaviest.sessionStart,
  );
}

/// PR per gerakan: `exerciseId → PR`.
Map<String, ExercisePr> personalRecordsByExercise(Iterable<SetRecord> sets) {
  final groups = <String, List<SetRecord>>{};
  for (final s in sets) {
    (groups[s.exerciseId] ??= []).add(s);
  }
  return {for (final e in groups.entries) e.key: ?personalRecords(e.value)};
}

/// Senin 00:00 (lokal) dari minggu tempat [t] berada.
DateTime gymWeekStart(DateTime t) {
  final d = DateTime(t.year, t.month, t.day);
  return d.subtract(Duration(days: d.weekday - 1));
}

/// Volume per minggu untuk [weeks] minggu terakhir (termasuk minggu ini),
/// urut lama → baru. Minggu tanpa latihan bernilai 0.
List<(DateTime week, double volume)> weeklyVolume(
  Iterable<SetRecord> sets,
  DateTime now, {
  int weeks = 8,
}) {
  final thisWeek = gymWeekStart(now);
  final keys = [
    for (var i = weeks - 1; i >= 0; i--)
      DateTime(thisWeek.year, thisWeek.month, thisWeek.day - 7 * i),
  ];
  final sums = {for (final k in keys) k: 0.0};
  for (final s in sets) {
    if (s.isWarmup) continue;
    final k = gymWeekStart(s.sessionStart.toLocal());
    if (sums.containsKey(k)) sums[k] = sums[k]! + s.volume;
  }
  return [for (final k in keys) (k, sums[k]!)];
}

/// Kapan terakhir tiap kelompok otot dilatih (`null` = belum pernah).
Map<MuscleGroup, DateTime?> lastTrained(
  Iterable<SetRecord> sets,
  MuscleGroup Function(String exerciseId) muscleOf,
) {
  final out = <MuscleGroup, DateTime?>{
    for (final m in MuscleGroup.tracked) m: null,
  };
  for (final s in sets) {
    final m = muscleOf(s.exerciseId);
    if (!out.containsKey(m)) continue;
    final prev = out[m];
    if (prev == null || s.sessionStart.isAfter(prev)) out[m] = s.sessionStart;
  }
  return out;
}

/// Kelompok otot yang TIDAK dilatih dalam [days] hari terakhir.
List<MuscleGroup> neglectedMuscles(
  Iterable<SetRecord> sets,
  MuscleGroup Function(String exerciseId) muscleOf,
  DateTime now, {
  int days = 7,
}) {
  final cutoff = now.subtract(Duration(days: days));
  final last = lastTrained(sets, muscleOf);
  return [
    for (final m in MuscleGroup.tracked)
      if (last[m] == null || last[m]!.isBefore(cutoff)) m,
  ];
}
