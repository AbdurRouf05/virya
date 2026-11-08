import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Saklar segmen bertinta: "01 JURNAL | 02 STATISTIK".
class TrainingSwitch extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  const TrainingSwitch({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(border: Border.all(color: FN.ink, width: 2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) Container(width: 2, color: FN.ink),
            Expanded(child: _segment(i)),
          ],
        ],
      ),
    );
  }

  Widget _segment(int i) {
    final selected = i == index;
    return Semantics(
      button: true,
      selected: selected,
      label: labels[i],
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: selected ? FN.ink : FN.paper,
          alignment: Alignment.center,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${(i + 1).toString().padLeft(2, '0')}  ',
                  style: FN.label(
                    size: 9,
                    color: selected ? FN.signal : FN.inkMuted,
                  ),
                ),
                TextSpan(
                  text: labels[i],
                  style: FN
                      .label(size: 11, color: selected ? FN.paper : FN.ink)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
