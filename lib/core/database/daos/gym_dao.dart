import 'package:drift/drift.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/tables/activities_table.dart';
import 'package:virya/core/database/tables/gym_tables.dart';

part 'gym_dao.g.dart';

/// Satu set yang sudah selesai + waktu mulai sesinya.
typedef LoggedSet = ({WorkoutSet set, DateTime sessionStart});

/// Akses data gym: gerakan, set per sesi, dan template.
///
/// Sesi gym = baris `activities` dengan `sportType = 'strength'`. Selama
/// berjalan statusnya `inProgress` dan setiap set langsung ditulis ke DB,
/// jadi sesi tetap aman walau aplikasi ditutup paksa.
@DriftAccessor(
  tables: [
    Activities,
    Exercises,
    WorkoutSets,
    WorkoutTemplates,
    WorkoutTemplateItems,
  ],
)
class GymDao extends DatabaseAccessor<AppDatabase> with _$GymDaoMixin {
  GymDao(super.db);

  static const sport = 'strength';

  // ---- Gerakan ----

  Stream<List<Exercise>> watchExercises() =>
      (select(exercises)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<void> insertExercise(ExercisesCompanion e) =>
      into(exercises).insert(e);

  // ---- Sesi ----

  /// Sesi gym yang belum selesai (paling baru), untuk dilanjutkan.
  Future<Activity?> activeSession() =>
      (select(activities)
            ..where(
              (t) => t.sportType.equals(sport) & t.status.equals('inProgress'),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> startSession({
    required String id,
    required String title,
    required DateTime start,
  }) => into(activities).insert(
    ActivitiesCompanion.insert(
      id: id,
      title: title,
      sportType: sport,
      status: 'inProgress',
      startTime: start,
      updatedAt: start,
    ),
  );

  Future<void> renameSession(String id, String title) =>
      (update(activities)..where((t) => t.id.equals(id))).write(
        ActivitiesCompanion(title: Value(title)),
      );

  SimpleSelectStatement<$WorkoutSetsTable, WorkoutSet> _setsQuery(
    String activityId,
  ) => select(workoutSets)
    ..where((t) => t.activityId.equals(activityId))
    ..orderBy([
      (t) => OrderingTerm.asc(t.exerciseOrder),
      (t) => OrderingTerm.asc(t.setIndex),
    ]);

  Future<List<WorkoutSet>> setsFor(String activityId) =>
      _setsQuery(activityId).get();

  Stream<List<WorkoutSet>> watchSetsFor(String activityId) =>
      _setsQuery(activityId).watch();

  Future<void> upsertSet(WorkoutSetsCompanion s) =>
      into(workoutSets).insertOnConflictUpdate(s);

  Future<void> deleteSet(String id) =>
      (delete(workoutSets)..where((t) => t.id.equals(id))).go();

  /// Tutup sesi: buang set yang belum dicentang, tandai `completed`.
  Future<void> finishSession(String id, {required DateTime end}) =>
      transaction(() async {
        await (delete(
          workoutSets,
        )..where((t) => t.activityId.equals(id) & t.completedAt.isNull())).go();
        final act = await (select(
          activities,
        )..where((t) => t.id.equals(id))).getSingle();
        final secs = end.difference(act.startTime).inSeconds;
        final dur = secs < 0 ? 0 : secs;
        await (update(activities)..where((t) => t.id.equals(id))).write(
          ActivitiesCompanion(
            status: const Value('completed'),
            endTime: Value(end),
            elapsedTimeSeconds: Value(dur),
            movingTimeSeconds: Value(dur),
            updatedAt: Value(end),
          ),
        );
      });

  /// Buang sesi beserta set-nya (FK cascade).
  Future<void> discardSession(String id) =>
      (delete(activities)..where((t) => t.id.equals(id))).go();

  /// Set dari sesi selesai TERAKHIR yang memuat [exerciseId].
  Future<List<WorkoutSet>> previousSets(
    String exerciseId, {
    String? excludeActivityId,
  }) async {
    final q =
        select(workoutSets).join([
            innerJoin(
              activities,
              activities.id.equalsExp(workoutSets.activityId),
            ),
          ])
          ..where(
            workoutSets.exerciseId.equals(exerciseId) &
                activities.status.equals('completed') &
                workoutSets.completedAt.isNotNull(),
          )
          ..orderBy([OrderingTerm.desc(activities.startTime)])
          ..limit(1);
    if (excludeActivityId != null) {
      q.where(activities.id.equals(excludeActivityId).not());
    }
    final row = await q.getSingleOrNull();
    if (row == null) return const [];
    final actId = row.readTable(workoutSets).activityId;
    return (select(workoutSets)
          ..where(
            (t) =>
                t.activityId.equals(actId) &
                t.exerciseId.equals(exerciseId) &
                t.completedAt.isNotNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.setIndex)]))
        .get();
  }

  /// Semua set selesai dari sesi selesai, terbaru dulu (untuk statistik).
  Stream<List<LoggedSet>> watchLoggedSets() {
    final q =
        select(workoutSets).join([
            innerJoin(
              activities,
              activities.id.equalsExp(workoutSets.activityId),
            ),
          ])
          ..where(
            activities.status.equals('completed') &
                workoutSets.completedAt.isNotNull(),
          )
          ..orderBy([
            OrderingTerm.desc(activities.startTime),
            OrderingTerm.asc(workoutSets.exerciseOrder),
            OrderingTerm.asc(workoutSets.setIndex),
          ]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (
            set: r.readTable(workoutSets),
            sessionStart: r.readTable(activities).startTime,
          ),
      ],
    );
  }

  /// Sesi gym yang sudah selesai, terbaru dulu.
  Stream<List<Activity>> watchSessions({int limit = 20}) =>
      (select(activities)
            ..where(
              (t) => t.sportType.equals(sport) & t.status.equals('completed'),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
            ..limit(limit))
          .watch();

  // ---- Template ----

  Stream<List<WorkoutTemplate>> watchTemplates() => (select(
    workoutTemplates,
  )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Stream<List<WorkoutTemplateItem>> watchTemplateItems() => (select(
    workoutTemplateItems,
  )..orderBy([(t) => OrderingTerm.asc(t.itemOrder)])).watch();

  Future<List<WorkoutTemplateItem>> templateItems(String templateId) =>
      (select(workoutTemplateItems)
            ..where((t) => t.templateId.equals(templateId))
            ..orderBy([(t) => OrderingTerm.asc(t.itemOrder)]))
          .get();

  /// Simpan template + ganti seluruh isinya.
  Future<void> saveTemplate(
    WorkoutTemplatesCompanion template,
    List<WorkoutTemplateItemsCompanion> items,
  ) => transaction(() async {
    await into(workoutTemplates).insertOnConflictUpdate(template);
    final id = template.id.value;
    await (delete(
      workoutTemplateItems,
    )..where((t) => t.templateId.equals(id))).go();
    await batch((b) => b.insertAll(workoutTemplateItems, items));
  });

  Future<void> deleteTemplate(String id) =>
      (delete(workoutTemplates)..where((t) => t.id.equals(id))).go();
}
