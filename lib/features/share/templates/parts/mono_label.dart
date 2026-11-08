import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Mono uppercase label. [color] defaults to `FN.inkMuted`.
class MonoLabel extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  final FontWeight weight;
  final double spacing;
  final TextAlign? align;
  const MonoLabel(
    this.text, {
    super.key,
    this.size = 8,
    this.color,
    this.weight = FontWeight.w500,
    this.spacing = 1.4,
    this.align,
  });

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    textAlign: align,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    softWrap: false,
    style: TextStyle(
      fontFamily: FN.mono,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color ?? FN.inkMuted,
      height: 1.15,
    ),
  );
}
