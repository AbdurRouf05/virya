import 'package:flutter/material.dart';
import 'package:stravo/app/theme/field_notes.dart';

/// Big notebook page title: mono kicker, Anton title, ink rule.
class Masthead extends StatelessWidget {
  final String kicker;
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  const Masthead({
    super.key,
    required this.kicker,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Text(kicker.toUpperCase(),
                  style: FN.label(size: 10, color: FN.signal)
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
            ...actions,
          ]),
          const SizedBox(height: 2),
          Text(title.toUpperCase(),
              style: TextStyle(
                  fontFamily: FN.display,
                  fontSize: 52,
                  height: 1.0,
                  color: fg,
                  letterSpacing: 0.5)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!.toUpperCase(), style: FN.label(size: 10.5)),
          ],
          const SizedBox(height: 10),
          Container(height: 3, color: fg),
          const SizedBox(height: 2),
          Container(height: 1, color: fg),
        ],
      ),
    );
  }
}
