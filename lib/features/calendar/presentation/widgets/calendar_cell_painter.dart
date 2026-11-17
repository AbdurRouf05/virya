import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/calendar/domain/calendar_cell.dart';

export 'package:virya/features/calendar/domain/calendar_cell.dart';

/// Paints one day square: category fill (full / diagonal split / quadrants)
/// at [alpha], rest-day tint, future outline, optional [outline] border.
/// Square corners only.
void paintDayCell(
  Canvas canvas,
  Rect r, {
  required CellKind kind,
  List<SportCategory> parts = const [],
  double alpha = 1,
  Color? outline,
  double outlineWidth = 1.5,
}) {
  switch (kind) {
    case CellKind.outside:
      return;
    case CellKind.future:
      canvas.drawRect(
        r.deflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = FN.paperLine,
      );
    case CellKind.rest:
      canvas.drawRect(r, Paint()..color = FN.paperDeep);
    case CellKind.active:
      _paintParts(canvas, r, parts, alpha);
  }
  if (outline != null) {
    canvas.drawRect(
      r.deflate(outlineWidth / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth
        ..color = outline,
    );
  }
}

void _paintParts(
  Canvas canvas,
  Rect r,
  List<SportCategory> parts,
  double alpha,
) {
  Paint p(SportCategory c) =>
      Paint()..color = FN.category(c).withValues(alpha: alpha);
  if (parts.isEmpty) return;
  if (parts.length == 1) {
    canvas.drawRect(r, p(parts[0]));
    return;
  }
  if (parts.length == 2) {
    // Top-left triangle = first, bottom-right triangle = second.
    canvas.drawPath(
      Path()
        ..moveTo(r.left, r.top)
        ..lineTo(r.right, r.top)
        ..lineTo(r.left, r.bottom)
        ..close(),
      p(parts[0]),
    );
    canvas.drawPath(
      Path()
        ..moveTo(r.right, r.top)
        ..lineTo(r.right, r.bottom)
        ..lineTo(r.left, r.bottom)
        ..close(),
      p(parts[1]),
    );
    return;
  }
  final c = r.center;
  final quads = [
    Rect.fromPoints(r.topLeft, c),
    Rect.fromPoints(Offset(c.dx, r.top), Offset(r.right, c.dy)),
    Rect.fromPoints(Offset(r.left, c.dy), Offset(c.dx, r.bottom)),
    Rect.fromPoints(c, r.bottomRight),
  ];
  for (var i = 0; i < 4 && i < parts.length; i++) {
    canvas.drawRect(quads[i], p(parts[i]));
  }
}

/// Single-cell painter for widget-sized squares (month grid, legend).
class DayCellPainter extends CustomPainter {
  final CellKind kind;
  final List<SportCategory> parts;
  final double alpha;
  final Color? outline;
  final double outlineWidth;

  DayCellPainter({
    required this.kind,
    this.parts = const [],
    this.alpha = 1,
    this.outline,
    this.outlineWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) => paintDayCell(
    canvas,
    Offset.zero & size,
    kind: kind,
    parts: parts,
    alpha: alpha,
    outline: outline,
    outlineWidth: outlineWidth,
  );

  @override
  bool shouldRepaint(DayCellPainter old) =>
      old.kind != kind ||
      old.alpha != alpha ||
      old.outline != outline ||
      old.outlineWidth != outlineWidth ||
      !_sameParts(old.parts, parts);

  static bool _sameParts(List<SportCategory> a, List<SportCategory> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
