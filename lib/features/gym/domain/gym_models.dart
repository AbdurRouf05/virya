/// Model murni modul gym (tanpa Flutter / DB).
library;

/// Kelompok otot utama. Disimpan sebagai [name] di `exercises.muscleGroup`.
enum MuscleGroup {
  dada('DADA'),
  punggung('PUNGGUNG'),
  kaki('KAKI'),
  bahu('BAHU'),
  lengan('LENGAN'),
  core('CORE'),
  lainnya('LAINNYA');

  final String label;
  const MuscleGroup(this.label);

  static MuscleGroup parse(String? s) =>
      values.asNameMap()[s?.toLowerCase()] ?? MuscleGroup.lainnya;

  /// Kelompok yang dipantau "jarang dilatih" (tanpa `lainnya`).
  static List<MuscleGroup> get tracked =>
      values.where((m) => m != lainnya).toList(growable: false);
}

/// Alat. Disimpan sebagai [name] di `exercises.equipment`.
enum Equipment {
  barbel('BARBEL'),
  dumbel('DUMBEL'),
  mesin('MESIN'),
  kabel('KABEL'),
  badan('BERAT BADAN'),
  lainnya('LAINNYA');

  final String label;
  const Equipment(this.label);

  static Equipment parse(String? s) =>
      values.asNameMap()[s?.toLowerCase()] ?? Equipment.lainnya;
}

/// Satu gerakan dari library.
class ExerciseInfo {
  final String id;
  final String name;
  final MuscleGroup muscle;
  final Equipment equipment;
  final bool isCustom;

  const ExerciseInfo({
    required this.id,
    required this.name,
    required this.muscle,
    this.equipment = Equipment.lainnya,
    this.isCustom = false,
  });
}

/// Satu set yang sudah selesai (dipakai untuk statistik & PR).
class SetRecord {
  final String sessionId;
  final String exerciseId;
  final DateTime sessionStart;
  final double weightKg;
  final int reps;
  final double? rpe;
  final bool isWarmup;

  const SetRecord({
    required this.sessionId,
    required this.exerciseId,
    required this.sessionStart,
    required this.weightKg,
    required this.reps,
    this.rpe,
    this.isWarmup = false,
  });

  double get volume => weightKg * reps;
}

/// Isi template: gerakan + target.
class TemplateItem {
  final String exerciseId;
  final int targetSets;
  final int targetReps;
  const TemplateItem({
    required this.exerciseId,
    this.targetSets = 3,
    this.targetReps = 8,
  });
}

class GymTemplate {
  final String id;
  final String name;
  final String? note;
  final List<TemplateItem> items;
  const GymTemplate({
    required this.id,
    required this.name,
    this.note,
    this.items = const [],
  });
}
