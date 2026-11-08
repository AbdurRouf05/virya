import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/gym/application/gym_session_state.dart';
import 'package:virya/features/gym/application/gym_session_store.dart';
import 'package:virya/features/gym/domain/gym_models.dart';
import 'package:virya/features/gym/domain/session_draft.dart';

export 'package:virya/features/gym/application/gym_session_state.dart';

/// Sesi gym yang sedang berjalan. `null` = tidak ada sesi.
///
/// Setiap perubahan langsung ditulis ke DB (aktivitas `inProgress` +
/// `workout_sets`), jadi [resume] bisa memulihkan sesi setelah aplikasi
/// ditutup paksa — sama seperti pemulihan rekaman GPS.
class GymSessionController extends StateNotifier<GymSessionState?> {
  final AppDatabase db;
  final GymSessionStore _store;
  GymSessionController(this.db)
    : _store = GymSessionStore(db.gymDao),
      super(null);

  static const _uuid = Uuid();
  static const defaultRestS = 90;

  /// Muat sesi berjalan dari DB bila ada. `true` bila ada sesi.
  Future<bool> resume() async {
    if (state != null) return true;
    final act = await db.gymDao.activeSession();
    if (act == null) return false;
    final lib = await _store.library();
    final ex = await _store.load(act.id, lib);
    state = GymSessionState(
      activityId: act.id,
      title: act.title,
      start: act.startTime,
      exercises: ex,
    );
    return true;
  }

  /// Mulai sesi baru, kosong atau dari [template].
  Future<void> start({GymTemplate? template}) async {
    if (await resume()) return;
    final now = DateTime.now();
    final id = _uuid.v4();
    final title = gymSessionTitle(now, templateName: template?.name);
    await db.gymDao.startSession(id: id, title: title, start: now.toUtc());
    state = GymSessionState(activityId: id, title: title, start: now);
    if (template == null) return;
    final lib = await _store.library();
    for (final it in template.items) {
      final info = lib[it.exerciseId];
      if (info == null) continue;
      await addExercise(info, sets: it.targetSets, reps: it.targetReps);
    }
  }

  Future<void> rename(String title) async {
    final s = state;
    if (s == null || title.trim().isEmpty) return;
    state = s.copyWith(title: title.trim());
    await db.gymDao.renameSession(s.activityId, title.trim());
  }

  Future<void> addExercise(ExerciseInfo info, {int? sets, int? reps}) async {
    final s = state;
    if (s == null) return;
    final prev = await _store.previous(info.id, s.activityId);
    final n = sets ?? (prev.isEmpty ? 1 : prev.length);
    final ex = DraftExercise(
      exercise: info,
      previous: prev,
      sets: [for (var i = 0; i < n; i++) _newSet(prev, i, reps)],
    );
    final list = [...state!.exercises, ex];
    state = state!.copyWith(exercises: list);
    await _store.writeExercise(s.activityId, list.length - 1, ex);
  }

  DraftSet _newSet(List<(double, int)> prev, int i, int? reps) {
    final p = i < prev.length ? prev[i] : (prev.isEmpty ? null : prev.last);
    return DraftSet(
      id: _uuid.v4(),
      hintWeightKg: p?.$1,
      hintReps: p?.$2 ?? reps,
    );
  }

  void removeExercise(int ex) {
    final s = state;
    if (s == null) return;
    final removed = s.exercises[ex];
    final list = [...s.exercises]..removeAt(ex);
    state = s.copyWith(exercises: list);
    for (final set in removed.sets) {
      _store.deleteSet(set.id);
    }
    for (var i = ex; i < list.length; i++) {
      _store.writeExercise(s.activityId, i, list[i]);
    }
  }

  void addSet(int ex) {
    final s = state;
    if (s == null) return;
    final e = s.exercises[ex];
    final last = e.sets.isEmpty ? null : e.sets.last;
    final next = _newSet(e.previous, e.sets.length, last?.effectiveReps);
    final seeded = last == null
        ? next
        : DraftSet(
            id: next.id,
            hintWeightKg: next.hintWeightKg ?? last.effectiveWeight,
            hintReps: next.hintReps ?? last.effectiveReps,
          );
    _replace(ex, e.withSets([...e.sets, seeded]));
  }

  void removeSet(int ex, int set) {
    final s = state;
    if (s == null) return;
    final e = s.exercises[ex];
    _store.deleteSet(e.sets[set].id);
    final sets = [...e.sets]..removeAt(set);
    if (sets.isEmpty) return removeExercise(ex);
    _replace(ex, e.withSets(sets));
  }

  void updateSet(int ex, int set, DraftSet Function(DraftSet) f) {
    final e = state?.exercises[ex];
    if (e == null) return;
    final sets = [...e.sets];
    sets[set] = f(sets[set]);
    _replace(ex, e.withSets(sets));
  }

  /// Centang / batal centang. Saat dicentang, isian kosong diisi patokan
  /// dan timer istirahat dimulai.
  void toggleDone(int ex, int set) {
    final e = state?.exercises[ex];
    if (e == null) return;
    final cur = e.sets[set];
    if (cur.done) {
      updateSet(ex, set, (d) => d.copyWith(completedAt: () => null));
      return;
    }
    updateSet(
      ex,
      set,
      (d) => d.copyWith(
        weightKg: () => d.effectiveWeight,
        reps: () => d.effectiveReps,
        completedAt: DateTime.now,
      ),
    );
    final nextLabel = set + 1 < e.sets.length
        ? 'SET ${set + 2} BERIKUTNYA'
        : 'GERAKAN BERIKUTNYA';
    startRest(defaultRestS, label: nextLabel);
  }

  void startRest(int seconds, {String? label}) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(
      restEndsAt: () => DateTime.now().add(Duration(seconds: seconds)),
      restTotalS: seconds,
      restLabel: () => label,
    );
  }

  /// −15 / +15 detik.
  void adjustRest(int delta) {
    final s = state;
    final end = s?.restEndsAt;
    if (s == null || end == null) return;
    final next = end.add(Duration(seconds: delta));
    if (!next.isAfter(DateTime.now())) return skipRest();
    state = s.copyWith(
      restEndsAt: () => next,
      restTotalS: (s.restTotalS + delta).clamp(1, 3600),
    );
  }

  void skipRest() => state = state?.copyWith(restEndsAt: () => null);

  void _replace(int ex, DraftExercise e) {
    final s = state!;
    final list = [...s.exercises];
    list[ex] = e;
    state = s.copyWith(exercises: list);
    _store.writeExercise(s.activityId, ex, e);
  }

  /// Simpan sesi (set yang belum dicentang dibuang). Mengembalikan id.
  Future<String?> finish() async {
    final s = state;
    if (s == null) return null;
    await _store.flush();
    await db.gymDao.finishSession(s.activityId, end: DateTime.now().toUtc());
    state = null;
    return s.activityId;
  }

  Future<void> discard() async {
    final s = state;
    if (s == null) return;
    await _store.flush();
    await db.gymDao.discardSession(s.activityId);
    state = null;
  }
}

final gymSessionProvider =
    StateNotifierProvider<GymSessionController, GymSessionState?>(
      (ref) => GymSessionController(ref.watch(databaseProvider)),
    );
