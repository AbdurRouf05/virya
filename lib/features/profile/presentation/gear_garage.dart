import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/profile/data/gear_providers.dart';
import 'package:virya/features/profile/presentation/widgets/gear_garage_add_dialog.dart';
import 'package:virya/features/profile/presentation/widgets/gear_garage_card.dart';

/// Bikes & shoes: add, retire, set default, service reminder.
class GearGarage extends ConsumerStatefulWidget {
  const GearGarage({super.key});

  @override
  ConsumerState<GearGarage> createState() => _GearGarageState();
}

class _GearGarageState extends ConsumerState<GearGarage> {
  bool _showRetired = false;

  @override
  Widget build(BuildContext context) {
    final gears = ref.watch(allGearsProvider).valueOrNull ?? const <Gear>[];
    final dist = ref.watch(gearDistanceProvider).valueOrNull ?? const {};
    final visible = gears.where((g) => _showRetired || !g.isRetired).toList();
    final retiredCount = gears.where((g) => g.isRetired).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Garasi kosong. Tambahkan sepeda atau sepatu untuk '
                'mencatat odometer & jadwal servis.',
                style: FN.label(size: 11),
              ),
            ),
          for (final g in visible)
            GearCard(gear: g, distanceM: dist[g.id] ?? 0),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: InkButton(
                  label: 'Tambah gear',
                  icon: Icons.add,
                  style: InkButtonStyle.ink,
                  expand: true,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const AddGearDialog(),
                  ),
                ),
              ),
              if (retiredCount > 0) ...[
                const SizedBox(width: 10),
                StampChip(
                  text: 'Pensiun ($retiredCount)',
                  selected: _showRetired,
                  onTap: () => setState(() => _showRetired = !_showRetired),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
