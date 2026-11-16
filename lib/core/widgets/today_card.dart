import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Kartu Hari Ini: bingkai tinta 2px, baris judul mono + teks kanan opsional.
class TodayCard extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;
  final VoidCallback? onTap;

  const TodayCard({
    super.key,
    required this.title,
    this.trailing,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = FN.isClean ? _clean() : _tegas();
    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }

  /// Bersih: kartu putih bergaris rambut, judul kecil abu-abu tanpa garis.
  Widget _clean() => Container(
    clipBehavior: Clip.antiAlias,
    decoration: FN.card(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
          child: Row(
            children: [
              Expanded(child: Text(FN.caps(title), style: FN.label(size: 11))),
              if (trailing != null)
                Text(FN.caps(trailing!), style: FN.label(size: 10.5)),
            ],
          ),
        ),
        child,
      ],
    ),
  );

  Widget _tegas() {
    return Container(
      decoration: BoxDecoration(
        color: FN.paper,
        border: Border.all(color: FN.ink, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    FN.caps(title),
                    style: FN
                        .label(size: 11, color: FN.ink)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (trailing != null)
                  Text(
                    FN.caps(trailing!),
                    style: FN.label(size: 10.5, color: FN.ink),
                  ),
              ],
            ),
          ),
          Container(height: 2, color: FN.ink),
          child,
        ],
      ),
    );
  }
}
