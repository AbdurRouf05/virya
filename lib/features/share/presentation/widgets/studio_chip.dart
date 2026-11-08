import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Selectable option chip, optionally with a color swatch.
class StudioChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? swatch;
  const StudioChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.swatch,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? FN.onNight : Colors.transparent,
            border: Border.all(color: selected ? FN.onNight : FN.nightLine),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (swatch != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: swatch,
                  border: Border.all(color: FN.inkMuted, width: 0.5),
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: FN.label(size: 9.5, color: selected ? FN.onAccent : FN.onNight)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      );
}
