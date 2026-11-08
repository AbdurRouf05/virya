import 'dart:math' as math;

const double earthRadiusM = 6371008.8;

double _rad(double d) => d * math.pi / 180.0;

/// Great-circle distance in meters.
double haversineM(double lat1, double lon1, double lat2, double lon2) {
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final s1 = math.sin(dLat / 2);
  final s2 = math.sin(dLon / 2);
  final a = s1 * s1 + math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * s2 * s2;
  return 2 * earthRadiusM * math.asin(math.min(1.0, math.sqrt(a)));
}

/// Equirectangular projection to local meters around an origin.
/// Accurate to well under 0.5% for spans below ~100 km.
class LocalProjector {
  final double lat0, lon0;
  final double _kx;
  static const double _ky = earthRadiusM * math.pi / 180.0;

  LocalProjector(this.lat0, this.lon0)
      : _kx = earthRadiusM * math.pi / 180.0 * math.cos(_rad(lat0));

  double x(double lon) => (lon - lon0) * _kx;
  double y(double lat) => (lat - lat0) * _ky;
}

double clampD(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

/// Linear interpolation of [values] at position [x] on the non-decreasing
/// axis [axis]. Clamps outside the range.
double interpOn(List<double> axis, List<double> values, double x) {
  final n = axis.length;
  if (n == 0) return 0;
  if (x <= axis[0]) return values[0];
  if (x >= axis[n - 1]) return values[n - 1];
  var lo = 0, hi = n - 1;
  while (hi - lo > 1) {
    final mid = (lo + hi) >> 1;
    if (axis[mid] < x) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  final a0 = axis[lo], a1 = axis[hi];
  if (a1 <= a0) return values[hi];
  final f = (x - a0) / (a1 - a0);
  return values[lo] + (values[hi] - values[lo]) * f;
}
