import 'package:flutter/material.dart';
import 'package:virya/app/theme/export_tokens.dart';

/// Anton poster numeral that shrinks to fit. [color] defaults to `FNExport.ink`.
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
      style: FNExport
          .bigNumber(size, color: color ?? FNExport.ink)
          .copyWith(height: 0.9, shadows: shadows),
    ),
  );
}
