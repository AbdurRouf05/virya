import 'dart:convert';

import 'package:virya/features/routes/data/routing_client.dart';
import 'package:virya/features/routes/domain/route_models.dart';

const _noRoute = RoutingException(
    'Tidak ada jalan yang bisa dilewati di sekitar titik ini. '
    'Coba geser titik mulai atau ubah jaraknya.');

/// Membaca GeoJSON BRouter: `features[0].geometry.coordinates` berisi
/// `[lon, lat, ele]`; panjang & tanjakan dari `properties`.
RoutePath parseBrouterGeoJson(String body) {
  final Map<String, dynamic> j;
  try {
    j = jsonDecode(body) as Map<String, dynamic>;
  } catch (_) {
    throw _noRoute;
  }
  final feats = j['features'];
  if (feats is! List || feats.isEmpty) throw _noRoute;
  final f = feats.first as Map<String, dynamic>;
  final coords = (f['geometry'] as Map?)?['coordinates'];
  if (coords is! List || coords.length < 2) throw _noRoute;
  final pts = <LatLon>[];
  final ele = <double>[];
  for (final c in coords) {
    final l = c as List;
    pts.add(((l[1] as num).toDouble(), (l[0] as num).toDouble()));
    ele.add(l.length > 2 ? (l[2] as num).toDouble() : double.nan);
  }
  final props = (f['properties'] as Map?) ?? const {};
  double? num_(String k) => double.tryParse('${props[k] ?? ''}');
  final base = RoutePath.fromPoints(pts, ele);
  return RoutePath(
    points: pts,
    ele: ele,
    distanceM: num_('track-length') ?? base.distanceM,
    ascentM: num_('filtered ascend') ?? base.ascentM,
  );
}

/// Membaca respons OSRM (`geometries=geojson`); tanpa ketinggian.
RoutePath parseOsrmJson(String body) {
  final Map<String, dynamic> j;
  try {
    j = jsonDecode(body) as Map<String, dynamic>;
  } catch (_) {
    throw _noRoute;
  }
  final routes = j['routes'];
  if (j['code'] != 'Ok' || routes is! List || routes.isEmpty) throw _noRoute;
  final r = routes.first as Map<String, dynamic>;
  final coords = (r['geometry'] as Map?)?['coordinates'];
  if (coords is! List || coords.length < 2) throw _noRoute;
  final pts = <LatLon>[
    for (final c in coords)
      (((c as List)[1] as num).toDouble(), (c[0] as num).toDouble()),
  ];
  final ele = List<double>.filled(pts.length, double.nan);
  return RoutePath(
    points: pts,
    ele: ele,
    distanceM: (r['distance'] as num?)?.toDouble() ?? polylineLengthM(pts),
    ascentM: 0,
  );
}

/// Pesan untuk kode HTTP gagal dari layanan routing.
RoutingException routingHttpError(int status, String body) {
  if (status == 400 && body.contains('not found')) {
    return const RoutingException(
        'Wilayah ini belum didukung layanan rute. Coba titik lain.');
  }
  if (status == 429) {
    return const RoutingException(
        'Layanan rute sedang sibuk. Tunggu sebentar lalu coba lagi.');
  }
  if (status >= 500) {
    return const RoutingException(
        'Layanan rute sedang bermasalah. Coba lagi nanti.');
  }
  return _noRoute;
}
