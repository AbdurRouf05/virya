import 'dart:math' as math;
import 'dart:ui';

import 'package:virya/features/share/render/topo_ink_camera.dart';
import 'package:virya/features/share/render/topo_ink_style.dart';

/// Start flag planted at [s0].
void paintTopoStartFlag(Canvas canvas, Offset s0, TopoInkStyle st, double u) {
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
}

/// Photo marker on a pin at [p]; filled once the tracer has [passed] it.
void paintTopoPhotoMarker(
    Canvas canvas, Offset p, bool passed, TopoInkStyle st, double u) {
  final q = p.translate(0, -14 * u);
  canvas.drawLine(p, q, Paint()
    ..color = st.head
    ..strokeWidth = 1 * u);
  final box = Rect.fromCenter(center: q.translate(0, -4 * u), width: 9 * u, height: 7 * u);
  if (passed) {
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

/// Tracer head at [head]: dashed drop line to [g] on the ground, ground
/// ring, glow, core.
void paintTopoHead(Canvas canvas, TopoCam cam, Offset head, Offset g,
    TopoInkStyle st, double u) {
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
