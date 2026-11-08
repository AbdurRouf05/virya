import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:virya/features/share/render/paper_painters.dart';
import 'package:virya/features/share/render/topo_ink_camera.dart';
import 'package:virya/features/share/render/topo_ink_style.dart';

/// Ground plate of radius [rr] (unit disc space): fill, grid, contours.
void paintTopoGround(Canvas canvas, TopoCam cam,
    {required double rr,
    required int seed,
    required TopoInkStyle st,
    required double u}) {
  final disc = Rect.fromCenter(
      center: Offset(cam.cx, cam.cy), width: 2 * rr * cam.s, height: 2 * rr * cam.s * cam.ct);
  final discPath = Path()..addOval(disc);

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
  final bx = -rr, by = rr;
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
}

/// Compass rim with degree ticks and a north label.
void paintTopoRim(Canvas canvas, TopoCam cam, double r, TopoInkStyle st, double u) {
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
