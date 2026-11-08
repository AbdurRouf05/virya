import 'dart:math' as math;
import 'dart:ui';

/// Equirectangular projection with cos(lat) correction, fitted (aspect kept)
/// and centered inside [box] minus [padding].
class RouteProjection {
  final double _cosLat;
  final double _minX, _maxY;
  final double scale;
  final Offset origin; // screen position of (_minX, _maxY)

  RouteProjection._(
      this._cosLat, this._minX, this._maxY, this.scale, this.origin);

  factory RouteProjection.fit(
    List<double> lat,
    List<double> lon,
    Rect box, {
    double padding = 0,
  }) {
    assert(lat.length == lon.length);
    if (lat.isEmpty) {
      return RouteProjection._(1, 0, 0, 1, box.center);
    }
    var minLat = lat.first, maxLat = lat.first;
    var minLon = lon.first, maxLon = lon.first;
    for (var i = 1; i < lat.length; i++) {
      minLat = math.min(minLat, lat[i]);
      maxLat = math.max(maxLat, lat[i]);
      minLon = math.min(minLon, lon[i]);
      maxLon = math.max(maxLon, lon[i]);
    }
    final cosLat = math.cos((minLat + maxLat) / 2 * math.pi / 180).abs();
    final minX = minLon * cosLat, maxX = maxLon * cosLat;
    final dx = maxX - minX, dy = maxLat - minLat;
    final inner = box.deflate(padding);
    final w = math.max(inner.width, 1e-6), h = math.max(inner.height, 1e-6);
    double s;
    if (dx <= 1e-12 && dy <= 1e-12) {
      s = 1;
    } else if (dx <= 1e-12) {
      s = h / dy;
    } else if (dy <= 1e-12) {
      s = w / dx;
    } else {
      s = math.min(w / dx, h / dy);
    }
    final ox = inner.center.dx - dx * s / 2;
    final oy = inner.center.dy - dy * s / 2;
    return RouteProjection._(cosLat, minX, maxLat, s, Offset(ox, oy));
  }

  Offset project(double lat, double lon) => Offset(
        origin.dx + (lon * _cosLat - _minX) * scale,
        origin.dy + (_maxY - lat) * scale,
      );

  List<Offset> projectAll(List<double> lat, List<double> lon) =>
      [for (var i = 0; i < lat.length; i++) project(lat[i], lon[i])];

  static List<Offset> fitPoints(
    List<double> lat,
    List<double> lon,
    Rect box, {
    double padding = 0,
  }) =>
      RouteProjection.fit(lat, lon, box, padding: padding)
          .projectAll(lat, lon);
}

Path polyline(List<Offset> pts, {int from = 0, int? to}) {
  final p = Path();
  final end = math.min(to ?? pts.length, pts.length);
  if (end - from < 1) return p;
  p.moveTo(pts[from].dx, pts[from].dy);
  for (var i = from + 1; i < end; i++) {
    p.lineTo(pts[i].dx, pts[i].dy);
  }
  return p;
}
