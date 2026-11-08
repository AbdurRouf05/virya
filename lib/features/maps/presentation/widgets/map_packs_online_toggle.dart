import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_box.dart';

/// Switch for the online (OpenFreeMap) fallback basemap.
class MapPacksOnlineToggle extends StatelessWidget {
  const MapPacksOnlineToggle({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MapPacksBox(
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PETA ONLINE CADANGAN', style: FN.label(size: 12, color: FN.ink)),
              const SizedBox(height: 4),
              Text(
                'Bila belum ada basemap offline dan perangkat online, pakai '
                'OpenFreeMap (gaya Field Notes).',
                style: TextStyle(
                    fontFamily: FN.sans, fontSize: 12, color: FN.inkSoft, height: 1.35),
              ),
            ]),
          ),
          Switch(
            value: value,
            activeThumbColor: FN.paper,
            activeTrackColor: FN.signal,
            inactiveThumbColor: FN.inkMuted,
            inactiveTrackColor: FN.paperDeep,
            onChanged: onChanged,
          ),
        ]),
      );
}
