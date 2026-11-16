import 'dart:convert';

import 'package:virya/features/routes/domain/route_models.dart';

/// Titik rute → JSON ringkas `[[lat,lon,ele],...]` (ele `null` bila kosong).
String encodePath(RoutePath p) => jsonEncode([
      for (var i = 0; i < p.points.length; i++)
        [
          _r(p.points[i].$1, 1e6),
          _r(p.points[i].$2, 1e6),
          if (i < p.ele.length && p.ele[i].isFinite) _r(p.ele[i], 10) else null,
        ],
    ]);

double _r(double v, double k) => (v * k).round() / k;

/// Kebalikan [encodePath]. Data rusak menghasilkan rute kosong.
RoutePath decodePath(String json, {double? distanceM, double? ascentM}) {
  try {
    final raw = jsonDecode(json) as List;
    final pts = <LatLon>[];
    final ele = <double>[];
    for (final r in raw) {
      final l = r as List;
      pts.add(((l[0] as num).toDouble(), (l[1] as num).toDouble()));
      ele.add(l.length > 2 && l[2] != null
          ? (l[2] as num).toDouble()
          : double.nan);
    }
    final base = RoutePath.fromPoints(pts, ele);
    return RoutePath(
      points: pts,
      ele: ele,
      distanceM: distanceM ?? base.distanceM,
      ascentM: ascentM ?? base.ascentM,
    );
  } catch (_) {
    return RoutePath.empty;
  }
}

String encodeWaypoints(List<LatLon> w) =>
    jsonEncode([for (final p in w) [_r(p.$1, 1e6), _r(p.$2, 1e6)]]);

List<LatLon> decodeWaypoints(String json) {
  try {
    return [
      for (final r in jsonDecode(json) as List)
        (((r as List)[0] as num).toDouble(), (r[1] as num).toDouble()),
    ];
  } catch (_) {
    return const [];
  }
}
