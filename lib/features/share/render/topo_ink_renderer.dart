import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:virya/features/share/render/topo_ink_camera.dart';
import 'package:virya/features/share/render/topo_ink_ground.dart';
import 'package:virya/features/share/render/topo_ink_markers.dart';
import 'package:virya/features/share/render/topo_ink_style.dart';

export 'package:virya/features/share/render/topo_ink_style.dart';

/// Pure-Flutter oblique "2.5D" route: ribbon lifted by exaggerated elevation,
/// hatched curtain down to a contour ground disc, rotating camera, animated
/// tracer. Deterministic: same inputs → same pixels.
class TopoInkRenderer {
  final int seed;
  final List<double> markerFracs; // photo positions 0..1
  final List<(double, double)> sectorFracs; // highlighted ranges 0..1

  late final Float64List _x, _y, _z, _f;
  late final double zMax;

  TopoInkRenderer({
    required List<double> lat,
    required List<double> lon,
    required List<double> ele,
    List<double>? dist,
    this.seed = 0,
    double exaggeration = 1,
    this.markerFracs = const [],
    this.sectorFracs = const [],
  }) {
    final n = math.min(lat.length, lon.length);
    _x = Float64List(n);
    _y = Float64List(n);
    _z = Float64List(n);
    _f = Float64List(n);
    if (n == 0) {
      zMax = 0;
      return;
    }
    var minLat = lat[0], maxLat = lat[0], minLon = lon[0], maxLon = lon[0];
    for (var i = 1; i < n; i++) {
      minLat = math.min(minLat, lat[i]);
      maxLat = math.max(maxLat, lat[i]);
      minLon = math.min(minLon, lon[i]);
      maxLon = math.max(maxLon, lon[i]);
    }
    final lat0 = (minLat + maxLat) / 2, lon0 = (minLon + maxLon) / 2;
    final k = math.cos(lat0 * math.pi / 180) * 111320;
    var r = 1e-6;
    for (var i = 0; i < n; i++) {
      _x[i] = (lon[i] - lon0) * k;
      _y[i] = (lat[i] - lat0) * 110540;
      r = math.max(r, math.sqrt(_x[i] * _x[i] + _y[i] * _y[i]));
    }
    var lo = double.infinity, hi = -double.infinity;
    for (var i = 0; i < n; i++) {
      final e = i < ele.length ? ele[i] : 0.0;
      lo = math.min(lo, e);
      hi = math.max(hi, e);
    }
    final raw = (hi - lo) / r;
    final gain = raw > 0 ? (0.34 / raw).clamp(1.0, 30.0) * exaggeration : 0.0;
    zMax = raw * gain;
    for (var i = 0; i < n; i++) {
      _x[i] /= r;
      _y[i] /= r;
      final e = i < ele.length ? ele[i] : lo;
      _z[i] = (e - lo) / r * gain;
    }
    final hasDist = dist != null && dist.length >= n && dist[n - 1] > dist[0];
    for (var i = 0; i < n; i++) {
      _f[i] = n == 1
          ? 1
          : hasDist
              ? (dist[i] - dist[0]) / (dist[n - 1] - dist[0])
              : i / (n - 1);
    }
  }

  int get length => _x.length;

  TopoCam _cam(Rect vp, double yaw, double tilt, double zoom) {
    final ct = math.cos(tilt), st = math.sin(tilt);
    final s = math.min(vp.width * 0.43, vp.height * 0.9 / (2.2 * ct + zMax * st)) *
        zoom;
    final cy = vp.center.dy + zMax * st * s / 2;
    return TopoCam(vp.center.dx, cy, s, math.cos(yaw), math.sin(yaw), ct, st);
  }

  /// Index i and blend w such that position = lerp(p[i], p[i+1], w).
  (int, double) _locate(double t) {
    final n = _f.length;
    if (n < 2 || t <= 0) return (0, 0);
    if (t >= 1) return (n - 2, 1);
    var lo = 0, hi = n - 1;
    while (hi - lo > 1) {
      final m = (lo + hi) >> 1;
      if (_f[m] <= t) {
        lo = m;
      } else {
        hi = m;
      }
    }
    final span = _f[hi] - _f[lo];
    return (lo, span <= 0 ? 0 : (t - _f[lo]) / span);
  }

