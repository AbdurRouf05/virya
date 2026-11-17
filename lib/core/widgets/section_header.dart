import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// "01 / RINGKASAN ─────────── trailing"
class SectionHeader extends StatelessWidget {
  final String? number;
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    this.number,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 28, 16, 12),
  });

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    if (FN.isClean) {
      // Bersih: judul kecil abu-abu, tanpa nomor dan tanpa garis.
      return Padding(
        padding: padding,
        child: Row(
          children: [
            Expanded(
              child: Text(
                FN.caps(title),
                style: FN.label(size: 12, color: FN.inkMuted),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      );
    }
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (number != null) ...[
            Text(
              number!,
              style: FN
                  .label(size: 12, color: FN.signal)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            Text(' / ', style: FN.label(size: 12, color: fg)),
          ],
          Flexible(
            child: Text(
              FN.caps(title),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FN
                  .label(size: 12, color: fg)
                  .copyWith(fontWeight: FontWeight.w700, letterSpacing: 2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: fg)),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

/// Auto-incrementing "01", "02"... for screens with optional sections.
class SectionCounter {
  int _n = 0;
  String next() => (++_n).toString().padLeft(2, '0');
}
