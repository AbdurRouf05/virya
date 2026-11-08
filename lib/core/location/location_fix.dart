/// One raw position fix from a [LocationSource] (before filtering).
class LocationFix {
  final DateTime time;
  final double lat;
  final double lon;

  /// GNSS altitude (m, ellipsoid or MSL depending on device). Null if unknown.
  final double? altitude;

  /// Horizontal accuracy radius in meters.
  final double accuracy;

  /// Device-reported speed (m/s). Null/negative when not available.
  final double? speed;

  /// Device-reported heading (deg). Null when not available.
  final double? heading;

  /// Optional sensor values (simulated replay or external sensors).
  final int? heartRate;
  final int? cadence;

  const LocationFix({
    required this.time,
    required this.lat,
    required this.lon,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.heartRate,
    this.cadence,
  });

  /// Speed only if the device reported a plausible value.
  double? get validSpeed => (speed != null && speed! >= 0) ? speed : null;
}
