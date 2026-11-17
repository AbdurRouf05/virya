import 'package:drift/drift.dart';
import 'package:virya/core/database/app_database.dart';

/// Library gerakan bawaan. ID tetap (`ex_...`) agar stabil antar perangkat
/// dan backup. Menambah gerakan baru di sini aman: seeding memakai
/// `insertOrIgnore`.
const builtInExercises = <(String id, String name, String muscle, String eq)>[
  // Dada
  ('ex_bench_press', 'Bench Press', 'dada', 'barbel'),
  ('ex_incline_bench', 'Incline Bench Press', 'dada', 'barbel'),
  ('ex_db_bench', 'Dumbbell Bench Press', 'dada', 'dumbel'),
  ('ex_incline_db_press', 'Incline Dumbbell Press', 'dada', 'dumbel'),
  ('ex_chest_fly', 'Chest Fly', 'dada', 'dumbel'),
  ('ex_cable_crossover', 'Cable Crossover', 'dada', 'kabel'),
  ('ex_chest_press_machine', 'Chest Press Mesin', 'dada', 'mesin'),
  ('ex_push_up', 'Push-up', 'dada', 'badan'),
  ('ex_dips', 'Dips', 'dada', 'badan'),
  // Punggung
  ('ex_deadlift', 'Deadlift', 'punggung', 'barbel'),
  ('ex_pull_up', 'Pull-up', 'punggung', 'badan'),
  ('ex_chin_up', 'Chin-up', 'punggung', 'badan'),
  ('ex_lat_pulldown', 'Lat Pulldown', 'punggung', 'kabel'),
  ('ex_barbell_row', 'Barbell Row', 'punggung', 'barbel'),
  ('ex_db_row', 'Dumbbell Row', 'punggung', 'dumbel'),
  ('ex_seated_cable_row', 'Seated Cable Row', 'punggung', 'kabel'),
  ('ex_face_pull', 'Face Pull', 'punggung', 'kabel'),
  // Kaki
  ('ex_squat', 'Squat', 'kaki', 'barbel'),
  ('ex_front_squat', 'Front Squat', 'kaki', 'barbel'),
  ('ex_leg_press', 'Leg Press', 'kaki', 'mesin'),
  ('ex_rdl', 'Romanian Deadlift', 'kaki', 'barbel'),
  ('ex_lunge', 'Lunge', 'kaki', 'dumbel'),
  ('ex_bulgarian_split_squat', 'Bulgarian Split Squat', 'kaki', 'dumbel'),
  ('ex_leg_extension', 'Leg Extension', 'kaki', 'mesin'),
  ('ex_leg_curl', 'Leg Curl', 'kaki', 'mesin'),
  ('ex_calf_raise', 'Calf Raise', 'kaki', 'mesin'),
  ('ex_hip_thrust', 'Hip Thrust', 'kaki', 'barbel'),
  // Bahu
  ('ex_ohp', 'Overhead Press', 'bahu', 'barbel'),
  ('ex_db_shoulder_press', 'Dumbbell Shoulder Press', 'bahu', 'dumbel'),
  ('ex_lateral_raise', 'Lateral Raise', 'bahu', 'dumbel'),
  ('ex_front_raise', 'Front Raise', 'bahu', 'dumbel'),
  ('ex_rear_delt_fly', 'Rear Delt Fly', 'bahu', 'dumbel'),
  ('ex_shrug', 'Shrug', 'bahu', 'dumbel'),
  // Lengan
  ('ex_barbell_curl', 'Barbell Curl', 'lengan', 'barbel'),
  ('ex_db_curl', 'Dumbbell Curl', 'lengan', 'dumbel'),
  ('ex_hammer_curl', 'Hammer Curl', 'lengan', 'dumbel'),
  ('ex_triceps_pushdown', 'Triceps Pushdown', 'lengan', 'kabel'),
  ('ex_skull_crusher', 'Skull Crusher', 'lengan', 'barbel'),
  ('ex_overhead_triceps', 'Overhead Triceps Extension', 'lengan', 'dumbel'),
  // Core
  ('ex_plank', 'Plank', 'core', 'badan'),
  ('ex_crunch', 'Crunch', 'core', 'badan'),
  ('ex_hanging_leg_raise', 'Hanging Leg Raise', 'core', 'badan'),
  ('ex_russian_twist', 'Russian Twist', 'core', 'badan'),
  ('ex_ab_wheel', 'Ab Wheel Rollout', 'core', 'lainnya'),
];

/// Isi library bawaan (idempoten). Dipanggil saat buat DB dan migrasi.
Future<void> seedExerciseLibrary(AppDatabase db) async {
  final now = DateTime.now().toUtc();
  await db.batch((b) {
    b.insertAll(db.exercises, [
      for (final (id, name, muscle, eq) in builtInExercises)
        ExercisesCompanion.insert(
          id: id,
          name: name,
          muscleGroup: muscle,
          equipment: Value(eq),
          createdAt: now,
        ),
    ], mode: InsertMode.insertOrIgnore);
  });
}
