import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Hairline-ruled settings row.
class SettingRow extends StatelessWidget {
  final String title;
  final String? note;
  final Widget? trailing;
  final Widget? below;
  const SettingRow({
    super.key,
    required this.title,
    this.note,
    this.trailing,
    this.below,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: FN.paperLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: FN.sans,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: FN.ink,
                      ),
                    ),
                    if (note != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(note!, style: FN.label(size: 9.5)),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (below != null) ...[const SizedBox(height: 8), below!],
        ],
      ),
    );
  }
}
