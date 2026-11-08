import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Pilihan jatuh tempo: HARI INI · BESOK · NANTI (tanpa tanggal) · TANGGAL.
class TaskDueChips extends StatelessWidget {
  final DateTime? value;
  final DateTime today;
  final ValueChanged<DateTime?> onChanged;

  const TaskDueChips({
    super.key,
    required this.value,
    required this.today,
    required this.onChanged,
  });

  DateTime get _tomorrow => DateTime(today.year, today.month, today.day + 1);

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value != null && !value!.isBefore(today) ? value! : today,
      firstDate: today,
      lastDate: DateTime(today.year + 5, 12, 31),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = value != null && value != today && value != _tomorrow;
    Widget chip(String text, bool selected, VoidCallback onTap) => StampChip(
      text: text,
      fontSize: 10,
      selected: selected,
      onTap: onTap,
    );
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        chip('HARI INI', value == today, () => onChanged(today)),
        chip('BESOK', value == _tomorrow, () => onChanged(_tomorrow)),
        chip('NANTI', value == null, () => onChanged(null)),
        chip(
          isCustom
              ? '${value!.day} ${Fmt.monthsShort[value!.month - 1]}'
                    .toUpperCase()
              : 'TANGGAL',
          isCustom,
          () => _pick(context),
        ),
      ],
    );
  }
}
