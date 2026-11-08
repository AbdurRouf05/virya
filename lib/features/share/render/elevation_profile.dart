import 'dart:math' as math;
import 'dart:ui';

import 'package:virya/app/theme/field_notes.dart';

/// Elevation silhouette, optionally colored by grade, with hatching.
/// Returns the top-edge points (for annotation). [fill]/[edge] default to
/// `FN.ink`.
List<Offset> paintElevation(
  Canvas canvas,
  Rect rect, {
  required List<double> dist,
  required List<double> ele,
  List<double>? grade,
  bool byGrade = true,
  Color? fill,
  Color? edge,
  double edgeWidth = 1.4,
  bool hatch = true,
  Color hatchColor = const Color(0x33141414),
  double headroom = 0.08,
}) {
  final edgeColor = edge ?? FN.ink;
  final n = math.min(dist.length, ele.length);
  if (n < 2) return const [];
  final total = math.max(dist[n - 1] - dist[0], 1e-6);
  var lo = ele[0], hi = ele[0];
  for (var i = 1; i < n; i++) {
    lo = math.min(lo, ele[i]);
    hi = math.max(hi, ele[i]);
  }
  final span = math.max(hi - lo, 20.0);
  final h = rect.height * (1 - headroom);
  final pts = <Offset>[
    for (var i = 0; i < n; i++)
      Offset(rect.left + (dist[i] - dist[0]) / total * rect.width,
          rect.bottom - (ele[i] - lo) / span * h * 0.94 - rect.height * 0.04),
  ];
  final whole = Path()..moveTo(rect.left, rect.bottom);
  for (final p in pts) {
    whole.lineTo(p.dx, p.dy);
  }
  whole
    ..lineTo(rect.right, rect.bottom)
    ..close();

  if (byGrade && grade != null && grade.length >= n) {
    var i = 1;
    while (i < n) {
      final c = FN.grade(grade[i]);
      final seg = Path()
        ..moveTo(pts[i - 1].dx, rect.bottom)
        ..lineTo(pts[i - 1].dx, pts[i - 1].dy);
      var j = i;
      while (j < n && FN.grade(grade[j]) == c) {
        seg.lineTo(pts[j].dx, pts[j].dy);
        j++;
      }
      final last = pts[j - 1];
      seg
        ..lineTo(last.dx, rect.bottom)
        ..close();
      canvas.drawPath(seg, Paint()..color = c);
      i = j;
    }
  } else {
    canvas.drawPath(whole, Paint()..color = fill ?? FN.ink);
  }
  if (hatch) {
    canvas.save();
    canvas.clipPath(whole);
    final hp = Paint()
      ..color = hatchColor
      ..strokeWidth = 0.8;
    for (var x = rect.left - rect.height; x < rect.right; x += 4) {
      canvas.drawLine(Offset(x, rect.bottom), Offset(x + rect.height, rect.top), hp);
    }
    canvas.restore();
  }
  final top = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (final p in pts.skip(1)) {
    top.lineTo(p.dx, p.dy);
  }
  canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = edgeWidth
        ..strokeJoin = StrokeJoin.round
        ..color = edgeColor);
  canvas.drawLine(rect.bottomLeft, rect.bottomRight,
      Paint()
        ..color = edgeColor
        ..strokeWidth = 1);
  return pts;
}
