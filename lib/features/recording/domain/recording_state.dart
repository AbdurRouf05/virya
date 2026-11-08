import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/location/models/telemetry_snapshot.dart';

enum RecordingPhase { idle, recording, paused, saving }

enum GpsStatus { off, searching, weak, good, simulated }

class RecordingState {
  final RecordingPhase phase;
  final SportType sport;
  final String? activityId;
  final LiveTelemetrySnapshot snapshot;

  /// Route so far (downsampled ~5 m) for the live map.
  final List<(double, double)> route;
  final GpsStatus gps;
  final bool simulated;
  final bool imperial;
  final int photoCount;

  /// Last user-facing message (Indonesian), e.g. errors.
  final String? message;

  const RecordingState({
    required this.phase,
    required this.sport,
    required this.snapshot,
    this.activityId,
    this.route = const [],
    this.gps = GpsStatus.off,
    this.simulated = false,
    this.imperial = false,
    this.photoCount = 0,
    this.message,
  });

  factory RecordingState.initial({
    SportType sport = SportType.gravelCycling,
    bool simulated = false,
    bool imperial = false,
  }) =>
      RecordingState(
        phase: RecordingPhase.idle,
        sport: sport,
        snapshot: LiveTelemetrySnapshot.initial(),
        simulated: simulated,
        imperial: imperial,
        gps: simulated ? GpsStatus.simulated : GpsStatus.off,
      );

  bool get isActive =>
      phase == RecordingPhase.recording || phase == RecordingPhase.paused;

  RecordingState copyWith({
    RecordingPhase? phase,
    SportType? sport,
    String? activityId,
    LiveTelemetrySnapshot? snapshot,
    List<(double, double)>? route,
    GpsStatus? gps,
    bool? simulated,
    bool? imperial,
    int? photoCount,
    String? message,
    bool clearMessage = false,
  }) =>
      RecordingState(
        phase: phase ?? this.phase,
        sport: sport ?? this.sport,
        activityId: activityId ?? this.activityId,
        snapshot: snapshot ?? this.snapshot,
        route: route ?? this.route,
        gps: gps ?? this.gps,
        simulated: simulated ?? this.simulated,
        imperial: imperial ?? this.imperial,
        photoCount: photoCount ?? this.photoCount,
        message: clearMessage ? null : (message ?? this.message),
      );
}

/// GNSS quality bucket from horizontal accuracy.
GpsStatus gpsStatusForAccuracy(double accuracyM) {
  if (accuracyM <= 0 || accuracyM.isNaN) return GpsStatus.searching;
  if (accuracyM <= 10) return GpsStatus.good;
  if (accuracyM <= 18) return GpsStatus.weak;
  return GpsStatus.searching;
}
