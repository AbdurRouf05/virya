import 'dart:math' as math;

import 'package:virya/core/analytics/geo.dart';
import 'package:virya/features/routes/domain/route_models.dart';

/// Posisi pengguna terhadap rute rencana.
class RouteFix {
  /// Jarak sepanjang rute dari titik mulai (m).
  final double alongM;

  /// Jarak tegak lurus ke rute (m).
  final double offsetM;
  final double remainingM;
  const RouteFix(this.alongM, this.offsetM, this.remainingM);
}

/// Memproyeksikan posisi GPS ke rute. Mencari di jendela ke depan dari posisi
/// terakhir supaya rute keliling/pergi-pulang yang bertumpuk tidak meloncat;
/// bila terlalu jauh, mencari ke seluruh rute.
class RouteTracker {
  RouteTracker(this.points)
      : _proj = points.isEmpty
            ? LocalProjector(0, 0)
            : LocalProjector(points.first.$1, points.first.$2) {
    _xs = [for (final p in points) _proj.x(p.$2)];
    _ys = [for (final p in points) _proj.y(p.$1)];
    _cum = List<double>.filled(points.length, 0);
    for (var i = 1; i < points.length; i++) {
      _cum[i] = _cum[i - 1] +
          math.sqrt(math.pow(_xs[i] - _xs[i - 1], 2) +
              math.pow(_ys[i] - _ys[i - 1], 2));
    }
  }

  final List<LatLon> points;
  final LocalProjector _proj;
  late final List<double> _xs, _ys, _cum;
  int _seg = 0;

  /// Panjang jendela pencarian ke depan (m).
  static const double windowM = 600;

  double get totalM => _cum.isEmpty ? 0 : _cum.last;

  void reset() => _seg = 0;

  RouteFix? update(LatLon p) {
    if (points.length < 2) return null;
    final px = _proj.x(p.$2), py = _proj.y(p.$1);
    // Jendela: sedikit ke belakang, ~600 m ke depan.
    var from = _seg;
    while (from > 0 && _cum[_seg] - _cum[from] < 50) {
      from--;
    }
    var to = _seg;
    while (to < points.length - 2 && _cum[to] - _cum[_seg] < windowM) {
      to++;
    }
    var best = _nearest(px, py, from, to);
    if (best.$2 > 60) {
      final global = _nearest(px, py, 0, points.length - 2);
      if (global.$2 < best.$2 - 20) best = global;
    }
    final (seg, dist, along) = best;
    _seg = seg;
    return RouteFix(along, dist, math.max(0, totalM - along));
  }

  (int, double, double) _nearest(double px, double py, int from, int to) {
    var bestSeg = from;
    var bestD = double.infinity;
    var bestAlong = 0.0;
    for (var i = from; i <= to; i++) {
      final ax = _xs[i], ay = _ys[i];
      final dx = _xs[i + 1] - ax, dy = _ys[i + 1] - ay;
      final len2 = dx * dx + dy * dy;
      final t = len2 <= 0
          ? 0.0
          : (((px - ax) * dx + (py - ay) * dy) / len2).clamp(0.0, 1.0);
      final qx = ax + dx * t, qy = ay + dy * t;
      final d = math.sqrt((px - qx) * (px - qx) + (py - qy) * (py - qy));
      if (d < bestD) {
        bestD = d;
        bestSeg = i;
        bestAlong = _cum[i] + (_cum[i + 1] - _cum[i]) * t;
      }
    }
    return (bestSeg, bestD, bestAlong);
  }
}

/// Peristiwa perubahan status keluar/kembali ke rute.
enum OffRouteEvent { left, rejoined }

/// Menyatakan "keluar rute" bila menyimpang > [offM] selama [holdS] detik,
/// dan "kembali" bila jaraknya < [backM]. Histeresis mencegah peringatan
/// berulang di batas.
class OffRouteMonitor {
  OffRouteMonitor({this.offM = 50, this.backM = 30, this.holdS = 10});

  final double offM;
  final double backM;
  final double holdS;

  bool _off = false;
  DateTime? _since;

  bool get isOff => _off;

  OffRouteEvent? update(double offsetM, DateTime at) {
    if (_off) {
      if (offsetM < backM) {
        _off = false;
        _since = null;
        return OffRouteEvent.rejoined;
      }
      return null;
    }
    if (offsetM <= offM) {
      _since = null;
      return null;
    }
    _since ??= at;
    if (at.difference(_since!).inMilliseconds >= holdS * 1000) {
      _off = true;
      return OffRouteEvent.left;
    }
    return null;
  }

  void reset() {
    _off = false;
    _since = null;
  }
}
