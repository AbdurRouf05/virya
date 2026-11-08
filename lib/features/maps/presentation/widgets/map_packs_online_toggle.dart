import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_box.dart';

/// Switch: may the map fetch new tiles from the internet (OpenFreeMap)?
class MapPacksOnlineToggle extends StatelessWidget {
  const MapPacksOnlineToggle({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MapPacksBox(
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AMBIL PETA DARI INTERNET', style: FN.label(size: 12, color: FN.ink)),
              const SizedBox(height: 4),
              Text(
                'Matikan untuk hemat kuota: peta hanya memakai cache dan '
                'wilayah yang sudah diunduh.',
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
