import 'dart:ui';

/// Oblique camera for the Topo-Ink renderer: yaw around the up axis, then
/// tilt; [s] is the unit-disc radius in pixels.
class TopoCam {
  final double cx, cy, s, cyaw, syaw, ct, st;
  // cyaw/syaw: cos/sin of yaw; ct/st: cos/sin of tilt.
  const TopoCam(this.cx, this.cy, this.s, this.cyaw, this.syaw, this.ct, this.st);

  Offset p(double x, double y, double z) {
    final xr = x * cyaw - y * syaw;
    final yr = x * syaw + y * cyaw;
    return Offset(cx + xr * s, cy - yr * ct * s - z * st * s);
  }
}
