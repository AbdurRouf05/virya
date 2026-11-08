import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Anton poster numeral that shrinks to fit. [color] defaults to `FN.ink`.
class PosterNumber extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  final List<Shadow>? shadows;
  final Alignment alignment;
  const PosterNumber(
    this.text, {
    super.key,
    required this.size,
    this.color,
    this.shadows,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: alignment,
    child: Text(
      text,
      maxLines: 1,
      style: FN
          .bigNumber(size, color: color ?? FN.ink)
          .copyWith(height: 0.9, shadows: shadows),
    ),
  );
}
