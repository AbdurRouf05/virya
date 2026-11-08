import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/calendar/presentation/widgets/calendar_cell_painter.dart';

/// Color key: one swatch per category, a split swatch for CAMPUR, and the
/// TIDAK AKTIF / NANTI states.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final c in SportCategory.values)
          _Item(kind: CellKind.active, parts: [c], text: c.label),
        const _Item(
          kind: CellKind.active,
          parts: [SportCategory.cycling, SportCategory.strength],
          text: 'CAMPUR',
        ),
        const _Item(kind: CellKind.rest, text: 'ISTIRAHAT'),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final CellKind kind;
  final List<SportCategory> parts;
  final String text;

  const _Item({required this.kind, required this.text, this.parts = const []});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(11, 11),
          painter: DayCellPainter(kind: kind, parts: parts),
        ),
        const SizedBox(width: 6),
        Text(text, style: FN.label(size: 9.5, color: FN.inkSoft)),
      ],
    );
  }
}
