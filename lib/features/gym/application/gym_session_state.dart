import 'package:virya/features/gym/domain/session_draft.dart';

/// Status sesi gym yang sedang berjalan (milik [GymSessionController]).
class GymSessionState {
  final String activityId;
  final String title;
  final DateTime start;
  final List<DraftExercise> exercises;

  /// Timer istirahat: selesai pada [restEndsAt] (null = tidak berjalan).
  final DateTime? restEndsAt;
  final int restTotalS;

  /// Label set berikutnya untuk bar istirahat, mis. "SET 4 BERIKUTNYA".
  final String? restLabel;

  const GymSessionState({
    required this.activityId,
    required this.title,
    required this.start,
    this.exercises = const [],
    this.restEndsAt,
    this.restTotalS = 90,
    this.restLabel,
  });

  DraftSummary get summary => DraftSummary.of(exercises);

  GymSessionState copyWith({
    String? title,
    List<DraftExercise>? exercises,
    DateTime? Function()? restEndsAt,
    int? restTotalS,
    String? Function()? restLabel,
  }) => GymSessionState(
    activityId: activityId,
    title: title ?? this.title,
    start: start,
    exercises: exercises ?? this.exercises,
    restEndsAt: restEndsAt == null ? this.restEndsAt : restEndsAt(),
    restTotalS: restTotalS ?? this.restTotalS,
    restLabel: restLabel == null ? this.restLabel : restLabel(),
  );
}
