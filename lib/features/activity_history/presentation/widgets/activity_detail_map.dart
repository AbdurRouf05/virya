import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/activity_history/application/activity_map_data.dart';

/// Framed route map, colour-mode chips and share / flyover buttons.
class ActivityDetailMap extends StatelessWidget {
  final Widget map;
  final MapColorMode mode;
  final ValueChanged<MapColorMode> onModeChanged;
  final VoidCallback onShare;
  final VoidCallback onFlyover;
  const ActivityDetailMap({
    super.key,
    required this.map,
    required this.mode,
    required this.onModeChanged,
    required this.onShare,
    required this.onFlyover,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: FN.ink, width: 1.5),
            ),
            child: ClipRect(child: map),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final m in MapColorMode.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: StampChip(
                    text: m.label,
                    fontSize: 10,
                    selected: mode == m,
                    onTap: () => onModeChanged(m),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: InkButton(
                  label: 'Bagikan',
                  icon: Icons.ios_share,
                  style: InkButtonStyle.primary,
                  expand: true,
                  onPressed: onShare,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkButton(
                  label: 'Flyover 3D',
                  icon: Icons.threed_rotation,
                  expand: true,
                  onPressed: onFlyover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
