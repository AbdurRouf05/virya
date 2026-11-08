import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Labelled, horizontally scrolling row of studio options.
class StudioRow extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const StudioRow({super.key, required this.label, required this.children});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(
            width: 52,
            child: Text(label, style: FN.label(size: 9, color: FN.inkMuted)),
          ),
          Expanded(
            child: SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: children,
              ),
            ),
          ),
        ]),
      );
}
