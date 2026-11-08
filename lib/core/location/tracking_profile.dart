import 'package:virya/core/constants/enums.dart';

/// Sport-specific tuning for the telemetry pipeline. All thresholds live here.
class TrackingProfile {
  /// Fixes with worse horizontal accuracy are dropped.
  final double maxAccuracyM;

  /// Faster implied movement between fixes is treated as a GPS jump.
  final double maxPlausibleSpeedMps;

  /// Kalman process noise (m/s).
  final double kalmanProcessNoiseMps;

  /// Auto-pause when speed stays below this for [autoPauseDelay].
  final double autoPauseSpeedMps;
  final Duration autoPauseDelay;

  /// Auto-resume when speed stays at/above the threshold for [autoResumeDelay].
  final Duration autoResumeDelay;

  const TrackingProfile({
    this.maxAccuracyM = 18,
    required this.maxPlausibleSpeedMps,
    required this.kalmanProcessNoiseMps,
    required this.autoPauseSpeedMps,
    this.autoPauseDelay = const Duration(seconds: 4),
    this.autoResumeDelay = const Duration(seconds: 2),
  });

  factory TrackingProfile.forSport(SportType sport) {
    if (sport.isCycling) {
      return const TrackingProfile(
        maxPlausibleSpeedMps: 30, // 108 km/h descent ceiling
        kalmanProcessNoiseMps: 4,
        autoPauseSpeedMps: 1.0,
      );
    }
    if (sport.isRunning) {
      return const TrackingProfile(
        maxPlausibleSpeedMps: 12,
        kalmanProcessNoiseMps: 2,
        autoPauseSpeedMps: 0.5,
      );
    }
    // hiking / walking
    return const TrackingProfile(
      maxPlausibleSpeedMps: 8,
      kalmanProcessNoiseMps: 1.5,
      autoPauseSpeedMps: 0.3,
      autoPauseDelay: Duration(seconds: 6),
    );
  }
}
