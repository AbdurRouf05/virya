import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Night scrim behind the top bar ([top]) or the bottom HUD.
class FlyoverGradient extends StatelessWidget {
  const FlyoverGradient({super.key, required this.top, required this.child});
  final bool top;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: top ? Alignment.topCenter : Alignment.bottomCenter,
            end: top ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [
              FN.night.withValues(alpha: .94),
              FN.night.withValues(alpha: top ? 0 : .80),
              if (!top) FN.night.withValues(alpha: 0),
            ],
          ),
        ),
        child: child,
      );
}
