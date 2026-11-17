import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/daos/gym_dao.dart';
import 'package:virya/features/gym/domain/gym_models.dart';

/// Aksi tulis gym di luar sesi berjalan: gerakan kustom & template.
class GymRepository {
  final GymDao dao;
  GymRepository(this.dao);

  static const _uuid = Uuid();

  Future<ExerciseInfo> createExercise({
    required String name,
    required MuscleGroup muscle,
    required Equipment equipment,
  }) async {
    final e = ExerciseInfo(
      id: _uuid.v4(),
      name: name.trim(),
      muscle: muscle,
      equipment: equipment,
      isCustom: true,
    );
    await dao.insertExercise(
      ExercisesCompanion.insert(
        id: e.id,
        name: e.name,
        muscleGroup: muscle.name,
        equipment: Value(equipment.name),
        isCustom: const Value(true),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    return e;
  }

  /// Simpan (baru bila [id] null). Mengembalikan id template.
  Future<String> saveTemplate({
    String? id,
    required String name,
    String? note,
    required List<TemplateItem> items,
  }) async {
    final tid = id ?? _uuid.v4();
    final now = DateTime.now().toUtc();
    await dao.saveTemplate(
      WorkoutTemplatesCompanion.insert(
        id: tid,
        name: name.trim(),
        note: Value(note?.trim().isEmpty ?? true ? null : note!.trim()),
        createdAt: now,
        updatedAt: now,
      ),
      [
        for (final (i, it) in items.indexed)
          WorkoutTemplateItemsCompanion.insert(
            id: _uuid.v4(),
            templateId: tid,
            exerciseId: it.exerciseId,
            itemOrder: i,
            targetSets: Value(it.targetSets),
            targetReps: Value(it.targetReps),
          ),
      ],
    );
    return tid;
  }

  Future<void> deleteTemplate(String id) => dao.deleteTemplate(id);

  /// Template dari sesi selesai: urutan gerakan, jumlah set kerja, reps
  /// terbanyak.
  Future<String> templateFromSession(String activityId, String name) async {
    final sets = await dao.setsFor(activityId);
    final order = <String>[];
    final count = <String, int>{};
    final reps = <String, int>{};
    for (final s in sets) {
      if (!order.contains(s.exerciseId)) order.add(s.exerciseId);
      if (s.isWarmup) continue;
      count[s.exerciseId] = (count[s.exerciseId] ?? 0) + 1;
      final r = s.reps ?? 0;
      if (r > (reps[s.exerciseId] ?? 0)) reps[s.exerciseId] = r;
    }
    return saveTemplate(
      name: name,
      items: [
        for (final e in order)
          TemplateItem(
            exerciseId: e,
            targetSets: (count[e] ?? 1).clamp(1, 20),
            targetReps: (reps[e] ?? 8).clamp(1, 100),
          ),
      ],
    );
  }
}

final gymRepositoryProvider = Provider<GymRepository>(
  (ref) => GymRepository(ref.watch(gymDaoProvider)),
);
