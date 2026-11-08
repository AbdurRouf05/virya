import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Section header: label, rule, optional trailing text.
class MapPacksSectionTitle extends StatelessWidget {
  const MapPacksSectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(title, style: FN.label(size: 12, color: FN.ink)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: FN.ink, thickness: 1)),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Text(trailing, style: FN.label(size: 12, color: FN.ink)),
        ],
      ]),
    );
  }
}
