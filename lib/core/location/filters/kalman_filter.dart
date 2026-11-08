import 'dart:math' as math;

import 'package:virya/core/location/geo_math.dart';

/// Constant-position Kalman filter for lat/lon with accuracy-weighted gain.
///
/// [processNoiseMps] is how fast (m/s) the true position is expected to
/// drift between fixes; higher = less smoothing, less lag.
class LatLonKalmanFilter {
  final double processNoiseMps;

  double? _lat;
  double? _lon;
  DateTime? _time;
  double _variance = -1; // m^2, negative = uninitialised

  LatLonKalmanFilter({this.processNoiseMps = 3.0});

  bool get isInitialised => _variance >= 0;
  double? get lat => _lat;
  double? get lon => _lon;

  /// Current 1-sigma error estimate in meters.
  double get errorM => _variance < 0 ? double.infinity : math.sqrt(_variance);

  void reset() {
    _lat = _lon = null;
    _time = null;
    _variance = -1;
  }

  /// Feed a measurement; returns the smoothed (lat, lon).
  (double, double) process(
    double lat,
    double lon,
    double accuracyM,
    DateTime time,
  ) {
    final acc = accuracyM < 1 ? 1.0 : accuracyM;
    if (_variance < 0) {
      _lat = lat;
      _lon = lon;
      _time = time;
      _variance = acc * acc;
      return (lat, lon);
    }
    final dt = time.difference(_time!).inMilliseconds / 1000.0;
    if (dt > 0) {
      _variance += dt * processNoiseMps * processNoiseMps;
      _time = time;
    }
    final k = _variance / (_variance + acc * acc);
    _lat = _lat! + k * (lat - _lat!);
    _lon = _lon! + k * (lon - _lon!);
    _variance = (1 - k) * _variance;
    return (_lat!, _lon!);
  }

  /// Distance between the current estimate and a raw point (diagnostics).
  double distanceTo(double lat, double lon) =>
      _lat == null ? 0 : GeoMath.haversine(_lat!, _lon!, lat, lon);
}
