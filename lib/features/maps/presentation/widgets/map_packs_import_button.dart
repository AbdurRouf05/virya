import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_box.dart';

/// Import button, or a progress box while a pack is being copied.
class MapPacksImportButton extends StatelessWidget {
  const MapPacksImportButton({
    super.key,
    required this.progress,
    required this.fileName,
    required this.onImport,
  });

  /// Null = idle.
  final double? progress;
  final String? fileName;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final prog = progress;
    if (prog != null) {
      return MapPacksBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MENYALIN ${fileName ?? ''}'.toUpperCase(),
              overflow: TextOverflow.ellipsis, style: FN.label(size: 11, color: FN.ink)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: prog > 0 ? prog : null,
            minHeight: 6,
            color: FN.signal,
            backgroundColor: FN.paperDeep,
          ),
          const SizedBox(height: 6),
          Text('${(prog * 100).toStringAsFixed(0)}%', style: FN.bigNumber(22)),
        ]),
      );
    }
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: FN.ink,
          foregroundColor: FN.paper,
          shape: const RoundedRectangleBorder(),
        ),
        onPressed: onImport,
        icon: const Icon(Icons.file_download_outlined),
        label: Text('IMPOR FILE .PMTILES', style: FN.label(size: 13, color: FN.paper)),
      ),
    );
  }
}
