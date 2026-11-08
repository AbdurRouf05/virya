import 'package:virya/core/location/geo_math.dart';
import 'package:virya/core/location/location_fix.dart';

enum FixRejectReason { inaccurate, duplicate, teleport }

/// Accuracy gate + speed-plausibility (teleport) filter.
///
/// After [maxConsecutiveRejects] teleport rejections in a row the gate assumes
/// its reference was the outlier and re-anchors on the newest fix.
class FixGate {
  final double maxAccuracyM;
  final double maxPlausibleSpeedMps;
  final int maxConsecutiveRejects;

  LocationFix? _last;
  int _teleportRejects = 0;

  FixGate({
    required this.maxAccuracyM,
    required this.maxPlausibleSpeedMps,
    this.maxConsecutiveRejects = 5,
  });

  LocationFix? get lastAccepted => _last;

  void reset() {
    _last = null;
    _teleportRejects = 0;
  }

  /// Returns null if the fix is accepted, otherwise why it was rejected.
  FixRejectReason? check(LocationFix fix) {
    if (fix.accuracy.isNaN || fix.accuracy > maxAccuracyM) {
      return FixRejectReason.inaccurate;
    }
    final last = _last;
    if (last == null) {
      _last = fix;
      return null;
    }
    final dt = fix.time.difference(last.time).inMilliseconds / 1000.0;
    if (dt <= 0) return FixRejectReason.duplicate;

    final d = GeoMath.haversine(last.lat, last.lon, fix.lat, fix.lon);
    // The combined accuracy radius is slack before judging speed.
    final slack = fix.accuracy + last.accuracy;
    final implied = (d - slack).clamp(0.0, double.infinity) / dt;
    if (implied > maxPlausibleSpeedMps &&
        _teleportRejects < maxConsecutiveRejects) {
      _teleportRejects++;
      return FixRejectReason.teleport;
    }
    _teleportRejects = 0;
    _last = fix;
    return null;
  }
}
