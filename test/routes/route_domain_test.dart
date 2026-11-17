import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/analytics/geo.dart';
import 'package:virya/features/routes/domain/loop_planner.dart';
import 'package:virya/features/routes/domain/route_codec.dart';
import 'package:virya/features/routes/domain/route_gpx.dart';
import 'package:virya/features/routes/domain/route_legs.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/domain/route_progress.dart';
import 'package:virya/features/routes/domain/route_scoring.dart';
import 'package:virya/features/routes/domain/route_stats.dart';
import 'package:virya/features/routes/domain/routing_profile.dart';

const LatLon start = (-6.2, 106.8);

double dist(LatLon a, LatLon b) => haversineM(a.$1, a.$2, b.$1, b.$2);

/// Garis lurus ke utara sepanjang [m] meter, titik tiap 10 m.
List<LatLon> northLine(double m, {LatLon from = start}) => [
      for (var d = 0.0; d <= m; d += 10) destinationPoint(from, 0, d),
    ];

RouteCandidate cand(double km, double ascent, double? fresh,
        {double bearing = 0}) =>
    RouteCandidate(
      path: RoutePath(
        points: [start, destinationPoint(start, bearing, km * 1000)],
        ele: const [0, 0],
        distanceM: km * 1000,
        ascentM: ascent,
      ),
      waypoints: const [],
      shape: RouteShape.loop,
      newRatio: fresh,
    );

