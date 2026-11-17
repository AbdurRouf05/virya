import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Memilih awal dan akhir segmen di sepanjang rute, dalam meter.
class SegmentRangePicker extends StatelessWidget {
  static const double nudgeM = 10;

  final double lengthM;
  final RangeValues values;
  final Fmt fmt;
  final ValueChanged<RangeValues> onChanged;

  const SegmentRangePicker({
    super.key,
    required this.lengthM,
    required this.values,
    required this.fmt,
    required this.onChanged,
  });

  void _nudge({double start = 0, double end = 0}) {
    final a = (values.start + start).clamp(0.0, lengthM);
    final b = (values.end + end).clamp(0.0, lengthM);
    if (b > a) onChanged(RangeValues(a, b));
  }

  Widget _stepper(
    String label,
    double value, {
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) => Row(
    children: [
      Expanded(
        child: Text(
          '$label · ${fmt.distanceFull(value, decimals: 2)}',
          style: FN.label(size: 11, color: FN.ink),
        ),
      ),
      InkIconButton(
        icon: Icons.remove,
        tooltip: '$label mundur ${nudgeM.round()} meter',
        size: 36,
        onPressed: onMinus,
      ),
      const SizedBox(width: 8),
      InkIconButton(
        icon: Icons.add,
        tooltip: '$label maju ${nudgeM.round()} meter',
        size: 36,
        onPressed: onPlus,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RangeSlider(
          min: 0,
          max: lengthM,
          values: values,
          activeColor: FN.signal,
          inactiveColor: FN.paperLine,
          onChanged: onChanged,
        ),
        _stepper(
          'Mulai',
          values.start,
          onMinus: () => _nudge(start: -nudgeM),
          onPlus: () => _nudge(start: nudgeM),
        ),
        const SizedBox(height: 8),
        _stepper(
          'Selesai',
          values.end,
          onMinus: () => _nudge(end: -nudgeM),
          onPlus: () => _nudge(end: nudgeM),
        ),
      ],
    );
  }
}
