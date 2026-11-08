import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/features/share/render/paper_painters.dart';

/// Colors for the Topo-Ink renderer.
class TopoInkStyle {
  final Color? background;
  final Color ground;
  final Color rim;
  final Color grid;
  final Color contour;
  final Color shadow;
  final Color curtain;
  final Color ribbon;
  final Color accent;
  final Color head;
  final bool glow;

  const TopoInkStyle({
    this.background,
    required this.ground,
    required this.rim,
    required this.grid,
    required this.contour,
    required this.shadow,
    required this.curtain,
    required this.ribbon,
    required this.accent,
    required this.head,
    this.glow = true,
  });

  factory TopoInkStyle.night({Color accent = FN.acid, bool background = true}) =>
      TopoInkStyle(
        background: background ? FN.night : null,
        ground: const Color(0xFF151513),
        rim: const Color(0xFF55554C),
        grid: const Color(0xFF26261F),
        contour: const Color(0xFF2E2E27),
        shadow: const Color(0x66000000),
        curtain: const Color(0x40EFE9DC),
        ribbon: const Color(0x80EFE9DC),
        accent: accent,
        head: FN.paper,
      );

  factory TopoInkStyle.paper({Color accent = FN.signal, bool background = true}) =>
      TopoInkStyle(
        background: background ? FN.paper : null,
        ground: FN.paperDeep,
        rim: FN.inkSoft,
        grid: const Color(0x30141414),
        contour: FN.paperLine,
        shadow: const Color(0x30141414),
        curtain: const Color(0x55141414),
        ribbon: FN.ink,
        accent: accent,
        head: FN.ink,
        glow: false,
      );
}

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

  _Cam _cam(Rect vp, double yaw, double tilt, double zoom) {
    final ct = math.cos(tilt), st = math.sin(tilt);
    final s = math.min(vp.width * 0.43, vp.height * 0.9 / (2.2 * ct + zMax * st)) *
        zoom;
    final cy = vp.center.dy + zMax * st * s / 2;
    return _Cam(vp.center.dx, cy, s, math.cos(yaw), math.sin(yaw), ct, st);
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

  /// Screen position of the tracer head.
  Offset headOffset(Size size,
      {double t = 1, double yaw = 0, double tilt = 0.95, Rect? viewport, double zoom = 1}) {
    final cam = _cam(viewport ?? Offset.zero & size, yaw, tilt, zoom);
    final (x, y, z) = _at(t);
    return cam.p(x, y, z);
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
    final disc = Rect.fromCenter(
        center: Offset(cam.cx, cam.cy), width: 2 * rr * cam.s, height: 2 * rr * cam.s * cam.ct);
    final discPath = Path()..addOval(disc);

    // Ground plate, grid, contours.
    canvas.drawOval(disc, Paint()..color = st.ground);
    canvas.save();
    canvas.clipPath(discPath);
    final gp = Paint()
      ..color = st.grid
      ..strokeWidth = 0.8 * u;
    for (var c = -1.0; c <= 1.0001; c += 0.25) {
      final h = math.sqrt(math.max(0, rr * rr - c * c));
      canvas.drawLine(cam.p(c, -h, 0), cam.p(c, h, 0), gp);
      canvas.drawLine(cam.p(-h, c, 0), cam.p(h, c, 0), gp);
    }
    final field = ContourField.of(seed, cols: 40);
    final ax = 2 * rr / field.cols, ay = -2 * rr / field.rows;
    const bx = -rr, by = rr;
    final m = Float64List(16)
      ..[0] = cam.s * cam.cyaw * ax
      ..[1] = -cam.s * cam.ct * cam.syaw * ax
      ..[4] = -cam.s * cam.syaw * ay
      ..[5] = -cam.s * cam.ct * cam.cyaw * ay
      ..[10] = 1
      ..[12] = cam.cx + cam.s * cam.cyaw * bx - cam.s * cam.syaw * by
      ..[13] = cam.cy - cam.s * cam.ct * cam.syaw * bx - cam.s * cam.ct * cam.cyaw * by
      ..[15] = 1;
    final cp = Paint()
      ..style = PaintingStyle.stroke
      ..color = st.contour;
    for (var k = 0; k < field.levels.length; k++) {
      cp.strokeWidth = (k % 5 == 2 ? 1.5 : 0.7) * u;
      canvas.drawPath(field.levels[k].transform(m), cp);
    }
    canvas.restore();

    if (showRim) _paintRim(canvas, cam, rr, st, u);

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
    // Start flag.
    final s0 = top.first;
    final fp = Paint()
      ..color = st.head
      ..strokeWidth = 1.2 * u;
    canvas.drawLine(s0, s0.translate(0, -18 * u), fp);
    canvas.drawPath(
        Path()
          ..moveTo(s0.dx, s0.dy - 18 * u)
          ..lineTo(s0.dx + 10 * u, s0.dy - 14.5 * u)
          ..lineTo(s0.dx, s0.dy - 11 * u)
          ..close(),
        Paint()..color = st.accent);

    // Photo markers.
    for (final f in markerFracs) {
      final (mx, my, mz) = _at(f.clamp(0, 1));
      final p = cam.p(mx, my, mz);
      final q = p.translate(0, -14 * u);
      canvas.drawLine(p, q, Paint()
        ..color = st.head
        ..strokeWidth = 1 * u);
      final box = Rect.fromCenter(center: q.translate(0, -4 * u), width: 9 * u, height: 7 * u);
      if (f <= tc) {
        canvas.drawRect(box, Paint()..color = st.accent);
      } else {
        canvas.drawRect(
            box,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1 * u
              ..color = st.head);
      }
    }

    // Head: drop line, ground ring, glow, core.
    if (tc > 0) {
      final g = cam.p(hx, hy, 0);
      final dl = Paint()
        ..color = st.accent.withValues(alpha: 0.7)
        ..strokeWidth = 1 * u;
      final len = (head - g).distance;
      for (var d = 0.0; d < len; d += 5 * u) {
        final a = Offset.lerp(head, g, d / len)!;
        final b = Offset.lerp(head, g, math.min(1, (d + 2.5 * u) / len))!;
        canvas.drawLine(a, b, dl);
      }
      canvas.drawOval(
          Rect.fromCenter(center: g, width: 14 * u, height: 14 * u * cam.ct),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1 * u
            ..color = st.accent);
      if (st.glow) {
        canvas.drawCircle(
            head,
            20 * u,
            Paint()
              ..shader = Gradient.radial(head, 20 * u, [
                st.accent.withValues(alpha: 0.75),
                st.accent.withValues(alpha: 0),
              ]));
      } else {
        canvas.drawCircle(head, 7 * u, Paint()..color = st.accent.withValues(alpha: 0.25));
      }
      canvas.drawCircle(head, 4 * u, Paint()..color = st.accent);
      canvas.drawCircle(head, 2 * u, Paint()..color = st.head);
    }
  }

  void _paintRim(Canvas canvas, _Cam cam, double r, TopoInkStyle st, double u) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cam.cx, cam.cy),
            width: 2 * r * cam.s,
            height: 2 * r * cam.s * cam.ct),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1 * u
          ..color = st.rim);
    final tp = Paint()..color = st.rim;
    for (var d = 0; d < 360; d += 10) {
      final a = d * math.pi / 180;
      final long = d % 90 == 0;
      final p0 = cam.p(r * math.sin(a), r * math.cos(a), 0);
      final p1 = cam.p((r + (long ? 0.07 : 0.035)) * math.sin(a),
          (r + (long ? 0.07 : 0.035)) * math.cos(a), 0);
      tp.strokeWidth = (long ? 1.4 : 0.8) * u;
      canvas.drawLine(p0, p1, tp);
    }
    final np = cam.p(0, r + 0.16, 0);
    final label = monoText('N', size: 9 * u, color: st.rim, weight: FontWeight.w700);
    label.paint(canvas, np - Offset(label.width / 2, label.height / 2));
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

class _Cam {
  final double cx, cy, s, cyaw, syaw, ct, st;
  // cyaw/syaw: cos/sin of yaw.
  const _Cam(this.cx, this.cy, this.s, this.cyaw, this.syaw, this.ct, this.st);

  Offset p(double x, double y, double z) {
    final xr = x * cyaw - y * syaw;
    final yr = x * syaw + y * cyaw;
    return Offset(cx + xr * s, cy - yr * ct * s - z * st * s);
  }
}
