import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_chip.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_gradient.dart';

/// Flyover header: back, activity title and the 2D/3D toggle.
class FlyoverTopBar extends StatelessWidget {
  const FlyoverTopBar({
    super.key,
    required this.title,
    required this.is3d,
    required this.busy,
    required this.onToggle3d,
  });
  final String title;
  final bool is3d;

  /// True while exporting: back and 3D toggle are disabled.
  final bool busy;
  final VoidCallback onToggle3d;

  @override
  Widget build(BuildContext context) => FlyoverGradient(
        top: true,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 18),
            child: Row(
              children: [
                BackButton(
                  color: FN.paper,
                  onPressed: busy ? null : () => Navigator.maybePop(context),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VIRYA // FLYOVER',
                        style: FN.label(size: 10, color: FN.acid),
                      ),
                      Text(
                        title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FN.bigNumber(22, color: FN.paper),
                      ),
                    ],
                  ),
                ),
                FlyoverChip(
                  is3d ? '3D' : '2D',
                  selected: true,
                  onTap: busy ? null : onToggle3d,
                ),
              ],
            ),
          ),
        ),
      );
}
