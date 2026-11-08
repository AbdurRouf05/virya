import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/profile/data/gear_providers.dart';
import 'package:virya/features/profile/domain/service_reminder.dart';
import 'package:virya/features/profile/presentation/widgets/gear_garage_service_dialog.dart';

/// One gear: type, name, odometer, menu and service reminder strip.
class GearCard extends ConsumerWidget {
  final Gear gear;
  final double distanceM;
  const GearCard({super.key, required this.gear, required this.distanceM});

  Future<void> _editService(
    BuildContext context,
    WidgetRef ref,
    ServiceReminder? current,
    double totalKm,
  ) async {
    final km = await showServiceIntervalDialog(
      context,
      current?.intervalKm ?? (gearIsShoe(gear.gearType) ? 600 : 1000),
    );
    if (km == null) return;
    final settings = ref.read(settingsProvider.notifier);
    await settings.set(
      SettingKeys.gearService(gear.id),
      km <= 0
          ? ''
          : ServiceReminder(km, current?.lastServiceKm ?? totalKm).encode(),
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    String v,
    ServiceReminder? reminder,
    double totalKm,
  ) async {
    final db = ref.read(databaseProvider);
    switch (v) {
      case 'default':
        await db.gearsDao.setDefaultGear(gear.id);
      case 'service':
        if (context.mounted) {
          await _editService(context, ref, reminder, totalKm);
        }
      case 'serviced':
        if (reminder != null) {
          await ref
              .read(settingsProvider.notifier)
              .set(
                SettingKeys.gearService(gear.id),
                ServiceReminder(reminder.intervalKm, totalKm).encode(),
              );
        }
      case 'retire':
        await toggleGearRetired(db, gear);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = ref.watch(fmtProvider);
    final totalKm = distanceM / 1000;
    final reminder = ServiceReminder.parse(
      ref.watch(settingsProvider)[SettingKeys.gearService(gear.id)],
    );
    final remaining = reminder?.remainingKm(totalKm);
    return Opacity(
      opacity: gear.isRetired ? 0.5 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: FN.paper,
          border: Border.all(color: FN.ink, width: gear.isDefault ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 0),
              child: Row(
                children: [
                  Icon(
                    gearIsShoe(gear.gearType)
                        ? Icons.directions_run
                        : Icons.pedal_bike,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${gearTypes[gear.gearType] ?? gear.gearType.toUpperCase()}'
                      '${gear.isDefault ? ' · DEFAULT' : ''}'
                      '${gear.isRetired ? ' · PENSIUN' : ''}',
                      style: FN.label(
                        size: 9.5,
                        color: gear.isDefault ? FN.signal : FN.inkMuted,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onSelected: (v) =>
                        _onMenu(context, ref, v, reminder, totalKm),
                    itemBuilder: (_) => [
                      if (!gear.isDefault && !gear.isRetired)
                        const PopupMenuItem(
                          value: 'default',
                          child: Text('JADIKAN DEFAULT'),
                        ),
                      const PopupMenuItem(
                        value: 'service',
                        child: Text('ATUR PENGINGAT SERVIS'),
                      ),
                      if (reminder != null)
                        const PopupMenuItem(
                          value: 'serviced',
                          child: Text('TANDAI SUDAH SERVIS'),
                        ),
                      PopupMenuItem(
                        value: 'retire',
                        child: Text(
                          gear.isRetired ? 'AKTIFKAN LAGI' : 'PENSIUNKAN',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gear.name.toUpperCase(),
                          style: TextStyle(
                            fontFamily: FN.display,
                            fontSize: 24,
                            height: 1.05,
                            color: FN.ink,
                          ),
                        ),
                        if ((gear.brandModel ?? '').isNotEmpty)
                          Text(gear.brandModel!, style: FN.label(size: 10)),
                      ],
                    ),
                  ),
                  StatBlock(
                    label: 'Odometer',
                    value: fmt.distance(distanceM, decimals: 0),
                    unit: fmt.distUnit,
                    size: 28,
                    align: CrossAxisAlignment.end,
                  ),
                ],
              ),
            ),
            if (reminder != null && remaining != null)
              _ServiceStrip(reminder: reminder, remaining: remaining),
          ],
        ),
      ),
    );
  }
}

class _ServiceStrip extends StatelessWidget {
  final ServiceReminder reminder;
  final double remaining;
  const _ServiceStrip({required this.reminder, required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: remaining <= 0 ? FN.signal : FN.paperDeep,
        border: Border(top: BorderSide(color: FN.ink)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.build_outlined,
            size: 14,
            color: remaining <= 0 ? FN.onAccent : FN.inkSoft,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              remaining <= 0
                  ? 'WAKTUNYA SERVIS · LEWAT ${(-remaining).round()} KM'
                  : 'SERVIS DALAM ${remaining.round()} KM',
              style: FN
                  .label(size: 10, color: remaining <= 0 ? FN.onAccent : FN.ink)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: (1 - remaining / reminder.intervalKm).clamp(0.0, 1.0),
              color: remaining <= 0 ? FN.onAccent : FN.ink,
              backgroundColor: FN.paperLine,
            ),
          ),
        ],
      ),
    );
  }
}
