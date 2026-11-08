import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Overflow menu on the detail app bar. Emits 'edit', 'gpx', 'tcx', 'delete'.
class ActivityDetailMenu extends StatelessWidget {
  final ValueChanged<String> onSelected;
  const ActivityDetailMenu({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Menu (ubah, ekspor GPX/TCX, hapus)',
      onSelected: onSelected,
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('Ubah catatan')),
        const PopupMenuItem(value: 'gpx', child: Text('Ekspor GPX')),
        const PopupMenuItem(value: 'tcx', child: Text('Ekspor TCX')),
        PopupMenuItem(
          value: 'delete',
          child: Text('Hapus', style: TextStyle(color: FN.warn)),
        ),
      ],
    );
  }
}
