import 'package:virya/features/gym/domain/gym_models.dart';

/// Satu baris set di sesi yang sedang berjalan.
class DraftSet {
  final String id;

  /// Kosong (`null`) = belum diisi; patokan diambil dari [hint].
  final double? weightKg;
  final int? reps;
  final double? rpe;
  final bool isWarmup;
  final DateTime? completedAt;

  /// Patokan dari sesi sebelumnya / template (tampil redup).
  final double? hintWeightKg;
  final int? hintReps;

  const DraftSet({
    required this.id,
    this.weightKg,
    this.reps,
    this.rpe,
    this.isWarmup = false,
    this.completedAt,
    this.hintWeightKg,
    this.hintReps,
  });

  bool get done => completedAt != null;

  /// Nilai yang dipakai saat dicentang: isian, kalau kosong patokan.
  double get effectiveWeight => weightKg ?? hintWeightKg ?? 0;
  int get effectiveReps => reps ?? hintReps ?? 0;

  DraftSet copyWith({
    double? Function()? weightKg,
    int? Function()? reps,
    double? Function()? rpe,
    bool? isWarmup,
    DateTime? Function()? completedAt,
  }) => DraftSet(
    id: id,
    weightKg: weightKg == null ? this.weightKg : weightKg(),
    reps: reps == null ? this.reps : reps(),
    rpe: rpe == null ? this.rpe : rpe(),
    isWarmup: isWarmup ?? this.isWarmup,
    completedAt: completedAt == null ? this.completedAt : completedAt(),
    hintWeightKg: hintWeightKg,
    hintReps: hintReps,
  );
}

/// Satu gerakan di sesi + set-setnya.
class DraftExercise {
  final ExerciseInfo exercise;
  final List<DraftSet> sets;

  /// Set sesi sebelumnya per indeks: "sblm 60×8".
  final List<(double weightKg, int reps)> previous;

  const DraftExercise({
    required this.exercise,
    required this.sets,
    this.previous = const [],
  });

  int get doneCount => sets.where((s) => s.done).length;

  (double, int)? previousAt(int i) => i < previous.length ? previous[i] : null;

  DraftExercise withSets(List<DraftSet> s) =>
      DraftExercise(exercise: exercise, sets: s, previous: previous);
}

/// Ringkasan sesi untuk header (volume, set, gerakan).
class DraftSummary {
  final double volumeKg;
  final int doneSets;
  final int totalSets;
  final int doneExercises;
  final int totalExercises;

  const DraftSummary({
    required this.volumeKg,
    required this.doneSets,
    required this.totalSets,
    required this.doneExercises,
    required this.totalExercises,
  });

  factory DraftSummary.of(List<DraftExercise> list) {
    var vol = 0.0;
    var done = 0, total = 0, exDone = 0;
    for (final e in list) {
      total += e.sets.length;
      final d = e.doneCount;
      done += d;
      if (e.sets.isNotEmpty && d == e.sets.length) exDone++;
      for (final s in e.sets) {
        if (s.done && !s.isWarmup) vol += (s.weightKg ?? 0) * (s.reps ?? 0);
      }
    }
    return DraftSummary(
      volumeKg: vol,
      doneSets: done,
      totalSets: total,
      doneExercises: exDone,
      totalExercises: list.length,
    );
  }
}

/// Judul sesi: "Gym · Push day" atau "Gym · Sore".
String gymSessionTitle(DateTime start, {String? templateName}) {
  final name = templateName?.trim();
  if (name != null && name.isNotEmpty) return 'Gym · $name';
  final h = start.hour;
  final part = h < 11
      ? 'Pagi'
      : h < 15
      ? 'Siang'
      : h < 18
      ? 'Sore'
      : 'Malam';
  return 'Gym · $part';
}

/// "62,5" / "60" — beban gaya Indonesia, tanpa nol di belakang.
String fmtKg(double kg) {
  final r = (kg * 100).round() / 100;
  var s = r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toString();
  s = s.replaceAll('.', ',');
  return s;
}

/// Isian bebas → angka (menerima koma). Kosong/invalid → null.
double? parseKg(String s) {
  final t = s.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  final v = double.tryParse(t);
  return v == null || v < 0 ? null : v;
}
