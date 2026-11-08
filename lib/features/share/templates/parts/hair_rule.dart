import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Thin horizontal rule. [color] defaults to `FN.ink`.
class HairRule extends StatelessWidget {
  final Color? color;
  final double thickness;
  const HairRule({super.key, this.color, this.thickness = 0.8});
  @override
  Widget build(BuildContext context) =>
      Container(height: thickness, color: color ?? FN.ink);
}
