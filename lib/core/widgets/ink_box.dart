import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Hairline ink frame. Optional hard (unblurred) offset shadow like a
/// printed block.
class InkBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? _borderColor;
  Color get borderColor => _borderColor ?? FN.ink;
  final double borderWidth;
  final bool hardShadow;
  final Color? _shadowColor;
  Color get shadowColor => _shadowColor ?? FN.ink;
  final VoidCallback? onTap;

  const InkBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.color,
    Color? borderColor,
    this.borderWidth = 1,
    this.hardShadow = false,
    Color? shadowColor,
    this.onTap,
  }) : _shadowColor = shadowColor,
       _borderColor = borderColor;

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
  final Color? _color;
  Color get color => _color ?? FN.ink;
  final double thickness;
  const InkRule({
    super.key,
    this.dashed = false,
    Color? color,
    this.thickness = 1,
  }) : _color = color;

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
