import 'package:flutter/material.dart';
import 'package:virya/features/share/render/paper_painters.dart';

/// Grain overlay only (on top of photos/content).
class GrainPainter extends CustomPainter {
  final int seed;
  final double density;
  final Color dark;
  final Color light;
  const GrainPainter({
    required this.seed,
    this.density = 0.12,
    this.dark = const Color(0x30000000),
    this.light = const Color(0x30FFFFFF),
  });
  @override
  void paint(Canvas canvas, Size size) => paintGrain(
    canvas,
    Offset.zero & size,
    seed: seed,
    density: density,
    dark: dark,
    light: light,
    dot: 0.8,
  );
  @override
  bool shouldRepaint(GrainPainter old) => old.seed != seed;
}
