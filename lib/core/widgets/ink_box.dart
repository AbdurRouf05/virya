import 'package:flutter/material.dart';
import 'package:stravo/app/theme/field_notes.dart';

/// Hairline ink frame. Optional hard (unblurred) offset shadow like a
/// printed block.
class InkBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color borderColor;
  final double borderWidth;
  final bool hardShadow;
  final Color shadowColor;
  final VoidCallback? onTap;

  const InkBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.color,
    this.borderColor = FN.ink,
    this.borderWidth = 1,
    this.hardShadow = false,
    this.shadowColor = FN.ink,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: hardShadow
            ? [BoxShadow(color: shadowColor, offset: const Offset(3, 3))]
            : null,
      ),
      child: child,
    );
    if (onTap != null) {
      box = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: box,
      );
    }
    return box;
  }
}

/// 1px ink rule; dashed variant for notebook separators.
class InkRule extends StatelessWidget {
  final bool dashed;
  final Color color;
  final double thickness;
  const InkRule(
      {super.key, this.dashed = false, this.color = FN.ink, this.thickness = 1});

  @override
  Widget build(BuildContext context) {
    if (!dashed) return Container(height: thickness, color: color);
    return SizedBox(
      height: thickness,
      width: double.infinity,
      child: CustomPaint(painter: _DashPainter(color, thickness)),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  final double t;
  _DashPainter(this.color, this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = t;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, t / 2), Offset(x + 3.5, t / 2), p);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
