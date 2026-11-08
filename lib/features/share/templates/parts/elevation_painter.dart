import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/render/paper_painters.dart';

/// Elevation silhouette painter for widgets. [fill]/[edge] default to
/// `FN.ink`.
class ElevationPainter extends CustomPainter {
  final ShareData data;
  final bool byGrade;
  final Color? fill;
  final Color? edge;
  final bool hatch;
  const ElevationPainter({
    required this.data,
    this.byGrade = true,
    this.fill,
    this.edge,
    this.hatch = true,
  });
  @override
  void paint(Canvas canvas, Size size) {
    paintElevation(
      canvas,
      Offset.zero & size,
      dist: data.dist,
      ele: data.ele,
      grade: data.grade,
      byGrade: byGrade,
      fill: fill ?? FN.ink,
      edge: edge ?? FN.ink,
      hatch: hatch,
    );
  }

  @override
  bool shouldRepaint(ElevationPainter old) => old.data != data;
}
