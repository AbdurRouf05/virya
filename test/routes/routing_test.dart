import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/analytics/geo.dart';
import 'package:virya/features/routes/application/route_generator.dart';
import 'package:virya/features/routes/data/routing_client.dart';
import 'package:virya/features/routes/data/routing_parsers.dart';
import 'package:virya/features/routes/domain/route_models.dart';

/// Layanan palsu: garis lurus antar titik, dikali [winding] supaya mirip
/// jalan sungguhan. Tanpa jaringan.
class FakeRouting implements RoutingClient {
  FakeRouting({this.winding = 1.3, this.fail});
  final double winding;
  final RoutingException? fail;
  int calls = 0;

  @override
  Future<RoutePath> route(List<LatLon> via,
      {required RouteSport sport,
      bool avoidMain = false,
      int alternative = 0}) async {
    calls++;
    if (fail != null) throw fail!;
    final base = RoutePath.fromPoints(via, List<double>.filled(via.length, 0));
    return RoutePath(
      points: via,
      ele: base.ele,
      distanceM: base.distanceM * winding * (1 + alternative * 0.05),
      ascentM: alternative * 50.0,
    );
  }
}

void main() {
  const LatLon start = (-6.2, 106.8);

  test('parser GeoJSON BRouter', () {
    const body = '{"type":"FeatureCollection","features":[{"type":"Feature",'
        '"properties":{"track-length":"1234","filtered ascend":"56"},'
        '"geometry":{"type":"LineString","coordinates":'
        '[[106.8,-6.2,10.5],[106.81,-6.21,12.0]]}}]}';
    final p = parseBrouterGeoJson(body);
    expect(p.points.first, (-6.2, 106.8));
    expect(p.ele, [10.5, 12.0]);
    expect(p.distanceM, 1234);
    expect(p.ascentM, 56);
    expect(() => parseBrouterGeoJson(''), throwsA(isA<RoutingException>()));
  });

  test('parser OSRM & pesan kesalahan HTTP', () {
    const body = '{"code":"Ok","routes":[{"distance":3158.9,'
        '"geometry":{"coordinates":[[106.82,-6.17],[106.84,-6.19]]}}]}';
    final p = parseOsrmJson(body);
    expect(p.distanceM, 3158.9);
    expect(p.ele.every((e) => e.isNaN), isTrue);
    expect(routingHttpError(400, 'datafile E0_N0.rd5 not found').message,
        contains('belum didukung'));
    expect(routingHttpError(503, '').message, contains('bermasalah'));
  });

  test('keliling: 3 pilihan dekat target, permintaan terbatas', () async {
    final fake = FakeRouting();
    final gen = RouteGenerator(fake, random: math.Random(1));
    final out = await gen.generate(
        const RoutePrefs(start: start, targetM: 30000, preferNew: false));
    expect(out, hasLength(3));
    for (final c in out) {
      expect(c.shape, RouteShape.loop);
      expect((c.path.distanceM / 30000 - 1).abs(), lessThan(0.25));
      expect(c.waypoints.first, start);
      expect(c.waypoints.last, start);
      expect(c.trait, isNotEmpty);
    }
    expect(fake.calls,
        lessThanOrEqualTo(RouteGenerator.tries * RouteGenerator.maxIterations));
  });

  test('pergi-pulang otomatis kembali ke titik mulai', () async {
    final gen = RouteGenerator(FakeRouting(), random: math.Random(2));
    final out = await gen.generate(const RoutePrefs(
        start: start, targetM: 20000, shape: RouteShape.outAndBack));
    expect(out, isNotEmpty);
    final p = out.first.path.points;
    expect(haversineM(p.last.$1, p.last.$2, start.$1, start.$2), lessThan(1));
  });

  test('A ke B butuh tujuan; offline dilempar dengan pesan jelas', () async {
    final gen = RouteGenerator(FakeRouting());
    await expectLater(
        gen.generate(
            const RoutePrefs(start: start, shape: RouteShape.pointToPoint)),
        throwsA(isA<RoutingException>()));
    final off = RouteGenerator(FakeRouting(
        fail: const RoutingException('Tidak ada koneksi internet.',
            offline: true)));
    await expectLater(
        off.generate(const RoutePrefs(start: start)),
        throwsA(isA<RoutingException>()
            .having((e) => e.offline, 'offline', isTrue)));
  });
}
