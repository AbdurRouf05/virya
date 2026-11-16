import 'dart:math' as math;

import 'package:virya/core/analytics/geo.dart';
import 'package:virya/features/routes/domain/route_models.dart';

/// Faktor jalan berkelok: rute jalan ≈ 1,25 × keliling lingkaran ideal.
const double roadWindingFactor = 1.25;

/// Toleransi jarak hasil terhadap target (±10%).
const double targetTolerance = 0.10;

double _rad(double d) => d * math.pi / 180;
double _deg(double r) => r * 180 / math.pi;

/// Titik sejauh [distM] dari [from] ke arah [bearingDeg] (0 = utara).
LatLon destinationPoint(LatLon from, double bearingDeg, double distM) {
  final d = distM / earthRadiusM;
  final b = _rad(bearingDeg);
  final lat1 = _rad(from.$1), lon1 = _rad(from.$2);
  final lat2 = math.asin(math.sin(lat1) * math.cos(d) +
      math.cos(lat1) * math.sin(d) * math.cos(b));
  final lon2 = lon1 +
      math.atan2(math.sin(b) * math.sin(d) * math.cos(lat1),
          math.cos(d) - math.sin(lat1) * math.sin(lat2));
  return (_deg(lat2), ((_deg(lon2) + 540) % 360) - 180);
}

/// Arah (derajat 0..360) dari [a] ke [b].
double bearingBetween(LatLon a, LatLon b) {
  final lat1 = _rad(a.$1), lat2 = _rad(b.$1);
  final dLon = _rad(b.$2 - a.$2);
  final y = math.sin(dLon) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  return (_deg(math.atan2(y, x)) + 360) % 360;
}

/// Jari-jari awal lingkaran untuk keliling sepanjang [targetM].
double initialLoopRadius(double targetM) =>
    targetM / (2 * math.pi) / roadWindingFactor;

/// Jari-jari baru setelah percobaan menghasilkan [actualM].
double rescaleRadius(double radiusM, double targetM, double actualM) {
  if (actualM <= 0) return radiusM;
  return radiusM * (targetM / actualM).clamp(0.5, 2.0);
}

bool withinTarget(double actualM, double targetM,
        {double tolerance = targetTolerance}) =>
    targetM > 0 && (actualM / targetM - 1).abs() <= tolerance;

/// Titik bantu keliling: [count] titik di lingkaran berjari-jari [radiusM]
/// yang melewati [start]; pusatnya di arah [bearingDeg]. Urutan searah jarum
/// jam, tanpa titik mulai/akhir.
List<LatLon> loopWaypoints(
  LatLon start,
  double radiusM,
  double bearingDeg, {
  int count = 3,
  math.Random? jitter,
}) {
  final center = destinationPoint(start, bearingDeg, radiusM);
  final back = (bearingDeg + 180) % 360; // arah pusat → mulai
  final step = 360 / (count + 1);
  return [
    for (var k = 1; k <= count; k++)
      destinationPoint(
        center,
        back + k * step + (jitter == null ? 0 : (jitter.nextDouble() - .5) * step * .4),
        radiusM * (jitter == null ? 1 : .85 + jitter.nextDouble() * .3),
      ),
  ];
}

/// Tujuan otomatis pergi-pulang: separuh target, dikoreksi kelokan jalan.
LatLon outAndBackDestination(LatLon start, double targetM, double bearingDeg) =>
    destinationPoint(start, bearingDeg, targetM / 2 / roadWindingFactor);

/// Arah mata angin dalam bahasa Indonesia untuk [bearingDeg].
String compassWord(double bearingDeg) {
  const words = [
    'utara', 'timur laut', 'timur', 'tenggara',
    'selatan', 'barat daya', 'barat', 'barat laut',
  ];
  return words[(((bearingDeg % 360) + 22.5) ~/ 45) % 8];
}

/// Nama bawaan, mis. "Keliling utara 40 km".
String defaultRouteName(RouteShape shape, LatLon start, List<LatLon> pts,
    double distanceM) {
  final km = (distanceM / 1000).round();
  if (pts.isEmpty || shape == RouteShape.manual) return 'Rute $km km';
  var lat = 0.0, lon = 0.0;
  for (final p in pts) {
    lat += p.$1;
    lon += p.$2;
  }
  final c = (lat / pts.length, lon / pts.length);
  final dir = haversineM(start.$1, start.$2, c.$1, c.$2) < 30
      ? ''
      : ' ${compassWord(bearingBetween(start, c))}';
  return '${shape.label}$dir $km km';
}
