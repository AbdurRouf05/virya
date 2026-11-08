import 'dart:math' as math;

/// Small geodesy helpers (WGS84 sphere approximation).
class GeoMath {
  GeoMath._();

  static const double earthRadiusM = 6371008.8;

  static double _rad(double deg) => deg * math.pi / 180.0;
  static double _deg(double rad) => rad * 180.0 / math.pi;

  /// Great-circle distance in meters.
  static double haversine(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * earthRadiusM * math.asin(math.min(1.0, math.sqrt(a)));
  }

  /// Initial bearing from point 1 to point 2, degrees 0..360.
  static double bearing(double lat1, double lon1, double lat2, double lon2) {
    final p1 = _rad(lat1), p2 = _rad(lat2);
    final dl = _rad(lon2 - lon1);
    final y = math.sin(dl) * math.cos(p2);
    final x = math.cos(p1) * math.sin(p2) -
        math.sin(p1) * math.cos(p2) * math.cos(dl);
    return (_deg(math.atan2(y, x)) + 360) % 360;
  }

  /// Meters per degree of latitude / longitude at [lat].
  static double metersPerDegLat() => earthRadiusM * math.pi / 180.0;
  static double metersPerDegLon(double lat) =>
      metersPerDegLat() * math.cos(_rad(lat));

  /// Barometric altitude (m) from pressure in hPa (ISA standard atmosphere).
  static double pressureAltitude(double hPa, {double seaLevelHPa = 1013.25}) =>
      44330.0 * (1 - math.pow(hPa / seaLevelHPa, 0.1903).toDouble());
}
