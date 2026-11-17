import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Big notebook page title: mono kicker, Anton title, ink rule.
class Masthead extends StatelessWidget {
  final String kicker;

  /// Judul besar. `null` = disembunyikan (layar tertanam di tab lain).
  final String? title;
  final String? subtitle;
  final List<Widget> actions;

  const Masthead({
    super.key,
    required this.kicker,
    this.title,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    if (FN.isClean) return _clean(fg);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  FN.caps(kicker),
                  style: FN
                      .label(size: 10, color: FN.signal)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              ...actions,
            ],
          ),
          if (title != null) ...[
            const SizedBox(height: 2),
            Text(
              FN.caps(title!),
              style: TextStyle(
                fontFamily: FN.display,
                fontSize: 52,
                height: 1.0,
                color: fg,
                letterSpacing: 0.5,
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(FN.caps(subtitle!), style: FN.label(size: 10.5)),
          ],
          const SizedBox(height: 10),
          Container(height: 3, color: fg),
          const SizedBox(height: 2),
          Container(height: 1, color: fg),
        ],
      ),
    );
  }

  /// Bersih: kicker abu-abu kecil, judul Plex Sans, tanpa garis ganda.
  Widget _clean(Color fg) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 18, 16, 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(kicker, style: FN.label(size: 11.5))),
            ...actions,
          ],
        ),
        if (title != null) ...[
          const SizedBox(height: 2),
          Text(
            title!,
            style: FN.title(44, color: fg).copyWith(fontSize: 27),
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: FN.label(size: 11)),
        ],
        const SizedBox(height: 8),
      ],
    ),
  );
}
