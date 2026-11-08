import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Bordered mono text like an ink stamp. Selectable for filters.
class StampChip extends StatelessWidget {
  final String text;
  final bool selected;
  final Color? _color;
  Color get color => _color ?? FN.ink;
  final VoidCallback? onTap;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StampChip({
    super.key,
    required this.text,
    this.selected = false,
    Color? color,
    this.onTap,
    this.icon,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  }) : _color = color;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final fg = selected ? bg : color;
    return Semantics(
      button: onTap != null,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: padding,
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: fontSize + 3, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                text.toUpperCase(),
                style: FN
                    .label(size: fontSize, color: fg)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
