import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Hand-drawn style 5-point stars (filled vs outlined), classic-race sector
/// difficulty.
class StarRating extends StatelessWidget {
  final int stars;
  final int max;
  final double size;
  final Color? _color;
  Color get color => _color ?? FN.signal;
  final Color? emptyColor;

  const StarRating({
    super.key,
    required this.stars,
    this.max = 5,
    this.size = 14,
    Color? color,
    this.emptyColor,
  }) : _color = color;

  @override
  Widget build(BuildContext context) {
    final empty =
        emptyColor ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);
    return Semantics(
      label: '$stars dari $max bintang',
      child: CustomPaint(
        size: Size(max * size + (max - 1) * size * 0.2, size),
        painter: _StarPainter(stars.clamp(0, max), max, color, empty),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final int stars, max;
  final Color color, empty;
  _StarPainter(this.stars, this.max, this.color, this.empty);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height;
    for (var i = 0; i < max; i++) {
      final c = Offset(i * s * 1.2 + s / 2, s / 2);
      final path = Path();
      for (var k = 0; k < 10; k++) {
        final r = k.isEven ? s / 2 : s / 4.6;
        final a = -math.pi / 2 + k * math.pi / 5;
        final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
        k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      final filled = i < stars;
      canvas.drawPath(
        path,
        Paint()
          ..color = filled ? color : empty
          ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter o) =>
      o.stars != stars || o.color != color || o.empty != empty;
}
