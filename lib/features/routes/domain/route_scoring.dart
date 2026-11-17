import 'package:virya/core/analytics/geo.dart';
import 'package:virya/features/routes/domain/route_models.dart';

/// Kisi kasar titik-titik jejak pengguna untuk cek "jalan baru".
class TrackGrid {
  TrackGrid(this.origin, {this.cellM = 20})
      : _proj = LocalProjector(origin.$1, origin.$2);

  final LatLon origin;
  final double cellM;
  final LocalProjector _proj;
  final Set<int> _cells = {};

  int get size => _cells.length;
  bool get isEmpty => _cells.isEmpty;

  static const int _off = 1 << 20;
  static int _key(int cx, int cy) => (cx + _off) * (_off * 4) + (cy + _off);

  (int, int) _cell(LatLon p) => (
        (_proj.x(p.$2) / cellM).floor(),
        (_proj.y(p.$1) / cellM).floor(),
      );

  void add(LatLon p) {
    final (cx, cy) = _cell(p);
    _cells.add(_key(cx, cy));
  }

  void addAll(Iterable<LatLon> pts) => pts.forEach(add);

  /// Benar bila ada titik jejak dalam sel yang sama atau tetangganya
  /// (radius efektif ≈ 1–2 sel, sekitar 25 m untuk sel 20 m).
  bool near(LatLon p) {
    final (cx, cy) = _cell(p);
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        if (_cells.contains(_key(cx + dx, cy + dy))) return true;
      }
    }
    return false;
  }
}

/// Mengiris polyline tiap [stepM] meter dan memanggil [f] dengan titik tengah
/// irisan serta panjangnya.
void _walk(List<LatLon> pts, double stepM, void Function(LatLon, double) f) {
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1], b = pts[i];
    final len = haversineM(a.$1, a.$2, b.$1, b.$2);
    if (len <= 0) continue;
    final n = (len / stepM).ceil();
    for (var k = 0; k < n; k++) {
      final t = (k + .5) / n;
      f((a.$1 + (b.$1 - a.$1) * t, a.$2 + (b.$2 - a.$2) * t), len / n);
    }
  }
}

/// Bagian panjang rute (0..1) yang jauh dari jejak lama; `null` bila tanpa
/// riwayat.
double? newRoadRatio(List<LatLon> pts, TrackGrid grid) {
  if (grid.isEmpty || pts.length < 2) return null;
  var total = 0.0, fresh = 0.0;
  _walk(pts, 15, (p, len) {
    total += len;
    if (!grid.near(p)) fresh += len;
  });
  return total <= 0 ? null : fresh / total;
}

/// Seberapa banyak (0..1) rute [a] menumpuk di atas rute [b].
double routeOverlap(List<LatLon> a, List<LatLon> b) {
  if (a.length < 2 || b.length < 2) return 0;
  final grid = TrackGrid(b.first, cellM: 30)..addAll(_dense(b, 20));
  return 1 - (newRoadRatio(a, grid) ?? 1);
}

List<LatLon> _dense(List<LatLon> pts, double stepM) {
  final out = <LatLon>[pts.first];
  _walk(pts, stepM, (p, _) => out.add(p));
  out.add(pts.last);
  return out;
}

/// Nilai satu kandidat sesuai preferensi (makin besar makin baik).
double candidateScore(RouteCandidate c, RoutePrefs prefs) {
  final d = c.path.distanceM;
  var s = -3 * (d / prefs.targetM - 1).abs();
  final perKm = d <= 0 ? 0 : c.path.ascentM / (d / 1000);
  switch (prefs.terrain) {
    case RouteTerrain.flat:
      s -= perKm / 10;
    case RouteTerrain.hilly:
      s += perKm / 10;
    case RouteTerrain.any:
      break;
  }
  if (prefs.preferNew && c.newRatio != null) s += 2 * c.newRatio!;
  return s;
}

/// Memilih hingga [count] kandidat terbaik yang saling berbeda, lalu memberi
/// ciri singkat pada masing-masing.
List<RouteCandidate> selectCandidates(
    List<RouteCandidate> all, RoutePrefs prefs,
    {int count = 3}) {
  final pool = [
    for (final c in all)
      if (!c.path.isEmpty) c,
  ]..sort((a, b) =>
      candidateScore(b, prefs).compareTo(candidateScore(a, prefs)));
  final picked = <RouteCandidate>[];
  final skipped = <RouteCandidate>[];
  for (final c in pool) {
    if (picked.length >= count) break;
    final dup = picked.any((p) => routeOverlap(c.path.points, p.path.points) > .9);
    (dup ? skipped : picked).add(c);
  }
  // Kalau kurang, terima juga yang mirip daripada hanya satu pilihan.
  for (final c in skipped) {
    if (picked.length >= count) break;
    picked.add(c);
  }
  return assignTraits(picked, prefs);
}

/// Ciri singkat: "72% jalan baru", "Paling datar", "Banyak tanjakan", ...
List<RouteCandidate> assignTraits(
    List<RouteCandidate> cs, RoutePrefs prefs) {
  if (cs.isEmpty) return cs;
  double perKm(RouteCandidate c) => c.path.distanceM <= 0
      ? 0
      : c.path.ascentM / (c.path.distanceM / 1000);
  final flattest = cs.reduce((a, b) => perKm(a) <= perKm(b) ? a : b);
  final hilliest = cs.reduce((a, b) => perKm(a) >= perKm(b) ? a : b);
  final newest = cs.reduce(
      (a, b) => (a.newRatio ?? -1) >= (b.newRatio ?? -1) ? a : b);
  final closest = cs.reduce((a, b) =>
      (a.path.distanceM - prefs.targetM).abs() <=
              (b.path.distanceM - prefs.targetM).abs()
          ? a
          : b);
  final used = <String>{};
  String pick(RouteCandidate c) {
    final opts = <String>[
      if (identical(c, newest) && (c.newRatio ?? 0) >= .3)
        '${((c.newRatio ?? 0) * 100).round()}% jalan baru',
      if (cs.length > 1 && identical(c, flattest) && !identical(flattest, hilliest))
        'Paling datar',
      if (cs.length > 1 && identical(c, hilliest) && perKm(c) >= 8)
        'Banyak tanjakan',
      if (identical(c, closest)) 'Paling pas jaraknya',
      if ((c.newRatio ?? 0) >= .3)
        '${((c.newRatio ?? 0) * 100).round()}% jalan baru',
      if (c.newRatio != null && c.newRatio! < .3) 'Jalan langganan',
      if (perKm(c) < 4) 'Cenderung datar' else 'Ada tanjakan',
    ];
    for (final o in opts) {
      if (used.add(o)) return o;
    }
    return opts.last;
  }

  return [for (final c in cs) c.withTrait(pick(c))];
}
