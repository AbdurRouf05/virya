import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stravo/app/theme/field_notes.dart';

enum PaperTexture { none, grid, contours }

/// Cream paper with a faint notebook grid or topographic contour lines.
class PaperBackground extends StatelessWidget {
  final Widget child;
  final PaperTexture texture;
  final bool night;
  final int seed;

  const PaperBackground({
    super.key,
    required this.child,
    this.texture = PaperTexture.grid,
    this.night = false,
    this.seed = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: night ? FN.night : FN.paper,
      child: CustomPaint(
        isComplex: true,
        painter: texture == PaperTexture.none
            ? null
            : _PaperPainter(texture, night, seed),
        child: child,
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  final PaperTexture texture;
  final bool night;
  final int seed;
  _PaperPainter(this.texture, this.night, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final line = (night ? FN.nightLine : FN.paperLine);
    if (texture == PaperTexture.grid) {
      final p = Paint()
        ..color = line.withValues(alpha: 0.45)
        ..strokeWidth = 0.5;
      const step = 24.0;
      for (var x = step; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
      }
      for (var y = step; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
      }
      return;
    }
    paintContours(canvas, size, line.withValues(alpha: 0.7), seed);
  }

  @override
  bool shouldRepaint(_PaperPainter old) =>
      old.texture != texture || old.night != night || old.seed != seed;
}

/// Wobbly concentric "contour lines" around a few peaks. Deterministic.
void paintContours(Canvas canvas, Size size, Color color, int seed,
    {int peaks = 3, int rings = 9, double strokeWidth = 0.8}) {
  final rnd = math.Random(seed);
  final p = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth;
  final maxR = math.max(size.width, size.height) * 0.55;
  for (var k = 0; k < peaks; k++) {
    final c = Offset(rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height);
    final ph1 = rnd.nextDouble() * 6.28, ph2 = rnd.nextDouble() * 6.28;
    final stretch = 0.7 + rnd.nextDouble() * 0.6;
    for (var r = 1; r <= rings; r++) {
      final radius = maxR * r / rings;
      final path = Path();
      for (var i = 0; i <= 72; i++) {
        final a = i / 72 * math.pi * 2;
        final wob = 1 +
            0.12 * math.sin(3 * a + ph1 + r * 0.3) +
            0.07 * math.cos(5 * a + ph2 - r * 0.2);
        final pt = c +
            Offset(math.cos(a) * radius * wob,
                math.sin(a) * radius * wob * stretch);
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, p);
    }
  }
}
