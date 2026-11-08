import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Overflow menu on the detail app bar. Emits 'edit', 'gpx', 'tcx', 'delete'
/// ('gpx'/'tcx' only when [exports] is true).
class ActivityDetailMenu extends StatelessWidget {
  final ValueChanged<String> onSelected;
  final bool exports;
  const ActivityDetailMenu({
    super.key,
    required this.onSelected,
    this.exports = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Menu (ubah, ekspor GPX/TCX, hapus)',
      onSelected: onSelected,
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('Ubah catatan')),
        if (exports) ...[
          const PopupMenuItem(value: 'gpx', child: Text('Ekspor GPX')),
          const PopupMenuItem(value: 'tcx', child: Text('Ekspor TCX')),
        ],
        PopupMenuItem(
          value: 'delete',
          child: Text('Hapus', style: TextStyle(color: FN.warn)),
        ),
      ],
    );
  }
}
