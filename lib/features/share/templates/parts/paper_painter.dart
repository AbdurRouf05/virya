import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/render/paper_painters.dart';

/// Paper background: fill, contours, grain. [fill] defaults to `FN.paper`,
/// [contour] to `FN.paperLine`.
class PaperPainter extends CustomPainter {
  final int seed;
  final Color? fill;
  final Color? contour;
  final Color? indexContour;
  final bool grain;
  final Color grainDark;
  final Color grainLight;
  const PaperPainter({
    required this.seed,
    this.fill,
    this.contour,
    this.indexContour,
    this.grain = true,
    this.grainDark = const Color(0x1E141414),
    this.grainLight = const Color(0x40FFFFFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, Paint()..color = fill ?? FN.paper);
    paintContours(
      canvas,
      r,
      seed: seed,
      color: contour ?? FN.paperLine,
      indexColor: indexContour,
      width: 0.6,
    );
    if (grain) {
      paintGrain(
        canvas,
        r,
        seed: seed + 3,
        dark: grainDark,
        light: grainLight,
        density: 0.09,
      );
    }
  }

  @override
  bool shouldRepaint(PaperPainter old) =>
      old.seed != seed || old.fill != fill || old.contour != contour;
}
