import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:virya/app/theme/export_tokens.dart';

export 'package:virya/features/share/render/contour_field.dart';
export 'package:virya/features/share/render/elevation_profile.dart';

final _grainCache = <String, (Float32List, Float32List)>{};

/// Paper grain: deterministic dark + light specks.
void paintGrain(
  Canvas canvas,
  Rect rect, {
  required int seed,
  double density = 0.05,
  Color dark = const Color(0x22141414),
  Color light = const Color(0x33FFFFFF),
  double dot = 0.7,
}) {
  final n = (rect.width * rect.height * density).round().clamp(0, 60000);
  final key = '$seed:${rect.width.round()}:${rect.height.round()}:$n';
  var pts = _grainCache[key];
  if (pts == null) {
    if (_grainCache.length > 8) _grainCache.remove(_grainCache.keys.first);
    final r = math.Random(seed);
    Float32List gen(int count) {
      final l = Float32List(count * 2);
      for (var i = 0; i < count; i++) {
        l[i * 2] = r.nextDouble() * rect.width;
        l[i * 2 + 1] = r.nextDouble() * rect.height;
      }
      return l;
    }

    pts = _grainCache[key] = (gen(n), gen(n ~/ 2));
  }
  canvas.save();
  canvas.translate(rect.left, rect.top);
  final p = Paint()
    ..strokeWidth = dot
    ..strokeCap = StrokeCap.round;
  canvas.drawRawPoints(PointMode.points, pts.$1, p..color = dark);
  canvas.drawRawPoints(PointMode.points, pts.$2, p..color = light);
  canvas.restore();
}

/// Ink route with optional ink-bleed halo.
void paintRoute(
  Canvas canvas,
  List<Offset> pts, {
  required Color color,
  double width = 2.4,
  bool bleed = true,
  Color? outline,
  double outlineWidth = 0,
  Shadow? shadow,
}) {
  if (pts.length < 2) return;
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (var i = 1; i < pts.length; i++) {
    path.lineTo(pts[i].dx, pts[i].dy);
  }
  Paint stroke(Color c, double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = c;
  if (shadow != null) {
    canvas.drawPath(
        path.shift(shadow.offset),
        stroke(shadow.color, width + outlineWidth * 2)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma));
  }
  if (outline != null && outlineWidth > 0) {
    canvas.drawPath(path, stroke(outline, width + outlineWidth * 2));
  }
  if (bleed) {
    canvas.drawPath(
        path,
        stroke(color.withValues(alpha: color.a * 0.28), width * 2.2)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 0.9));
  }
  canvas.drawPath(path, stroke(color, width));
}

/// Start ring and finish block.
void paintStartFinish(
  Canvas canvas,
  Offset start,
  Offset finish, {
  required Color color,
  double size = 6,
  Color? fill,
}) {
  final ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.4
    ..color = color;
  if (fill != null) {
    canvas.drawCircle(start, size, Paint()..color = fill);
  }
  canvas.drawCircle(start, size, ring);
  canvas.drawCircle(start, size * 0.35, Paint()..color = color);
  final r = Rect.fromCenter(center: finish, width: size * 1.5, height: size * 1.5);
  canvas.save();
  canvas.translate(finish.dx, finish.dy);
  canvas.rotate(math.pi / 4);
  canvas.translate(-finish.dx, -finish.dy);
  if (fill != null) canvas.drawRect(r.inflate(size * 0.3), Paint()..color = fill);
  canvas.drawRect(r, Paint()..color = color);
  canvas.restore();
}

/// Mono text helper for painters. [color] defaults to `FNExport.ink`,
/// [family] to `FNExport.mono`.
TextPainter monoText(
  String s, {
  double size = 9,
  Color? color,
  FontWeight weight = FontWeight.w500,
  double spacing = 1.2,
  String? family,
  double? height,
  List<Shadow>? shadows,
}) =>
    TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: family ?? FNExport.mono,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: color ?? FNExport.ink,
          height: height,
          shadows: shadows,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
