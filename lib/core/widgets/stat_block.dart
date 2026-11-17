import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Mono label + Anton value + mono unit.
class StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final double size;
  final Color? valueColor;
  final Color? labelColor;
  final CrossAxisAlignment align;

  const StatBlock({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.size = 34,
    this.valueColor,
    this.labelColor,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final fg = valueColor ?? Theme.of(context).colorScheme.onSurface;
    final muted = labelColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          FN.caps(label),
          style: FN.label(size: 10, color: muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: size >= 24 ? 6 : 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: align == CrossAxisAlignment.end
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: FN.bigNumber(size, color: fg)),
              if (unit != null && unit!.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  FN.caps(unit!),
                  style: FN.label(
                    size: FN.isClean ? size * 0.3 : size * 0.32,
                    color: muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Grid of stat blocks separated by hairlines (a ledger table).
class StatGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  final Color? _lineColor;
  Color get lineColor => _lineColor ?? FN.ink;
  const StatGrid({
    super.key,
    required this.children,
    this.columns = 2,
    Color? lineColor,
  }) : _lineColor = lineColor;

  @override
  Widget build(BuildContext context) {
    if (FN.isClean) return _clean();
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final cells = <Widget>[];
      for (var c = 0; c < columns; c++) {
        final idx = i + c;
        cells.add(
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
              decoration: BoxDecoration(
                border: Border(
                  left: c == 0
                      ? BorderSide.none
                      : BorderSide(color: lineColor, width: 1),
                ),
              ),
              child: idx < children.length ? children[idx] : const SizedBox(),
            ),
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(Container(height: 1, color: lineColor));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells,
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(border: Border.all(color: lineColor, width: 1)),
      child: Column(children: rows),
    );
  }

  /// Bersih: kisi berjarak lega tanpa garis.
  Widget _clean() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i += columns)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < columns; c++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: i + c < children.length
                          ? children[i + c]
                          : const SizedBox(),
                    ),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}
