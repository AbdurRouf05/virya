import 'package:virya/core/analytics/geo.dart';
import 'package:virya/features/routes/domain/route_models.dart';

/// Memecah [path] menjadi potongan antar titik bantu [stops] (termasuk mulai
/// & akhir). Indeks pencocokan selalu maju supaya rute keliling tidak salah
/// potong. Bila tidak cocok, hasilnya satu potongan utuh.
List<RoutePath> splitAtStops(RoutePath path, List<LatLon> stops) {
  final pts = path.points;
  if (pts.length < 2 || stops.length < 2) return [path];
  final cuts = <int>[0];
  var from = 0;
  for (var s = 1; s < stops.length - 1; s++) {
    // Sisakan titik untuk sisa stop supaya potongan tidak kosong.
    final limit = pts.length - 1 - (stops.length - 1 - s);
    var best = from + 1, bestD = double.infinity;
    for (var i = from + 1; i <= limit; i++) {
      final d = haversineM(stops[s].$1, stops[s].$2, pts[i].$1, pts[i].$2);
      if (d < bestD) {
        bestD = d;
        best = i;
      }
    }
    if (best > limit) return [path];
    cuts.add(best);
    from = best;
  }
  cuts.add(pts.length - 1);
  return [
    for (var k = 1; k < cuts.length; k++)
      RoutePath.fromPoints(
        pts.sublist(cuts[k - 1], cuts[k] + 1),
        [
          for (var i = cuts[k - 1]; i <= cuts[k]; i++)
            i < path.ele.length ? path.ele[i] : double.nan,
        ],
      ),
  ];
}

/// Garis lurus sebagai cadangan bila routing gagal untuk satu potongan.
RoutePath straightLeg(LatLon a, LatLon b) =>
    RoutePath.fromPoints([a, b], const [double.nan, double.nan]);
