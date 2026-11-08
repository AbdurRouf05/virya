import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/focus/domain/focus_logic.dart';

/// Pilih batas menit per hari untuk [label]. Null bila dibatalkan.
Future<int?> showFocusMinutesSheet(
  BuildContext context, {
  required String label,
  int initial = 30,
}) => showModalBottomSheet<int>(
  context: context,
  backgroundColor: FN.paper,
  shape: const RoundedRectangleBorder(),
  isScrollControlled: true,
  builder: (_) => FocusMinutesSheet(label: label, initial: initial),
);

class FocusMinutesSheet extends StatefulWidget {
  final String label;
  final int initial;

  const FocusMinutesSheet({
    super.key,
    required this.label,
    required this.initial,
  });

  @override
  State<FocusMinutesSheet> createState() => _State();
}

class _State extends State<FocusMinutesSheet> {
  static const _presets = [15, 30, 45, 60, 90, 120];
  static const _step = 5;

  late int _minutes = normalizeFocusMinutes(widget.initial);

  void _set(int m) => setState(() => _minutes = normalizeFocusMinutes(m));

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FN.display,
              fontSize: 32,
              height: 1.05,
              color: FN.ink,
            ),
          ),
          Text('BATAS PER HARI', style: FN.label(size: 11)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Kurangi 5 menit',
                onPressed: _minutes <= minFocusMinutes
                    ? null
                    : () => _set(_minutes - _step),
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 150,
                child: Text(
                  formatFocusMinutes(_minutes),
                  textAlign: TextAlign.center,
                  style: FN.bigNumber(30),
                ),
              ),
              IconButton(
                tooltip: 'Tambah 5 menit',
                onPressed: _minutes >= maxFocusMinutes
                    ? null
                    : () => _set(_minutes + _step),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final m in _presets)
                StampChip(
                  text: '$m MNT',
                  fontSize: 10,
                  selected: _minutes == m,
                  onTap: () => _set(m),
                ),
            ],
          ),
          const SizedBox(height: 16),
          InkButton(
            label: 'Simpan',
            style: InkButtonStyle.primary,
            expand: true,
            onPressed: () => Navigator.pop(context, _minutes),
          ),
        ],
      ),
    ),
  );
}
