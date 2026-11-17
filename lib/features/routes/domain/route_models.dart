import 'package:virya/core/analytics/geo.dart';

typedef LatLon = (double lat, double lon);

/// Olahraga untuk perencanaan rute (menentukan profil routing & kecepatan).
enum RouteSport {
  run('Lari', 2, 50, 8),
  ride('Sepeda', 5, 200, 40),
  walk('Jalan', 1, 30, 5);

  final String label;
  final double minKm;
  final double maxKm;
  final double defaultKm;
  const RouteSport(this.label, this.minKm, this.maxKm, this.defaultKm);

  static RouteSport fromName(String? n) =>
      values.firstWhere((s) => s.name == n, orElse: () => ride);
}

enum RouteShape {
  loop('Keliling'),
  outAndBack('Pergi-pulang'),
  pointToPoint('A → B'),
  manual('Manual');

  final String label;
  const RouteShape(this.label);

  static RouteShape fromName(String? n) =>
      values.firstWhere((s) => s.name == n, orElse: () => manual);
}

enum RouteTerrain {
  flat('Datar'),
  any('Bebas'),
  hilly('Cari tanjakan');

  final String label;
  const RouteTerrain(this.label);
}

/// Pilihan di layar "Atur".
class RoutePrefs {
  final LatLon? start;
  final LatLon? destination;
  final RouteSport sport;
  final double targetM;
  final RouteShape shape;
  final RouteTerrain terrain;
  final bool preferNew;
  final bool avoidMain;

  const RoutePrefs({
    this.start,
    this.destination,
    this.sport = RouteSport.ride,
    this.targetM = 40000,
    this.shape = RouteShape.loop,
    this.terrain = RouteTerrain.any,
    this.preferNew = true,
    this.avoidMain = false,
  });

  RoutePrefs copyWith({
    LatLon? start,
    LatLon? destination,
    bool clearDestination = false,
    RouteSport? sport,
    double? targetM,
    RouteShape? shape,
    RouteTerrain? terrain,
    bool? preferNew,
    bool? avoidMain,
  }) =>
      RoutePrefs(
        start: start ?? this.start,
        destination:
            clearDestination ? null : (destination ?? this.destination),
        sport: sport ?? this.sport,
        targetM: targetM ?? this.targetM,
        shape: shape ?? this.shape,
        terrain: terrain ?? this.terrain,
        preferNew: preferNew ?? this.preferNew,
        avoidMain: avoidMain ?? this.avoidMain,
      );
}

/// Garis rute dengan ketinggian per titik (`NaN` bila tidak diketahui).
class RoutePath {
  final List<LatLon> points;
  final List<double> ele;
  final double distanceM;
  final double ascentM;

  const RoutePath({
    required this.points,
    required this.ele,
    required this.distanceM,
    required this.ascentM,
  });

  static const empty =
      RoutePath(points: [], ele: [], distanceM: 0, ascentM: 0);

  bool get isEmpty => points.length < 2;

  /// Dibuat dari titik saja; jarak & tanjakan dihitung ulang.
  factory RoutePath.fromPoints(List<LatLon> pts, List<double> ele) =>
      RoutePath(
        points: pts,
        ele: ele,
        distanceM: polylineLengthM(pts),
        ascentM: ascentOf(ele),
      );

  RoutePath reversed() => RoutePath(
        points: points.reversed.toList(growable: false),
        ele: ele.reversed.toList(growable: false),
        distanceM: distanceM,
        ascentM: ascentOf(ele.reversed.toList(growable: false)),
      );

  /// Menyambung jalur; titik sambung yang kembar dibuang.
  static RoutePath join(List<RoutePath> parts) {
    final pts = <LatLon>[];
    final ele = <double>[];
    for (final p in parts) {
      for (var i = 0; i < p.points.length; i++) {
        if (i == 0 && pts.isNotEmpty && pts.last == p.points[0]) continue;
        pts.add(p.points[i]);
        ele.add(i < p.ele.length ? p.ele[i] : double.nan);
      }
    }
    return RoutePath.fromPoints(pts, ele);
  }
}

/// Panjang polyline dalam meter.
double polylineLengthM(List<LatLon> pts) {
  var d = 0.0;
  for (var i = 1; i < pts.length; i++) {
    d += haversineM(pts[i - 1].$1, pts[i - 1].$2, pts[i].$1, pts[i].$2);
  }
  return d;
}

/// Total naik dengan ambang 3 m supaya derau DEM tidak terhitung.
double ascentOf(List<double> ele, {double thresholdM = 3}) {
  double? ref;
  var gain = 0.0;
  for (final e in ele) {
    if (!e.isFinite) continue;
    if (ref == null) {
      ref = e;
    } else if (e - ref >= thresholdM) {
      gain += e - ref;
      ref = e;
    } else if (ref - e >= thresholdM) {
      ref = e;
    }
  }
  return gain;
}

/// Satu pilihan rute hasil "Buat rute".
class RouteCandidate {
  final RoutePath path;
  final List<LatLon> waypoints;
  final RouteShape shape;

  /// Bagian rute (0..1) yang belum pernah dilewati; `null` bila tanpa riwayat.
  final double? newRatio;
  final String trait;

  const RouteCandidate({
    required this.path,
    required this.waypoints,
    required this.shape,
    this.newRatio,
    this.trait = '',
  });

  RouteCandidate withTrait(String t) => RouteCandidate(
        path: path,
        waypoints: waypoints,
        shape: shape,
        newRatio: newRatio,
        trait: t,
      );
}

/// Rute yang tersimpan (atau siap disimpan).
class SavedRoute {
  final String id;
  final String name;
  final RouteSport sport;
  final RouteShape shape;
  final RoutePath path;
  final List<LatLon> waypoints;
  final DateTime createdAt;

  const SavedRoute({
    required this.id,
    required this.name,
    required this.sport,
    required this.shape,
    required this.path,
    this.waypoints = const [],
    required this.createdAt,
  });

  SavedRoute copyWith({String? id, String? name, RoutePath? path,
          List<LatLon>? waypoints, RouteShape? shape}) =>
      SavedRoute(
        id: id ?? this.id,
        name: name ?? this.name,
        sport: sport,
        shape: shape ?? this.shape,
        path: path ?? this.path,
        waypoints: waypoints ?? this.waypoints,
        createdAt: createdAt,
      );
}
