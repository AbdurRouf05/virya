import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Full-width bordered box used across the map packs screen.
class MapPacksBox extends StatelessWidget {
  const MapPacksBox({super.key, required this.child, this.color});
  final Widget child;

  /// Defaults to [FN.paper].
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: color ?? FN.paper, border: Border.all(color: FN.ink, width: 1.5)),
        child: child,
      );
}