  (double, double, double) _at(double t) {
    if (_f.isEmpty) return (0, 0, 0);
    if (_f.length == 1) return (_x[0], _y[0], _z[0]);
    final (i, w) = _locate(t);
    double l(Float64List a) => a[i] + (a[i + 1] - a[i]) * w;
    return (l(_x), l(_y), l(_z));
  }

  void paint(
    Canvas canvas,
    Size size, {
    double t = 1,
    double yaw = 0,
    double tilt = 0.95,
    TopoInkStyle? style,
    Rect? viewport,
    double zoom = 1,
    bool showRim = true,
  }) {
    final st = style ?? TopoInkStyle.night();
    final vp = viewport ?? Offset.zero & size;
    final u = vp.width / 360; // stroke unit
    if (st.background != null) {
      canvas.drawRect(vp, Paint()..color = st.background!);
    }
    final cam = _cam(vp, yaw, tilt, zoom);
    const rr = 1.06;
    paintTopoGround(canvas, cam, rr: rr, seed: seed, st: st, u: u);
    if (showRim) paintTopoRim(canvas, cam, rr, st, u);

    final n = length;
    if (n < 2) return;
    final ground = [for (var i = 0; i < n; i++) cam.p(_x[i], _y[i], 0)];
    final top = [for (var i = 0; i < n; i++) cam.p(_x[i], _y[i], _z[i])];
    final tc = t.clamp(0.0, 1.0);
    final (hi, _) = _locate(tc);
    final (hx, hy, hz) = _at(tc);
    final head = cam.p(hx, hy, hz);

    // Ground shadow.
    canvas.drawPath(
        _poly(ground, 0, n),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6 * u
          ..strokeJoin = StrokeJoin.round
          ..color = st.shadow);

    // Curtain hatch.
    final step = math.max(1, n ~/ 170);
    final cu = Paint()..strokeWidth = 0.7 * u;
    for (var i = 0; i < n; i += step) {
      final passed = _f[i] <= tc;
      cu.color = passed ? st.accent.withValues(alpha: 0.38) : st.curtain;
      canvas.drawLine(ground[i], top[i], cu);
    }

    // Full ribbon (faint), sectors, travelled part.
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_poly(top, 0, n), stroke
      ..strokeWidth = 1.3 * u
      ..color = st.ribbon);
    for (final (a, b) in sectorFracs) {
      final (i0, _) = _locate(a.clamp(0, 1));
      final (i1, _) = _locate(b.clamp(0, 1));
      canvas.drawPath(
          _poly(top, i0, i1 + 2),
          stroke
            ..strokeWidth = 4.2 * u
            ..color = st.ribbon.withValues(alpha: 0.35));
    }
    if (tc > 0) {
      final done = _poly(top, 0, hi + 1)..lineTo(head.dx, head.dy);
      if (st.glow) {
        canvas.drawPath(
            done,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 7 * u
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..color = st.accent.withValues(alpha: 0.35)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * u));
      }
      canvas.drawPath(done, stroke
        ..strokeWidth = 3 * u
        ..color = st.accent);
    }
    paintTopoStartFlag(canvas, top.first, st, u);
    for (final f in markerFracs) {
      final (mx, my, mz) = _at(f.clamp(0, 1));
      paintTopoPhotoMarker(canvas, cam.p(mx, my, mz), f <= tc, st, u);
    }
    if (tc > 0) paintTopoHead(canvas, cam, head, cam.p(hx, hy, 0), st, u);
  }

  static Path _poly(List<Offset> pts, int from, int to) {
    final p = Path();
    final end = math.min(to, pts.length);
    if (end - from < 1) return p;
    p.moveTo(pts[from].dx, pts[from].dy);
    for (var i = from + 1; i < end; i++) {
      p.lineTo(pts[i].dx, pts[i].dy);
    }
    return p;
  }
}
