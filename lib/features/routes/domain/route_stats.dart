import 'dart:math' as math;

import 'package:virya/features/routes/domain/route_models.dart';

/// Profil ketinggian rute yang sudah dihaluskan untuk grafik.
class RouteProfile {
  final List<double> distanceM;
  final List<double> ele;
  final List<double> gradePct;
  const RouteProfile(this.distanceM, this.ele, this.gradePct);

  bool get hasData => ele.length >= 2;
}

/// Mengambil sampel ketinggian tiap [stepM] meter (interpolasi linear),
/// melewatkan titik tanpa data. Gradien dihitung per jendela [gradeWindowM].
RouteProfile routeProfile(RoutePath path,
    {double stepM = 50, double gradeWindowM = 100}) {
  final pts = path.points;
  final cum = <double>[];
  final ele = <double>[];
  var d = 0.0;
  for (var i = 0; i < pts.length; i++) {
    if (i > 0) d += polylineLengthM([pts[i - 1], pts[i]]);
    final e = i < path.ele.length ? path.ele[i] : double.nan;
    if (e.isFinite) {
      cum.add(d);
      ele.add(e);
    }
  }
  if (ele.length < 2 || cum.last <= 0) {
    return const RouteProfile([], [], []);
  }
  final total = cum.last;
  final step = math.max(stepM, total / 400);
  final xs = <double>[];
  final ys = <double>[];
  var j = 0;
  for (var x = 0.0; x <= total + 1e-6; x += step) {
    while (j < cum.length - 2 && cum[j + 1] < x) {
      j++;
    }
    final span = cum[j + 1] - cum[j];
    final t = span <= 0 ? 0.0 : ((x - cum[j]) / span).clamp(0.0, 1.0);
    xs.add(x);
    ys.add(ele[j] + (ele[j + 1] - ele[j]) * t);
  }
  final half = math.max(1, (gradeWindowM / step / 2).round());
  final grades = <double>[];
  for (var i = 0; i < xs.length; i++) {
    final a = math.max(0, i - half), b = math.min(xs.length - 1, i + half);
    final run = xs[b] - xs[a];
    grades.add(run <= 0 ? 0 : (ys[b] - ys[a]) / run * 100);
  }
  return RouteProfile(xs, ys, grades);
}

/// Tanjakan paling curam (persen) dalam jendela ~[windowM] meter.
double maxGradePct(RoutePath path, {double windowM = 100}) {
  final p = routeProfile(path, stepM: 25, gradeWindowM: windowM);
  var best = 0.0;
  for (final g in p.gradePct) {
    if (g > best) best = g;
  }
  return best;
}

/// Kecepatan rata-rata pengguna (atau bawaan) untuk satu olahraga.
class SportPace {
  final double speedMps;

  /// Tambahan detik per meter naik di atas tanjakan wajar.
  final double climbSecPerM;

  /// Tanjakan wajar (m per km) yang sudah tercermin di [speedMps].
  final double typicalAscentPerKm;
  final bool fromHistory;

  const SportPace({
    required this.speedMps,
    required this.climbSecPerM,
    this.typicalAscentPerKm = 5,
    this.fromHistory = false,
  });

  static SportPace fallback(RouteSport s) => switch (s) {
        RouteSport.ride =>
          const SportPace(speedMps: 20 / 3.6, climbSecPerM: 1.2),
        RouteSport.run => const SportPace(speedMps: 9 / 3.6, climbSecPerM: 3),
        RouteSport.walk =>
          const SportPace(speedMps: 4.8 / 3.6, climbSecPerM: 6),
      };
}

/// Kecepatan dari riwayat: total jarak / total waktu bergerak. Butuh minimal
/// 5 km & 20 menit data supaya tidak meleset; selain itu pakai bawaan.
SportPace paceFromHistory(
    RouteSport sport, double totalDistanceM, double totalMovingS) {
  final base = SportPace.fallback(sport);
  if (totalDistanceM < 5000 || totalMovingS < 1200) return base;
  final v = totalDistanceM / totalMovingS;
  final lo = base.speedMps * 0.35, hi = base.speedMps * 2.5;
  if (v < lo || v > hi) return base;
  return SportPace(
    speedMps: v,
    climbSecPerM: base.climbSecPerM,
    typicalAscentPerKm: base.typicalAscentPerKm,
    fromHistory: true,
  );
}

/// Perkiraan waktu (detik) menempuh rute.
double estimateSeconds(double distanceM, double ascentM, SportPace pace) {
  if (distanceM <= 0 || pace.speedMps <= 0) return 0;
  final flat = distanceM / pace.speedMps;
  final extraClimb =
      math.max(0.0, ascentM - pace.typicalAscentPerKm * distanceM / 1000);
  return flat + extraClimb * pace.climbSecPerM;
}
