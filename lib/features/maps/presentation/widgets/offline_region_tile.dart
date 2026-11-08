import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/offline_maps/map_pack.dart' show formatBytes;
import 'package:virya/core/offline_maps/offline_region.dart';

/// One downloaded region: name, size, date, resume + delete.
class OfflineRegionTile extends StatelessWidget {
  const OfflineRegionTile({
    super.key,
    required this.region,
    required this.onDelete,
    required this.onResume,
  });
  final OfflineRegion region;
  final VoidCallback? onDelete;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM yyyy').format(region.createdAt.toLocal());
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
          color: FN.paper, border: Border.all(color: FN.ink, width: 1.5)),
      child: Row(children: [
        Icon(region.complete ? Icons.download_done : Icons.downloading,
            color: region.complete ? FN.ink : FN.caution),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(region.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: FN.sans, fontWeight: FontWeight.w600, color: FN.ink)),
            const SizedBox(height: 2),
            Text(
              '${formatBytes(region.sizeBytes)} · $date'
              '${region.complete ? '' : ' · BELUM LENGKAP'}',
              style: FN.label(size: 10,
                  color: region.complete ? FN.inkMuted : FN.caution),
            ),
          ]),
        ),
        if (!region.complete)
          IconButton(
            tooltip: 'Lanjutkan unduhan',
            onPressed: onResume,
            icon: Icon(Icons.play_arrow, color: FN.ink),
          ),
        IconButton(
          tooltip: 'Hapus wilayah',
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline, color: FN.warn),
        ),
      ]),
    );
  }
}
