import 'dart:collection';
import 'dart:math' as math;

import 'package:stravo/core/constants/enums.dart';

/// Where the phone sits; changes how much road vibration reaches it.
enum PhoneMount {
  handlebar,
  pocket;

  static PhoneMount parse(String? v) =>
      v == 'pocket' ? PhoneMount.pocket : PhoneMount.handlebar;
}

/// All surface-classification tuning in one place.
///
/// Input is the per-second RMS of gravity-free acceleration (m/s^2). It is
/// normalised to a "handlebar at 6 m/s (~22 km/h), calibration 1.0" reference:
///
///   normalised = rms / (calibration * mountFactor * speedFactor)
///   speedFactor = clamp((speed / 6 m/s) ^ 0.5, 0.6, 1.6)
///
/// Vibration energy grows roughly with the square root of speed on the same
/// surface; a pocket/body mount damps it to ~60 % of a rigid bar mount.
/// Bands on the normalised value (handlebar reference):
///
///   < 1.5  asphalt        smooth tarmac, little buzz
///   < 2.9  smoothGravel   packed hardpack / fine gravel
///   < 4.2  dirt           soil, singletrack, loose but not chattery
///   >= 4.2 roughGravel    makadam, washboard, chunky gravel
///
/// Cobblestone is not separable by RMS alone (needs spectral periodicity), so
/// it is never emitted. Below [minSpeedMps] or for non-cycling sports
/// (foot-strike dominates the signal) the result is [SurfaceType.unknown].
class SurfaceThresholds {
  SurfaceThresholds._();

  static const double refSpeedMps = 6.0;
  static const double speedExponent = 0.5;
  static const double minSpeedFactor = 0.6;
  static const double maxSpeedFactor = 1.6;
  static const double minSpeedMps = 1.5;

  static const Map<PhoneMount, double> mountFactor = {
    PhoneMount.handlebar: 1.0,
    PhoneMount.pocket: 0.6,
  };

  static const double asphaltMax = 1.5;
  static const double smoothGravelMax = 2.9;
  static const double dirtMax = 4.2;

  /// Majority vote window (seconds) for the displayed surface.
  static const int smoothingWindow = 5;
}

class SurfaceClassifier {
  final PhoneMount mount;

  /// User calibration (`vibration_calibration` setting); >1 = phone/bike
  /// transmits more vibration than reference.
  final double calibration;
  final bool enabled;

  final Queue<SurfaceType> _recent = Queue();
  SurfaceType _current = SurfaceType.unknown;

  SurfaceClassifier({
    this.mount = PhoneMount.handlebar,
    double calibration = 1.0,
    this.enabled = true,
  }) : calibration = calibration > 0 ? calibration : 1.0;

  SurfaceType get current => _current;

  double normalise(double rms, double speedMps) {
    final sf = math
        .pow(speedMps / SurfaceThresholds.refSpeedMps,
            SurfaceThresholds.speedExponent)
        .toDouble()
        .clamp(SurfaceThresholds.minSpeedFactor,
            SurfaceThresholds.maxSpeedFactor);
    final mf = SurfaceThresholds.mountFactor[mount]!;
    return rms / (calibration * mf * sf);
  }

  /// Single-second classification without smoothing.
  SurfaceType classifyInstant(double rms, double speedMps) {
    if (!enabled || speedMps < SurfaceThresholds.minSpeedMps || rms <= 0) {
      return SurfaceType.unknown;
    }
    final n = normalise(rms, speedMps);
    if (n < SurfaceThresholds.asphaltMax) return SurfaceType.asphalt;
    if (n < SurfaceThresholds.smoothGravelMax) return SurfaceType.smoothGravel;
    if (n < SurfaceThresholds.dirtMax) return SurfaceType.dirt;
    return SurfaceType.roughGravel;
  }

  /// Feeds one second; returns the majority surface of the recent window.
  /// While stopped the last moving surface is kept.
  SurfaceType update(double rms, double speedMps) {
    final instant = classifyInstant(rms, speedMps);
    if (instant == SurfaceType.unknown) {
      return enabled ? _current : SurfaceType.unknown;
    }
    _recent.addLast(instant);
    while (_recent.length > SurfaceThresholds.smoothingWindow) {
      _recent.removeFirst();
    }
    final counts = <SurfaceType, int>{};
    for (final s in _recent) {
      counts[s] = (counts[s] ?? 0) + 1;
    }
    var best = instant;
    var bestCount = 0;
    for (final e in counts.entries) {
      // Ties prefer the currently shown surface (less flicker).
      if (e.value > bestCount || (e.value == bestCount && e.key == _current)) {
        best = e.key;
        bestCount = e.value;
      }
    }
    _current = best;
    return _current;
  }

  void reset() {
    _recent.clear();
    _current = SurfaceType.unknown;
  }
}
