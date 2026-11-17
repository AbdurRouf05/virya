import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Kontrol segmen pilih-satu.
///
/// Tegas: bingkai tinta 2px, segmen aktif blok tinta, label mono kapital.
/// Bersih: lintasan abu-abu dengan pil putih untuk segmen aktif.
class SegmentedPick<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;

  const SegmentedPick({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final clean = FN.isClean;
    return Container(
      height: height,
      padding: EdgeInsets.all(clean ? 3 : 0),
      decoration:
          clean
              ? BoxDecoration(color: FN.fill, borderRadius: FN.smallRadius)
              : BoxDecoration(border: Border.all(color: FN.ink, width: 2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0 && !clean) Container(width: 2, color: FN.ink),
            Expanded(child: _segment(options[i])),
          ],
        ],
      ),
    );
  }

  Widget _segment((T, String) o) {
    final (v, label) = o;
    final selected = v == value;
    final clean = FN.isClean;
    final text = FN.caps(label);
    return Semantics(
      button: true,
      selected: selected,
      label: text,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration:
                clean
                    ? BoxDecoration(
                      color: selected ? FN.cardFill : null,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow:
                          selected
                              ? [
                                BoxShadow(
                                  color: FN.onAccent.withValues(alpha: 0.06),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ]
                              : null,
                    )
                    : BoxDecoration(color: selected ? FN.ink : FN.paper),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                style:
                    clean
                        ? (selected
                            ? FN.heading(size: 13, color: FN.ink)
                            : FN.body(size: 13, color: FN.inkSoft))
                        : FN.labelStrong(
                          size: 11,
                          color: selected ? FN.paper : FN.ink,
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
