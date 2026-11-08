import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/calendar/application/calendar_controller.dart';

/// Kicker "KONSISTENSI · 2026", Anton title and the TAHUN/BULAN toggle.
class CalendarHeader extends StatelessWidget {
  final int year;
  final CalendarView view;
  final ValueChanged<CalendarView> onView;

  const CalendarHeader({
    super.key,
    required this.year,
    required this.view,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KONSISTENSI · $year',
                style: FN.label(size: 11, color: FN.inkSoft),
              ),
              const SizedBox(height: 2),
              Text(
                'KALENDER',
                style: TextStyle(
                  fontFamily: FN.display,
                  fontSize: 48,
                  height: 1.0,
                  color: FN.ink,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            border: Border.all(color: FN.ink, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Seg(
                text: 'TAHUN',
                on: view == CalendarView.year,
                onTap: () => onView(CalendarView.year),
              ),
              _Seg(
                text: 'BULAN',
                on: view == CalendarView.month,
                onTap: () => onView(CalendarView.month),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Seg extends StatelessWidget {
  final String text;
  final bool on;
  final VoidCallback onTap;

  const _Seg({required this.text, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: on,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          color: on ? FN.ink : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            text,
            style: FN
                .label(size: 11, color: on ? FN.paper : FN.ink)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
