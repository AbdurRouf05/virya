import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Label lurus & datar — pengganti semua "stempel". Tanpa rotasi, tanpa border ganda.
class MarkLabel extends StatelessWidget {
  const MarkLabel(
    this.text, {
    super.key,
    Color? color,
    this.filled = true,
    this.fontSize = 11,
  }) : _color = color;

  final String text;
  final Color? _color;
  Color get color => _color ?? FN.signal;
  final bool filled; // true = blok solid, false = garis kiri
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final fg = filled
        ? (color.computeLuminance() > 0.35 ? FN.onAccent : FN.onNight)
        : color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.6,
        vertical: fontSize * 0.3,
      ),
      decoration: filled
          ? BoxDecoration(color: color)
          : BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 3)),
            ),
      child: Text(
        text.toUpperCase(),
        maxLines: 1,
        style: FN
            .label(size: fontSize, color: fg)
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
