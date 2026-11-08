import 'dart:math' as math;

/// Small geo helpers shared by the map widgets and the flyover planner.
typedef LatLon = (double lat, double lon);

const _earthR = 6371008.8;
double _rad(double d) => d * math.pi / 180;
double _deg(double r) => r * 180 / math.pi;

double haversineM(double lat1, double lon1, double lat2, double lon2) {
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) *
          math.cos(_rad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return 2 * _earthR * math.asin(math.min(1, math.sqrt(a)));
}

/// Initial bearing in degrees [0, 360).
double bearingDeg(double lat1, double lon1, double lat2, double lon2) {
  final y = math.sin(_rad(lon2 - lon1)) * math.cos(_rad(lat2));
  final x = math.cos(_rad(lat1)) * math.sin(_rad(lat2)) -
      math.sin(_rad(lat1)) * math.cos(_rad(lat2)) * math.cos(_rad(lon2 - lon1));
  return (_deg(math.atan2(y, x)) + 360) % 360;
}

List<double> cumulativeDistance(List<LatLon> pts) {
  final out = List<double>.filled(pts.length, 0);
  for (var i = 1; i < pts.length; i++) {
    out[i] = out[i - 1] +
        haversineM(pts[i - 1].$1, pts[i - 1].$2, pts[i].$1, pts[i].$2);
  }
  return out;
}

/// Douglas–Peucker on a local equirectangular projection. Returns kept
/// indices (always includes first and last), ascending.
List<int> simplifyIndices(List<LatLon> pts, double epsilonM) {
  final n = pts.length;
  if (n <= 2) return List.generate(n, (i) => i);
  final lat0 = pts.map((e) => e.$1).reduce((a, b) => a + b) / n;
  final kx = _earthR * math.cos(_rad(lat0)) * math.pi / 180;
  const ky = _earthR * math.pi / 180;
  final xs = [for (final p in pts) p.$2 * kx];
  final ys = [for (final p in pts) p.$1 * ky];
  final keep = List<bool>.filled(n, false)
    ..[0] = true
    ..[n - 1] = true;
  final stack = <(int, int)>[(0, n - 1)];
  final eps2 = epsilonM * epsilonM;
  while (stack.isNotEmpty) {
    final (a, b) = stack.removeLast();
    if (b <= a + 1) continue;
    final ax = xs[a], ay = ys[a];
    final dx = xs[b] - ax, dy = ys[b] - ay;
    final len2 = dx * dx + dy * dy;
    var maxD = -1.0;
    var idx = -1;
    for (var i = a + 1; i < b; i++) {
      double d2;
      if (len2 == 0) {
        final ex = xs[i] - ax, ey = ys[i] - ay;
        d2 = ex * ex + ey * ey;
      } else {
        var t = ((xs[i] - ax) * dx + (ys[i] - ay) * dy) / len2;
        t = t.clamp(0.0, 1.0);
        final ex = xs[i] - (ax + t * dx), ey = ys[i] - (ay + t * dy);
        d2 = ex * ex + ey * ey;
      }
      if (d2 > maxD) {
        maxD = d2;
        idx = i;
      }
    }
    if (maxD > eps2) {
      keep[idx] = true;
      stack
        ..add((a, idx))
        ..add((idx, b));
    }
  }
  return [for (var i = 0; i < n; i++) if (keep[i]) i];
}

/// Indices of at most [maxPoints] shape-preserving points.
List<int> downsampleIndices(List<LatLon> pts, int maxPoints) {
  if (pts.length <= maxPoints) return List.generate(pts.length, (i) => i);
  var eps = 2.0;
  var idx = simplifyIndices(pts, eps);
  var guard = 0;
  while (idx.length > maxPoints && guard++ < 20) {
    eps *= 1.8;
    idx = simplifyIndices(pts, eps);
  }
  if (idx.length > maxPoints) {
    final step = idx.length / maxPoints;
    idx = [for (var i = 0; i < maxPoints - 1; i++) idx[(i * step).floor()], idx.last];
  }
  return idx;
}

/// Uniform Catmull–Rom between p1 and p2 (t in [0,1]).
LatLon catmullRom(LatLon p0, LatLon p1, LatLon p2, LatLon p3, double t) {
  double f(double a, double b, double c, double d) {
    final t2 = t * t, t3 = t2 * t;
    return 0.5 *
        ((2 * b) +
            (-a + c) * t +
            (2 * a - 5 * b + 4 * c - d) * t2 +
            (-a + 3 * b - 3 * c + d) * t3);
  }

  return (f(p0.$1, p1.$1, p2.$1, p3.$1), f(p0.$2, p1.$2, p2.$2, p3.$2));
}

/// Densifies [ctrl] with Catmull–Rom, [steps] samples per segment.
List<LatLon> catmullRomPath(List<LatLon> ctrl, {int steps = 6}) {
  if (ctrl.length < 3) return List.of(ctrl);
  final out = <LatLon>[];
  for (var i = 0; i < ctrl.length - 1; i++) {
    final p0 = ctrl[math.max(0, i - 1)];
    final p1 = ctrl[i];
    final p2 = ctrl[i + 1];
    final p3 = ctrl[math.min(ctrl.length - 1, i + 2)];
    for (var s = 0; s < steps; s++) {
      out.add(catmullRom(p0, p1, p2, p3, s / steps));
    }
  }
  out.add(ctrl.last);
  return out;
}

/// Removes 360° jumps so angles can be smoothed / interpolated linearly.
List<double> unwrapAngles(List<double> a) {
  if (a.isEmpty) return [];
  final out = <double>[a.first];
  for (var i = 1; i < a.length; i++) {
    var d = a[i] - a[i - 1];
    d = (d + 540) % 360 - 180;
    out.add(out.last + d);
  }
  return out;
}

/// Zero-phase Gaussian smoothing with edge clamping.
List<double> gaussianSmooth(List<double> v, double sigma) {
  if (sigma <= 0 || v.length < 3) return List.of(v);
  final r = (sigma * 3).ceil();
  final w = [for (var k = -r; k <= r; k++) math.exp(-(k * k) / (2 * sigma * sigma))];
  final out = List<double>.filled(v.length, 0);
  for (var i = 0; i < v.length; i++) {
    var s = 0.0, ws = 0.0;
    for (var k = -r; k <= r; k++) {
      final j = (i + k).clamp(0, v.length - 1);
      s += v[j] * w[k + r];
      ws += w[k + r];
    }
    out[i] = s / ws;
  }
  return out;
}

/// Linear interpolation of y(x) for ascending [xs].
double interpAt(List<double> xs, List<double> ys, double x) {
  if (xs.isEmpty) return 0;
  if (x <= xs.first) return ys.first;
  if (x >= xs.last) return ys.last;
  var lo = 0, hi = xs.length - 1;
  while (hi - lo > 1) {
    final m = (lo + hi) >> 1;
    if (xs[m] <= x) {
      lo = m;
    } else {
      hi = m;
    }
  }
  final span = xs[hi] - xs[lo];
  if (span <= 0) return ys[lo];
  final t = (x - xs[lo]) / span;
  return ys[lo] + (ys[hi] - ys[lo]) * t;
}

double easeInOut(double t) {
  final x = t.clamp(0.0, 1.0);
  return x < .5 ? 4 * x * x * x : 1 - math.pow(-2 * x + 2, 3) / 2;
}
