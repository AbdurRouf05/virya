import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/offline_maps/map_pack.dart' show formatBytes;
import 'package:virya/features/maps/application/region_download_controller.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_box.dart';

/// Progress of the running region download with a cancel button.
class RegionDownloadProgressCard extends StatelessWidget {
  const RegionDownloadProgressCard({super.key, required this.state, required this.onCancel});
  final RegionDownloadState state;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final p = state.progress;
    return MapPacksBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MENGUNDUH ${state.region.name}'.toUpperCase(),
            overflow: TextOverflow.ellipsis, style: FN.label(size: 11, color: FN.ink)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: p.done > 0 ? p.fraction : null,
          minHeight: 6,
          color: FN.signal,
          backgroundColor: FN.paperDeep,
        ),
        const SizedBox(height: 6),
        Row(children: [
          Text('${(p.fraction * 100).toStringAsFixed(0)}%', style: FN.bigNumber(22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${p.done}/${p.total} ubin · ${formatBytes(p.bytes)}'
              '${p.failed > 0 ? ' · ${p.failed} gagal' : ''}',
              style: FN.label(size: 10),
            ),
          ),
          TextButton(
            onPressed: state.cancelling ? null : onCancel,
            child: Text(state.cancelling ? 'MENGHENTIKAN…' : 'BATAL',
                style: FN.label(size: 11, color: FN.warn)),
          ),
        ]),
      ]),
    );
  }
}
