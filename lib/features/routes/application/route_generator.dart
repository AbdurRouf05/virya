import 'dart:math' as math;

import 'package:virya/features/routes/data/routing_client.dart';
import 'package:virya/features/routes/domain/loop_planner.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/domain/route_scoring.dart';

/// Membuat beberapa kandidat rute lewat [RoutingClient], lalu memilih tiga
/// yang paling cocok & beragam. Jumlah permintaan dibatasi (maks ~12) demi
/// pemakaian wajar server publik.
class RouteGenerator {
  RouteGenerator(this.client, {math.Random? random})
      : _rnd = random ?? math.Random();

  final RoutingClient client;
  final math.Random _rnd;

  /// Jumlah percobaan arah untuk keliling / pergi-pulang otomatis.
  static const int tries = 4;

  /// Maksimal ulang skala jari-jari per arah.
  static const int maxIterations = 3;

  Future<List<RouteCandidate>> generate(RoutePrefs prefs,
      {TrackGrid? history}) async {
    final start = prefs.start;
    if (start == null) {
      throw const RoutingException('Titik mulai belum ada. Ketuk peta dulu.');
    }
    final raw = switch (prefs.shape) {
      RouteShape.loop => await _loops(start, prefs),
      RouteShape.outAndBack => await _outAndBack(start, prefs),
      RouteShape.pointToPoint || RouteShape.manual =>
        await _pointToPoint(start, prefs),
    };
    final scored = [
      for (final c in raw)
        RouteCandidate(
          path: c.path,
          waypoints: c.waypoints,
          shape: c.shape,
          newRatio: history == null ? null : newRoadRatio(c.path.points, history),
        ),
    ];
    return selectCandidates(scored, prefs);
  }

  List<double> _bearings() {
    final off = _rnd.nextDouble() * 360;
    return [for (var i = 0; i < tries; i++) (off + i * 360 / tries) % 360];
  }

  Future<RoutePath> _route(List<LatLon> via, RoutePrefs p, [int alt = 0]) =>
      client.route(via,
          sport: p.sport, avoidMain: p.avoidMain, alternative: alt);

  /// Menjalankan [jobs] dua-dua; kandidat gagal dilewati. Bila semuanya
  /// gagal, kesalahan pertama dilempar (offline langsung dilempar).
  Future<List<RouteCandidate>> _collect(
      List<Future<RouteCandidate> Function()> jobs) async {
    final out = <RouteCandidate>[];
    RoutingException? first;
    for (var i = 0; i < jobs.length; i += 2) {
      final batch = jobs.skip(i).take(2).map((j) async {
        try {
          return await j();
        } on RoutingException catch (e) {
          if (e.offline) rethrow;
          first ??= e;
          return null;
        }
      });
      for (final c in await Future.wait(batch)) {
        if (c != null && !c.path.isEmpty) out.add(c);
      }
    }
    if (out.isEmpty) {
      throw first ??
          const RoutingException('Rute tidak ditemukan. Coba lagi.');
    }
    return out;
  }

  Future<List<RouteCandidate>> _loops(LatLon start, RoutePrefs p) {
    final count = p.targetM < 10000 ? 2 : (p.targetM > 80000 ? 4 : 3);
    return _collect([
      for (final b in _bearings())
        () async {
          var r = initialLoopRadius(p.targetM);
          RouteCandidate? best;
          for (var it = 0; it < maxIterations; it++) {
            final wps = loopWaypoints(start, r, b, count: count, jitter: _rnd);
            final stops = [start, ...wps, start];
            final path = await _route(stops, p);
            final c = RouteCandidate(
                path: path, waypoints: stops, shape: RouteShape.loop);
            if (best == null ||
                (path.distanceM - p.targetM).abs() <
                    (best.path.distanceM - p.targetM).abs()) {
              best = c;
            }
            if (withinTarget(path.distanceM, p.targetM)) break;
            r = rescaleRadius(r, p.targetM, path.distanceM);
          }
          return best!;
        },
    ]);
  }

  RouteCandidate _mirror(LatLon start, LatLon dest, RoutePath out) =>
      RouteCandidate(
        path: RoutePath.join([out, out.reversed()]),
        waypoints: [start, dest, start],
        shape: RouteShape.outAndBack,
      );

  Future<List<RouteCandidate>> _outAndBack(LatLon start, RoutePrefs p) {
    final dest = p.destination;
    if (dest != null) {
      return _collect([
        for (var alt = 0; alt < 3; alt++)
          () async => _mirror(start, dest, await _route([start, dest], p, alt)),
      ]);
    }
    return _collect([
      for (final b in _bearings())
        () async {
          var reach = p.targetM / 2 / roadWindingFactor;
          RouteCandidate? best;
          for (var it = 0; it < maxIterations - 1; it++) {
            final d = destinationPoint(start, b, reach);
            final c = _mirror(start, d, await _route([start, d], p));
            if (best == null ||
                (c.path.distanceM - p.targetM).abs() <
                    (best.path.distanceM - p.targetM).abs()) {
              best = c;
            }
            if (withinTarget(c.path.distanceM, p.targetM)) break;
            reach = rescaleRadius(reach, p.targetM, c.path.distanceM);
          }
          return best!;
        },
    ]);
  }

  Future<List<RouteCandidate>> _pointToPoint(LatLon start, RoutePrefs p) {
    final dest = p.destination;
    if (dest == null) {
      throw const RoutingException('Ketuk peta untuk memilih titik tujuan.');
    }
    return _collect([
      for (var alt = 0; alt < 3; alt++)
        () async => RouteCandidate(
              path: await _route([start, dest], p, alt),
              waypoints: [start, dest],
              shape: RouteShape.pointToPoint,
            ),
    ]);
  }
}
