import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Baris template: nama gerakan, stepper set × reps, hapus, pegangan geser.
class GymTemplateItemRow extends StatelessWidget {
  final int index;
  final String name;
  final int sets;
  final int reps;
  final ValueChanged<int> onSets;
  final ValueChanged<int> onReps;
  final VoidCallback onRemove;

  const GymTemplateItemRow({
    super.key,
    required this.index,
    required this.name,
    required this.sets,
    required this.reps,
    required this.onSets,
    required this.onReps,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      decoration: BoxDecoration(
        color: FN.paper,
        border: Border.all(color: FN.ink, width: 1.5),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_indicator, color: FN.inkMuted),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FN.sans,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: FN.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _stepper('SET', sets, 1, 20, onSets),
                    const SizedBox(width: 12),
                    _stepper('REPS', reps, 1, 100, onReps),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Hapus',
            icon: Icon(Icons.close, color: FN.inkSoft),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _stepper(String label, int v, int min, int max, ValueChanged<int> on) {
    Widget btn(IconData i, int next) => InkWell(
      onTap: next < min || next > max ? null : () => on(next),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: FN.ink)),
        child: Icon(i, size: 16, color: FN.ink),
      ),
    );
    return Row(
      children: [
        Text(label, style: FN.label(size: 9.5)),
        const SizedBox(width: 6),
        btn(Icons.remove, v - 1),
        SizedBox(
          width: 34,
          child: Text(
            '$v',
            textAlign: TextAlign.center,
            style: FN.bigNumber(18, color: FN.ink),
          ),
        ),
        btn(Icons.add, v + 1),
      ],
    );
  }
}
