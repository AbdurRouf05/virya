import 'package:virya/core/location/geo_math.dart';

/// Fuses barometric and GNSS altitude and accumulates gain/loss with
/// hysteresis so sensor noise does not inflate climbing.
///
/// * Barometer available: relative altitude from pressure (low noise), with an
///   offset slowly pulled towards GNSS so the absolute level stays sane.
/// * No barometer: exponentially smoothed GNSS altitude.
class ElevationFilter {
  /// Gain/loss is only counted once altitude moved this far from the anchor.
  final double baroHysteresisM;
  final double gnssHysteresisM;

  /// EMA factors per update (~1 Hz).
  final double gnssAlpha;
  final double baroAlpha;
  final double offsetAlpha;

  double? _smoothed;
  double? _anchor;
  double? _baroOffset;
  bool _usingBaro = false;

  double gain = 0;
  double loss = 0;

  ElevationFilter({
    this.baroHysteresisM = 2.0,
    this.gnssHysteresisM = 5.0,
    this.gnssAlpha = 0.15,
    this.baroAlpha = 0.5,
    this.offsetAlpha = 0.01,
  });

  double? get altitude => _smoothed;
  bool get usingBarometer => _usingBaro;

  void reset() {
    _smoothed = _anchor = _baroOffset = null;
    _usingBaro = false;
    gain = loss = 0;
  }

  /// Feed one update. [pressureHPa] is null when no barometer is available.
  /// With [countTotals] false (paused) altitude is tracked but not totalled.
  double? update({
    double? gnssAltitude,
    double? pressureHPa,
    bool countTotals = true,
  }) {
    double? target;
    if (pressureHPa != null && pressureHPa > 300) {
      final baroAlt = GeoMath.pressureAltitude(pressureHPa);
      if (_baroOffset == null) {
        _baroOffset = (gnssAltitude ?? _smoothed ?? baroAlt) - baroAlt;
      } else if (gnssAltitude != null) {
        final desired = gnssAltitude - baroAlt;
        _baroOffset = _baroOffset! + offsetAlpha * (desired - _baroOffset!);
      }
      target = baroAlt + _baroOffset!;
      if (!_usingBaro && _smoothed != null) {
        // Switching source: re-anchor to avoid a phantom step.
        _anchor = target;
        _smoothed = target;
      }
      _usingBaro = true;
    } else if (gnssAltitude != null) {
      target = gnssAltitude;
      _usingBaro = false;
    }
    if (target == null) return _smoothed;

    final alpha = _usingBaro ? baroAlpha : gnssAlpha;
    final prev = _smoothed;
    _smoothed = prev == null ? target : prev + alpha * (target - prev);
    _anchor ??= _smoothed;

    final h = _usingBaro ? baroHysteresisM : gnssHysteresisM;
    final diff = _smoothed! - _anchor!;
    if (diff >= h) {
      if (countTotals) gain += diff;
      _anchor = _smoothed;
    } else if (diff <= -h) {
      if (countTotals) loss += -diff;
      _anchor = _smoothed;
    }
    return _smoothed;
  }
}
