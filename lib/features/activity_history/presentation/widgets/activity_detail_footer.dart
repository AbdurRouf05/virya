import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Bottom of the detail page: GPX/TCX export (hidden when the callbacks are
/// null, e.g. gym sessions), delete, record caption.
class ActivityDetailFooter extends StatelessWidget {
  final VoidCallback? onExportGpx;
  final VoidCallback? onExportTcx;
  final VoidCallback onDelete;
  final String caption;
  const ActivityDetailFooter({
    super.key,
    this.onExportGpx,
    this.onExportTcx,
    required this.onDelete,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InkRule(),
          const SizedBox(height: 16),
          if (onExportGpx != null || onExportTcx != null) ...[
            Row(
              children: [
                Expanded(
                  child: InkButton(
                    label: 'Ekspor GPX',
                    icon: Icons.download,
                    expand: true,
                    onPressed: onExportGpx,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkButton(
                    label: 'Ekspor TCX',
                    icon: Icons.download,
                    expand: true,
                    onPressed: onExportTcx,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          InkButton(
            label: 'Hapus aktivitas',
            icon: Icons.delete_outline,
            style: InkButtonStyle.danger,
            expand: true,
            onPressed: onDelete,
          ),
          const SizedBox(height: 16),
          Text(caption, textAlign: TextAlign.center, style: FN.label(size: 9)),
        ],
      ),
    );
  }
}
