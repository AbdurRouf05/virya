import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/offline_maps/map_pack.dart' show formatBytes;
import 'package:virya/core/offline_maps/offline_tiles.dart';
import 'package:virya/features/maps/data/offline_map_providers.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_box.dart';

/// "ONLINE · cache 120 MB" + clear-cache action + GPS reassurance.
class OfflineMapStatusCard extends StatelessWidget {
  const OfflineMapStatusCard({super.key, required this.status, required this.onClearCache});
  final OfflineMapStatus status;
  final VoidCallback? onClearCache;

  @override
  Widget build(BuildContext context) {
    final cap = formatBytes(OfflineTiles.defaultCacheMaxBytes);
    final small = TextStyle(fontFamily: FN.sans, fontSize: 12, color: FN.inkSoft, height: 1.35);
    return MapPacksBox(
      color: FN.paperDeep,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(status.online ? Icons.wifi : Icons.wifi_off, size: 18,
              color: status.online ? FN.ok : FN.inkMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${status.online ? 'ONLINE' : 'OFFLINE'} · CACHE ${formatBytes(status.cacheBytes)}',
              style: FN.label(size: 13, color: FN.ink),
            ),
          ),
          TextButton(
            onPressed: status.cacheBytes > 0 ? onClearCache : null,
            child: Text('HAPUS CACHE',
                style: FN.label(size: 11,
                    color: status.cacheBytes > 0 ? FN.warn : FN.inkMuted)),
          ),
        ]),
        const SizedBox(height: 4),
        Text(
          status.online
              ? 'Peta tampil otomatis dari internet. Area yang pernah dilihat '
                  'disimpan (maks $cap) agar bisa dibuka lagi tanpa sinyal.'
              : 'Tanpa internet: yang tampil hanya area yang pernah dilihat '
                  'dan wilayah yang sudah diunduh.',
          style: small,
        ),
        const SizedBox(height: 6),
        Text('Rekam GPS tetap jalan tanpa internet.',
            style: small.copyWith(color: FN.ink, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