void main() {
  group('geometri keliling', () {
    test('titik tujuan & arah konsisten', () {
      final p = destinationPoint(start, 90, 1000);
      expect(dist(start, p), closeTo(1000, 1));
      expect(bearingBetween(start, p), closeTo(90, 0.5));
    });

    test('titik bantu ada di lingkaran yang melewati titik mulai', () {
      const r = 3000.0;
      final w = loopWaypoints(start, r, 45, count: 3);
      final center = destinationPoint(start, 45, r);
      expect(w, hasLength(3));
      for (final p in w) {
        expect(dist(center, p), closeTo(r, 2));
      }
      expect(dist(center, start), closeTo(r, 2));
    });

    test('jari-jari awal dan skala ulang', () {
      expect(initialLoopRadius(40000),
          closeTo(40000 / (2 * math.pi) / 1.25, 1e-6));
      expect(rescaleRadius(1000, 40000, 20000), 2000);
      expect(rescaleRadius(1000, 40000, 200000), 500);
      expect(withinTarget(43000, 40000), isTrue);
      expect(withinTarget(45000, 40000), isFalse);
    });

    test('nama arah & nama bawaan', () {
      expect(compassWord(0), 'utara');
      expect(compassWord(135), 'tenggara');
      expect(compassWord(350), 'utara');
      expect(defaultRouteName(RouteShape.loop, start, northLine(5000), 40200),
          'Keliling utara 40 km');
    });

    test('profil BRouter per olahraga', () {
      expect(brouterProfile(RouteSport.ride, avoidMain: false), 'trekking');
      expect(brouterProfile(RouteSport.ride, avoidMain: true), 'safety');
      expect(brouterProfile(RouteSport.run, avoidMain: false), 'shortest');
      expect(brouterProfile(RouteSport.walk, avoidMain: true),
          'hiking-mountain');
    });
  });

  group('statistik', () {
    test('tanjakan dengan ambang derau', () {
      expect(ascentOf([0, 1, 0, 1, 0, 1]), 0);
      expect(ascentOf([0, 10, 5, 20]), 25);
      expect(ascentOf([double.nan, 0, 10]), 10);
    });

    test('perkiraan waktu & kecepatan dari riwayat', () {
      final pace = SportPace.fallback(RouteSport.ride);
      expect(estimateSeconds(20000, 0, pace), closeTo(3600, 1));
      // 40 km, 500 m naik: kelebihan 300 m x 1,2 s.
      expect(estimateSeconds(40000, 500, pace), closeTo(7200 + 360, 1));
      final h = paceFromHistory(RouteSport.ride, 100000, 4 * 3600);
      expect(h.fromHistory, isTrue);
      expect(h.speedMps * 3.6, closeTo(25, 0.01));
      expect(paceFromHistory(RouteSport.ride, 1000, 300).fromHistory, isFalse);
    });

    test('tanjakan maksimum & profil', () {
      final pts = northLine(1000);
      final ele = [
        for (var i = 0; i < pts.length; i++) i < 50 ? 0.0 : (i - 50) * 1.0,
      ];
      final path = RoutePath.fromPoints(pts, ele);
      expect(maxGradePct(path), closeTo(10, 1));
      expect(routeProfile(path).hasData, isTrue);
      final noEle = RoutePath.fromPoints(
          pts, List<double>.filled(pts.length, double.nan));
      expect(routeProfile(noEle).hasData, isFalse);
    });
  });

  group('jalan baru & pemilihan', () {
    test('rasio jalan baru dari kisi jejak', () {
      final route = northLine(2000);
      final grid = TrackGrid(start)..addAll(northLine(1000));
      expect(newRoadRatio(route, grid)!, closeTo(0.5, 0.05));
      expect(newRoadRatio(route, TrackGrid(start)), isNull);
      // Jejak paralel 200 m ke timur tidak dihitung sudah dilewati.
      final far = TrackGrid(start)
        ..addAll(northLine(2000, from: destinationPoint(start, 90, 200)));
      expect(newRoadRatio(route, far), closeTo(1, 0.01));
    });

    test('memilih 3 beragam, buang duplikat, beri ciri', () {
      const prefs = RoutePrefs(start: start, targetM: 40000);
      final a = cand(40, 400, 0.72);
      final dup = cand(40, 400, 0.70);
      final b = cand(39, 100, 0.2, bearing: 120);
      final c = cand(42, 900, 0.1, bearing: 240);
      final out = selectCandidates([a, dup, b, c], prefs);
      expect(out, hasLength(3));
      expect(out.map((x) => x.newRatio), isNot(contains(0.70)));
      expect(out.map((x) => x.trait).toSet(), hasLength(3));
      expect(out.first.trait, '72% jalan baru');
      expect(out.map((x) => x.trait), contains('Paling datar'));
      expect(out.map((x) => x.trait), contains('Banyak tanjakan'));
    });

    test('preferensi datar mengutamakan rute landai', () {
      const prefs = RoutePrefs(
          start: start,
          targetM: 40000,
          terrain: RouteTerrain.flat,
          preferNew: false);
      final hilly = cand(40, 1200, null);
      final flat = cand(40, 50, null, bearing: 180);
      expect(candidateScore(flat, prefs),
          greaterThan(candidateScore(hilly, prefs)));
    });
  });

  group('mengikuti rute', () {
    test('sisa jarak dan jarak ke rute', () {
      final t = RouteTracker(northLine(2000));
      final f = t.update(
          destinationPoint(destinationPoint(start, 0, 500), 90, 20))!;
      expect(f.alongM, closeTo(500, 5));
      expect(f.offsetM, closeTo(20, 2));
      expect(f.remainingM, closeTo(1500, 5));
    });

    test('rute pergi-pulang tidak meloncat ke arah pulang', () {
      final out = northLine(1000);
      final t = RouteTracker([...out, ...out.reversed.skip(1)]);
      for (var d = 0.0; d <= 900; d += 50) {
        t.update(destinationPoint(start, 0, d));
      }
      final f = t.update(destinationPoint(start, 0, 950))!;
      expect(f.alongM, closeTo(950, 10));
    });

    test('peringatan keluar rute butuh waktu & histeresis', () {
      final m = OffRouteMonitor();
      final t0 = DateTime(2026, 11, 16, 7);
      DateTime at(int s) => t0.add(Duration(seconds: s));
      expect(m.update(80, at(0)), isNull);
      expect(m.update(80, at(5)), isNull);
      expect(m.update(80, at(10)), OffRouteEvent.left);
      expect(m.update(40, at(11)), isNull);
      expect(m.update(20, at(12)), OffRouteEvent.rejoined);
      // Menjauh singkat lalu kembali: tidak ada peringatan.
      expect(m.update(80, at(13)), isNull);
      expect(m.update(10, at(16)), isNull);
      expect(m.update(80, at(20)), isNull);
      expect(m.isOff, isFalse);
    });
  });

  group('simpan & ekspor', () {
    final path = RoutePath.fromPoints(
        [start, (-6.21, 106.81), (-6.22, 106.8)], [10, double.nan, 30]);

    test('codec bolak-balik', () {
      final back = decodePath(encodePath(path));
      expect(back.points, path.points);
      expect(back.ele[0], 10);
      expect(back.ele[1].isNaN, isTrue);
      expect(back.distanceM, closeTo(path.distanceM, 0.5));
      expect(decodePath('rusak').isEmpty, isTrue);
      expect(decodeWaypoints(encodeWaypoints([start])), [start]);
    });

    test('GPX berisi titik, nama di-escape', () {
      final gpx = routeToGpx(SavedRoute(
        id: 'x',
        name: 'Pagi & sore',
        sport: RouteSport.run,
        shape: RouteShape.loop,
        path: path,
        createdAt: DateTime.utc(2026, 11, 16),
      ));
      expect(gpx, contains('<name>Pagi &amp; sore</name>'));
      expect('<trkpt'.allMatches(gpx), hasLength(3));
      expect(gpx, contains('<ele>10.0</ele>'));
      expect(gpxFileName('Keliling Utara 40 km'), 'keliling-utara-40-km.gpx');
    });

    test('potong per titik bantu & balik arah', () {
      final pts = northLine(3000);
      final p = RoutePath.fromPoints(pts, List<double>.filled(pts.length, 0));
      final stops = [pts.first, destinationPoint(start, 0, 1000), pts.last];
      final legs = splitAtStops(p, stops);
      expect(legs, hasLength(2));
      expect(legs[0].distanceM, closeTo(1000, 15));
      expect(RoutePath.join(legs).distanceM, closeTo(p.distanceM, 1));
      expect(p.reversed().points.first, pts.last);
    });
  });
}
