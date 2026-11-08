import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Kartu pesan di atas peta: jalur kosong atau gagal dihitung.
class HeatmapNote extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const HeatmapNote({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FN.paper,
          border: Border.all(color: FN.ink, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: FN.label(size: 14, color: FN.ink),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FN.sans,
                fontSize: 14,
                color: FN.inkSoft,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              InkButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
