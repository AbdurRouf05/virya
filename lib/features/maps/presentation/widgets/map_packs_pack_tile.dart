import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/offline_maps/map_pack.dart';

/// UI label for a pack type.
String mapPackTypeLabel(MapPackType t) => switch (t) {
      MapPackType.basemap => 'BASEMAP',
      MapPackType.dem => 'TERRAIN',
      MapPackType.unknown => 'TAK DIKENAL',
    };

/// One installed pack row: type badge, name/meta, activate + delete.
class MapPacksPackTile extends StatelessWidget {
  const MapPacksPackTile({
    super.key,
    required this.pack,
    required this.active,
    required this.onActivate,
    required this.onDelete,
  });
  final MapPack pack;
  final bool active;
  final VoidCallback onActivate;

  /// Null disables the delete button (e.g. while importing).
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final p = pack;
    final h = p.header;
    final meta = [
      formatBytes(p.sizeBytes),
      if (h != null) 'z${h.minZoom}–${h.maxZoom}',
      if (h != null) h.tileType.name.toUpperCase(),
    ].join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: active ? FN.ink : FN.paper,
        border: Border.all(color: FN.ink, width: 1.5),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          color: p.type == MapPackType.dem
              ? FN.ok
              : p.type == MapPackType.basemap
                  ? FN.signal
                  : FN.inkMuted,
          child: Text(mapPackTypeLabel(p.type), style: FN.label(size: 9, color: FN.paper)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.fileName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: FN.mono,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? FN.paper : FN.ink)),
            const SizedBox(height: 2),
            Text(meta, style: FN.label(size: 10, color: active ? FN.paperLine : FN.inkMuted)),
          ]),
        ),
        if (p.type != MapPackType.unknown)
          TextButton(
            onPressed: onActivate,
            child: Text(active ? 'AKTIF ✓' : 'AKTIFKAN',
                style: FN.label(size: 10, color: active ? FN.acid : FN.ink)),
          ),
        IconButton(
          tooltip: 'Hapus',
          icon: Icon(Icons.delete_outline, color: active ? FN.paper : FN.ink),
          onPressed: onDelete,
        ),
      ]),
    );
  }
}
