import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:virya/core/database/daos/activities_dao.dart';
import 'package:virya/core/database/daos/body_dao.dart';
import 'package:virya/core/database/daos/focus_dao.dart';
import 'package:virya/core/database/daos/gears_dao.dart';
import 'package:virya/core/database/daos/gym_dao.dart';
import 'package:virya/core/database/daos/segments_dao.dart';
import 'package:virya/core/database/daos/tasks_dao.dart';
import 'package:virya/core/database/daos/track_points_dao.dart';
import 'package:virya/core/database/daos/waypoint_photos_dao.dart';
import 'package:virya/core/database/tables/activities_table.dart';
import 'package:virya/core/database/seed/exercise_library.dart';
import 'package:virya/core/database/tables/body_tables.dart';
import 'package:virya/core/database/tables/focus_tables.dart';
import 'package:virya/core/database/tables/gears_table.dart';
import 'package:virya/core/database/tables/gym_tables.dart';
import 'package:virya/core/database/tables/segments_table.dart';
import 'package:virya/core/database/tables/tasks_table.dart';
import 'package:virya/core/database/tables/track_points_table.dart';
import 'package:virya/core/database/tables/user_profile_table.dart';
import 'package:virya/core/database/tables/waypoint_photos_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Activities,
    TrackPoints,
    WaypointPhotos,
    Gears,
    UserProfiles,
    Segments,
    SegmentEfforts,
    AppSettings,
    Exercises,
    WorkoutSets,
    WorkoutTemplates,
    WorkoutTemplateItems,
    Tasks,
    AppLimits,
    AppUsageDays,
    BodyCheckins,
    BodyPhotos,
  ],
  daos: [
    ActivitiesDao,
    TrackPointsDao,
    WaypointPhotosDao,
    GearsDao,
    GymDao,
    TasksDao,
    FocusDao,
    BodyDao,
    SegmentsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Konstruktor khusus untuk unit testing dan in-memory database
  AppDatabase.forTesting(super.e);

  /// Factory untuk in-memory SQLite database (sangat cepat untuk unit test)
  factory AppDatabase.memory() {
    return AppDatabase.forTesting(
      NativeDatabase.memory(),
    );
  }

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();

          // Index performa tinggi untuk rute 3D, flyover, dan query realtime
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_trackpoints_activity_seq '
            'ON track_points (activity_id, sequence_idx ASC);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_activities_sport_status '
            'ON activities (sport_type, status);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_activities_status_start '
            'ON activities (status, start_time DESC);',
          );
          await _createGymIndexes();
          await _createTaskIndexes();
          await seedExerciseLibrary(this);
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(activities, activities.relativeEffort);
            await m.addColumn(activities, activities.gritScore);
            await m.addColumn(activities, activities.avgPowerW);
            await m.addColumn(activities, activities.source);
            await m.createTable(segments);
            await m.createTable(segmentEfforts);
            await m.createTable(appSettings);
          }
          if (from < 3) {
            await m.createTable(exercises);
            await m.createTable(workoutSets);
            await m.createTable(workoutTemplates);
            await m.createTable(workoutTemplateItems);
            await _createGymIndexes();
            await seedExerciseLibrary(this);
          }
          if (from < 4) {
            await m.createTable(tasks);
            await _createTaskIndexes();
          }
          if (from < 5) {
            await m.createTable(appLimits);
            await m.createTable(appUsageDays);
          }
          if (from < 6) {
            await m.createTable(bodyCheckins);
            await m.createTable(bodyPhotos);
          }
        },
        beforeOpen: (details) async {
          // Aktifkan Foreign Keys di SQLite
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_activities_status_start '
            'ON activities (status, start_time DESC);',
          );
        },
      );

  Future<void> _createGymIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_workout_sets_activity '
      'ON workout_sets (activity_id, exercise_order, set_index);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_workout_sets_exercise '
      'ON workout_sets (exercise_id);',
    );
  }

  Future<void> _createTaskIndexes() => customStatement(
    'CREATE INDEX IF NOT EXISTS idx_tasks_done_at ON tasks (done_at);',
  );
}

/// Fungsi pembuka koneksi file database lokal di storage internal ponsel
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    // Legacy name kept for backup compatibility (see BackupService.dbFileName).
    final file = File(p.join(dbFolder.path, 'stravo_local.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Riverpod Providers untuk Dependency Injection
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final activitiesDaoProvider = Provider<ActivitiesDao>((ref) {
  return ref.watch(databaseProvider).activitiesDao;
});

final trackPointsDaoProvider = Provider<TrackPointsDao>((ref) {
  return ref.watch(databaseProvider).trackPointsDao;
});

final waypointPhotosDaoProvider = Provider<WaypointPhotosDao>((ref) {
  return ref.watch(databaseProvider).waypointPhotosDao;
});

final gymDaoProvider = Provider<GymDao>((ref) {
  return ref.watch(databaseProvider).gymDao;
});

final tasksDaoProvider = Provider<TasksDao>((ref) {
  return ref.watch(databaseProvider).tasksDao;
});

final focusDaoProvider = Provider<FocusDao>((ref) {
  return ref.watch(databaseProvider).focusDao;
});

final bodyDaoProvider = Provider<BodyDao>((ref) {
  return ref.watch(databaseProvider).bodyDao;
});

final gearsDaoProvider = Provider<GearsDao>((ref) {
  return ref.watch(databaseProvider).gearsDao;
});
/// Typed helpers over the AppSettings key/value table.
extension AppSettingsX on AppDatabase {
  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value),
      );
}
