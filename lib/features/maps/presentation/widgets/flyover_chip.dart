import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Small outlined toggle chip used in the flyover controls.
class FlyoverChip extends StatelessWidget {
  const FlyoverChip(this.label, {super.key, required this.selected, this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? FN.paper : Colors.transparent,
            border: Border.all(color: FN.paper, width: 1.2),
          ),
          child: Text(
            label,
            style: FN.label(size: 11, color: selected ? FN.night : FN.paper),
          ),
        ),
      );
}
