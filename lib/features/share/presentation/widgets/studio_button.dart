import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Studio action button; disabled (dimmed) when [onTap] is null.
class StudioButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback? onTap;
  const StudioButton({super.key, required this.label, this.primary = false, this.onTap});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary ? FN.signal : Colors.transparent,
              border: Border.all(color: primary ? FN.signal : FN.paper, width: 1.4),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  style: FN.label(size: 11, color: primary ? FN.ink : FN.paper)
                      .copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.6),
                ),
              ),
            ),
          ),
        ),
      );
}
