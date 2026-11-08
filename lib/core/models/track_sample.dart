import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/database/app_database.dart';

/// SHARED CONTRACT — one GPS/sensor sample of a recorded or imported activity.
///
/// Every feature (analytics, maps, share cards, video, import/export) consumes
/// activities as `List<TrackSample>` ordered by time. Do not rename fields.
class TrackSample {
  final DateTime time;
  final double lat;
  final double lon;

  /// Altitude in meters (barometer-fused when available). Null if unknown.
  final double? ele;

  /// Instant speed in m/s as reported by GNSS/derived. Null if unknown.
  final double? speedMps;

  final double? accuracyM;
  final int? heartRate;
  final int? cadence;

  /// Estimated surface from vibration analysis.
  final SurfaceType surface;

  /// Raw vibration RMS (m/s^2, gravity-removed) for this second.
  final double vibration;

  /// True when this sample was captured while (auto-)paused.
  final bool paused;

  const TrackSample({
    required this.time,
    required this.lat,
    required this.lon,
    this.ele,
    this.speedMps,
    this.accuracyM,
    this.heartRate,
    this.cadence,
    this.surface = SurfaceType.unknown,
    this.vibration = 0,
    this.paused = false,
  });

  factory TrackSample.fromTrackPoint(TrackPoint p) => TrackSample(
        time: p.timestamp,
        lat: p.latitude,
        lon: p.longitude,
        ele: p.altitudeMeters,
        speedMps: p.speedMps,
        accuracyM: p.accuracyMeters,
        heartRate: p.heartRate,
        cadence: p.cadence,
        surface: SurfaceType.values.firstWhere(
          (s) => s.name == p.surfaceType,
          orElse: () => SurfaceType.unknown,
        ),
        vibration: p.vibrationRaw,
        paused: p.isPaused,
      );

  TrackSample copyWith({double? ele, SurfaceType? surface, bool? paused}) =>
      TrackSample(
        time: time,
        lat: lat,
        lon: lon,
        ele: ele ?? this.ele,
        speedMps: speedMps,
        accuracyM: accuracyM,
        heartRate: heartRate,
        cadence: cadence,
        surface: surface ?? this.surface,
        vibration: vibration,
        paused: paused ?? this.paused,
      );
}
