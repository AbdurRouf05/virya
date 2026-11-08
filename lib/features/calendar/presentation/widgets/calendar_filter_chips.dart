import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/sport_category.dart';

/// SEMUA · SEPEDA · LARI · JALAN · GYM. Each category chip carries a small
/// color square; the selected chip is ink-filled.
class CalendarFilterChips extends StatelessWidget {
  final SportCategory? selected;
  final ValueChanged<SportCategory?> onSelect;

  const CalendarFilterChips({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            text: 'SEMUA',
            on: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final c in SportCategory.values)
            _Chip(
              text: c.label,
              swatch: FN.category(c),
              on: selected == c,
              onTap: () => onSelect(c),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color? swatch;
  final bool on;
  final VoidCallback onTap;

  const _Chip({
    required this.text,
    required this.on,
    required this.onTap,
    this.swatch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: on,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: on ? FN.ink : null,
              border: Border.all(color: FN.ink, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (swatch != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: swatch,
                      border: on ? Border.all(color: FN.paper) : null,
                    ),
                  ),
                  const SizedBox(width: 7),
                ],
                Text(
                  text,
                  style: FN
                      .label(size: 11, color: on ? FN.paper : FN.ink)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
