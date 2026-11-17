import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Pilihan jatuh tempo: HARI INI · BESOK · NANTI (tanpa tanggal) · TANGGAL,
/// plus TIAP HARI (rutinitas) bila [onRepeat] diisi.
class TaskDueChips extends StatelessWidget {
  final DateTime? value;
  final DateTime today;
  final ValueChanged<DateTime?> onChanged;

  /// Rutinitas harian dipilih; tanggal diabaikan.
  final bool repeat;
  final ValueChanged<bool>? onRepeat;

  const TaskDueChips({
    super.key,
    required this.value,
    required this.today,
    required this.onChanged,
    this.repeat = false,
    this.onRepeat,
  });

  void _choose(DateTime? d) {
    onRepeat?.call(false);
    onChanged(d);
  }

  DateTime get _tomorrow => DateTime(today.year, today.month, today.day + 1);

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value != null && !value!.isBefore(today) ? value! : today,
      firstDate: today,
      lastDate: DateTime(today.year + 5, 12, 31),
    );
    if (picked != null) _choose(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isCustom =
        !repeat && value != null && value != today && value != _tomorrow;
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
        chip(FN.caps('Hari ini'), !repeat && value == today, () => _choose(today)),
        chip(FN.caps('Besok'), !repeat && value == _tomorrow, () => _choose(_tomorrow)),
        chip(FN.caps('Nanti'), !repeat && value == null, () => _choose(null)),
        chip(
          isCustom
              ? FN.caps('${value!.day} ${Fmt.monthsShort[value!.month - 1]}')
              : FN.caps('Tanggal'),
          isCustom,
          () => _pick(context),
        ),
        if (onRepeat != null)
          chip(FN.caps('Tiap hari'), repeat, () => onRepeat!(true)),
      ],
    );
  }
}
