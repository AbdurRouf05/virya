import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/daos/gym_dao.dart';
import 'package:virya/features/gym/domain/gym_models.dart';

/// DB row → model domain.
ExerciseInfo exerciseInfoOf(Exercise e) => ExerciseInfo(
  id: e.id,
  name: e.name,
  muscle: MuscleGroup.parse(e.muscleGroup),
  equipment: Equipment.parse(e.equipment),
  isCustom: e.isCustom,
);

SetRecord setRecordOf(WorkoutSet s, DateTime sessionStart) => SetRecord(
  sessionId: s.activityId,
  exerciseId: s.exerciseId,
  sessionStart: sessionStart,
  weightKg: s.weightKg ?? 0,
  reps: s.reps ?? 0,
  rpe: s.rpe,
  isWarmup: s.isWarmup,
);

/// Seluruh library gerakan, urut nama.
final exercisesProvider = StreamProvider<List<ExerciseInfo>>(
  (ref) => ref
      .watch(gymDaoProvider)
      .watchExercises()
      .map((l) => l.map(exerciseInfoOf).toList()),
);

/// `id → gerakan` untuk pencarian cepat.
final exerciseMapProvider = Provider<Map<String, ExerciseInfo>>(
  (ref) => {
    for (final e in ref.watch(exercisesProvider).valueOrNull ?? const [])
      e.id: e,
  },
);

/// Semua set selesai dari sesi selesai (terbaru dulu).
final loggedSetsProvider = StreamProvider<List<SetRecord>>(
  (ref) => ref
      .watch(gymDaoProvider)
      .watchLoggedSets()
      .map(
        (rows) => [
          for (final LoggedSet r in rows) setRecordOf(r.set, r.sessionStart),
        ],
      ),
);

/// Sesi gym selesai terbaru.
final recentGymSessionsProvider = StreamProvider<List<Activity>>(
  (ref) => ref.watch(gymDaoProvider).watchSessions(limit: 10),
);

final _templateRowsProvider = StreamProvider<List<WorkoutTemplate>>(
  (ref) => ref.watch(gymDaoProvider).watchTemplates(),
);
final _templateItemRowsProvider = StreamProvider<List<WorkoutTemplateItem>>(
  (ref) => ref.watch(gymDaoProvider).watchTemplateItems(),
);

/// Template lengkap dengan isinya.
final templatesProvider = Provider<AsyncValue<List<GymTemplate>>>((ref) {
  final items = ref.watch(_templateItemRowsProvider).valueOrNull ?? const [];
  return ref
      .watch(_templateRowsProvider)
      .whenData(
        (rows) => [
          for (final t in rows)
            GymTemplate(
              id: t.id,
              name: t.name,
              note: t.note,
              items: [
                for (final i in items)
                  if (i.templateId == t.id)
                    TemplateItem(
                      exerciseId: i.exerciseId,
                      targetSets: i.targetSets,
                      targetReps: i.targetReps,
                    ),
              ],
            ),
        ],
      );
});

/// Set (selesai) satu sesi, untuk halaman detail aktivitas.
final sessionSetsProvider = StreamProvider.family<List<WorkoutSet>, String>(
  (ref, activityId) => ref.watch(gymDaoProvider).watchSetsFor(activityId),
);
