import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/offline_maps/map_pack_repository.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_box.dart';

/// Shows which basemap / terrain pack is currently active.
class MapPacksActiveCard extends StatelessWidget {
  const MapPacksActiveCard({super.key, required this.state});
  final MapPacksState state;

  @override
  Widget build(BuildContext context) {
    Widget row(String k, String? v, String empty) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(width: 92, child: Text(k, style: FN.label())),
            Expanded(
              child: Text(v ?? empty,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: FN.mono,
                      fontSize: 13,
                      color: v == null ? FN.inkMuted : FN.ink,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        );
    return MapPacksBox(
      color: FN.paperDeep,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        row('BASEMAP', state.activeBasemap, '— otomatis / tidak ada'),
        row('TERRAIN', state.activeDem, '— otomatis / tidak ada (3D datar)'),
      ]),
    );
  }
}
