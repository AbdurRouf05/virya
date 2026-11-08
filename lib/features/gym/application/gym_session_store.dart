import 'package:drift/drift.dart' show Value;
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/daos/gym_dao.dart';
import 'package:virya/features/gym/data/gym_providers.dart';
import 'package:virya/features/gym/domain/gym_models.dart';
import 'package:virya/features/gym/domain/session_draft.dart';

/// Penulisan sesi berjalan ke DB. Semua tulis diantrekan agar urutannya
/// terjaga walau dipanggil tanpa `await` dari UI.
class GymSessionStore {
  final GymDao dao;
  GymSessionStore(this.dao);

  Future<void> _queue = Future.value();

  Future<void> _enqueue(Future<void> Function() op) =>
      _queue = _queue.then((_) => op()).catchError((_) {});

  /// Tunggu semua tulis yang tertunda.
  Future<void> flush() => _queue;

  Future<void> writeSet(
    String activityId,
    String exerciseId,
    int order,
    int index,
    DraftSet s,
  ) => _enqueue(
    () => dao.upsertSet(
      WorkoutSetsCompanion.insert(
        id: s.id,
        activityId: activityId,
        exerciseId: exerciseId,
        exerciseOrder: order,
        setIndex: index,
        reps: Value(s.reps),
        weightKg: Value(s.weightKg),
        rpe: Value(s.rpe),
        isWarmup: Value(s.isWarmup),
        completedAt: Value(s.completedAt?.toUtc()),
      ),
    ),
  );

  /// Tulis ulang semua set satu gerakan (setelah urutan berubah).
  Future<void> writeExercise(String activityId, int order, DraftExercise e) {
    var f = Future<void>.value();
    for (final (i, s) in e.sets.indexed) {
      f = writeSet(activityId, e.exercise.id, order, i, s);
    }
    return f;
  }

  Future<void> deleteSet(String id) => _enqueue(() => dao.deleteSet(id));

  /// Patokan "sblm": set kerja sesi terakhir untuk gerakan ini.
  Future<List<(double, int)>> previous(
    String exerciseId,
    String current,
  ) async {
    final rows = await dao.previousSets(exerciseId, excludeActivityId: current);
    return [for (final r in rows) (r.weightKg ?? 0, r.reps ?? 0)];
  }

  /// Bangun ulang draf dari DB (melanjutkan sesi setelah aplikasi ditutup).
  Future<List<DraftExercise>> load(
    String activityId,
    Map<String, ExerciseInfo> library,
  ) async {
    final rows = await dao.setsFor(activityId);
    final byOrder = <int, List<WorkoutSet>>{};
    for (final r in rows) {
      (byOrder[r.exerciseOrder] ??= []).add(r);
    }
    final keys = byOrder.keys.toList()..sort();
    final out = <DraftExercise>[];
    for (final k in keys) {
      final sets = byOrder[k]!;
      final exId = sets.first.exerciseId;
      final info =
          library[exId] ??
          ExerciseInfo(id: exId, name: 'Gerakan', muscle: MuscleGroup.lainnya);
      final prev = await previous(exId, activityId);
      out.add(
        DraftExercise(
          exercise: info,
          previous: prev,
          sets: [
            for (final (i, s) in sets.indexed)
              DraftSet(
                id: s.id,
                weightKg: s.weightKg,
                reps: s.reps,
                rpe: s.rpe,
                isWarmup: s.isWarmup,
                completedAt: s.completedAt,
                hintWeightKg: i < prev.length ? prev[i].$1 : null,
                hintReps: i < prev.length ? prev[i].$2 : null,
              ),
          ],
        ),
      );
    }
    return out;
  }

  Future<Map<String, ExerciseInfo>> library() async => {
    for (final e in await dao.watchExercises().first) e.id: exerciseInfoOf(e),
  };
}
