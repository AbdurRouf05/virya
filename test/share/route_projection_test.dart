import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/render/route_projection.dart';

import 'share_fixture.dart';

void main() {
  const box = Rect.fromLTWH(10, 20, 300, 500);

  test('fits all points inside the padded box, touching one axis', () {
    final d = fakeShareData();
    final pts = RouteProjection.fitPoints(d.lat, d.lon, box, padding: 16);
    final inner = box.deflate(16);
    var minX = double.infinity, maxX = -double.infinity;
    var minY = double.infinity, maxY = -double.infinity;
    for (final p in pts) {
      minX = math.min(minX, p.dx);
      maxX = math.max(maxX, p.dx);
      minY = math.min(minY, p.dy);
      maxY = math.max(maxY, p.dy);
    }
    expect(minX, greaterThanOrEqualTo(inner.left - 1e-6));
    expect(maxX, lessThanOrEqualTo(inner.right + 1e-6));
    expect(minY, greaterThanOrEqualTo(inner.top - 1e-6));
    expect(maxY, lessThanOrEqualTo(inner.bottom + 1e-6));
    final fillsW = (maxX - minX - inner.width).abs() < 1e-6;
    final fillsH = (maxY - minY - inner.height).abs() < 1e-6;
    expect(fillsW || fillsH, isTrue);
    // Centered.
    expect(((minX + maxX) / 2 - inner.center.dx).abs(), lessThan(1e-6));
    expect(((minY + maxY) / 2 - inner.center.dy).abs(), lessThan(1e-6));
  });

  test('applies cos(lat) correction (1°x1° at 60°N is half as wide)', () {
    final lat = [60.0, 61.0, 61.0, 60.0];
    final lon = [10.0, 10.0, 11.0, 11.0];
    final pts = RouteProjection.fitPoints(
        lat, lon, const Rect.fromLTWH(0, 0, 1000, 1000));
    final w = (pts[2].dx - pts[0].dx).abs();
    final h = (pts[1].dy - pts[0].dy).abs();
    expect(w / h, closeTo(math.cos(60.5 * math.pi / 180), 0.01));
    // North is up.
    expect(pts[1].dy, lessThan(pts[0].dy));
  });

  test('degenerate input projects to the box center', () {
    final pts = RouteProjection.fitPoints([1.0, 1.0], [2.0, 2.0], box);
    expect(pts.first, box.center);
    expect(RouteProjection.fitPoints([], [], box), isEmpty);
  });

  test('coordinate stamp format', () {
    expect(SF.coord(-6.835, 107.62), "6°50'S 107°37'E");
    expect(SF.duration(5330), '1:28:50');
    expect(SF.duration(605), '10:05');
  });
}
