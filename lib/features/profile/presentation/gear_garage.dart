import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/app/format.dart';
import 'package:stravo/app/settings.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/widgets/field_kit.dart';
import 'package:stravo/features/profile/data/gear_providers.dart';
import 'package:stravo/features/settings/data/data_actions.dart';
import 'package:uuid/uuid.dart';

/// Service reminder stored in AppSettings as "intervalKm|lastServiceKm".
class ServiceReminder {
  final double intervalKm;
  final double lastServiceKm;
  const ServiceReminder(this.intervalKm, this.lastServiceKm);

  static ServiceReminder? parse(String? raw) {
    if (raw == null) return null;
    final p = raw.split('|');
    if (p.length != 2) return null;
    final i = double.tryParse(p[0]), l = double.tryParse(p[1]);
    if (i == null || l == null || i <= 0) return null;
    return ServiceReminder(i, l);
  }

  String encode() => '$intervalKm|$lastServiceKm';
  double remainingKm(double totalKm) => intervalKm - (totalKm - lastServiceKm);
}

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
    final visible =
        gears.where((g) => _showRetired || !g.isRetired).toList();
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
                  style: FN.label(size: 11)),
            ),
          for (final g in visible)
            GearCard(
              gear: g,
              distanceM: dist[g.id] ?? 0,
            ),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: InkButton(
                label: 'Tambah gear',
                icon: Icons.add,
                style: InkButtonStyle.ink,
                expand: true,
                onPressed: () => showDialog<void>(
                    context: context, builder: (_) => const AddGearDialog()),
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
          ]),
        ],
      ),
    );
  }
}

class GearCard extends ConsumerWidget {
  final Gear gear;
  final double distanceM;
  const GearCard({super.key, required this.gear, required this.distanceM});

  Future<void> _editService(BuildContext context, WidgetRef ref,
      ServiceReminder? current, double totalKm) async {
    final ctrl = TextEditingController(
        text: (current?.intervalKm ?? (gearIsShoe(gear.gearType) ? 600 : 1000))
            .toStringAsFixed(0));
    final km = await showDialog<double>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('PENGINGAT SERVIS'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'INTERVAL (KM)', suffixText: 'km'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, 0.0),
              child: const Text('MATIKAN')),
          TextButton(
            onPressed: () => Navigator.pop(c, double.tryParse(ctrl.text)),
            style: TextButton.styleFrom(foregroundColor: FN.signal),
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (km == null) return;
    final settings = ref.read(settingsProvider.notifier);
    await settings.set(
      SettingKeys.gearService(gear.id),
      km <= 0
          ? ''
          : ServiceReminder(km, current?.lastServiceKm ?? totalKm).encode(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = ref.watch(fmtProvider);
    final totalKm = distanceM / 1000;
    final reminder = ServiceReminder.parse(
        ref.watch(settingsProvider)[SettingKeys.gearService(gear.id)]);
    final db = ref.read(databaseProvider);
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
              child: Row(children: [
                Icon(
                    gearIsShoe(gear.gearType)
                        ? Icons.directions_run
                        : Icons.pedal_bike,
                    size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${gearTypes[gear.gearType] ?? gear.gearType.toUpperCase()}'
                    '${gear.isDefault ? ' · DEFAULT' : ''}'
                    '${gear.isRetired ? ' · PENSIUN' : ''}',
                    style: FN.label(
                        size: 9.5,
                        color: gear.isDefault ? FN.signal : FN.inkMuted),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, size: 20),
                  onSelected: (v) async {
                    switch (v) {
                      case 'default':
                        await db.gearsDao.setDefaultGear(gear.id);
                      case 'service':
                        if (context.mounted) {
                          await _editService(context, ref, reminder, totalKm);
                        }
                      case 'serviced':
                        if (reminder != null) {
                          await ref.read(settingsProvider.notifier).set(
                              SettingKeys.gearService(gear.id),
                              ServiceReminder(reminder.intervalKm, totalKm)
                                  .encode());
                        }
                      case 'retire':
                        await (db.update(db.gears)
                              ..where((t) => t.id.equals(gear.id)))
                            .write(GearsCompanion(
                                isRetired: Value(!gear.isRetired),
                                isDefault: const Value(false)));
                    }
                  },
                  itemBuilder: (_) => [
                    if (!gear.isDefault && !gear.isRetired)
                      const PopupMenuItem(
                          value: 'default', child: Text('JADIKAN DEFAULT')),
                    const PopupMenuItem(
                        value: 'service', child: Text('ATUR PENGINGAT SERVIS')),
                    if (reminder != null)
                      const PopupMenuItem(
                          value: 'serviced', child: Text('TANDAI SUDAH SERVIS')),
                    PopupMenuItem(
                        value: 'retire',
                        child: Text(gear.isRetired ? 'AKTIFKAN LAGI' : 'PENSIUNKAN')),
                  ],
                ),
              ]),
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
                        Text(gear.name.toUpperCase(),
                            style: const TextStyle(
                                fontFamily: FN.display,
                                fontSize: 24,
                                height: 1.05,
                                color: FN.ink)),
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
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                decoration: BoxDecoration(
                  color: remaining <= 0 ? FN.signal : FN.paperDeep,
                  border: const Border(top: BorderSide(color: FN.ink)),
                ),
                child: Row(children: [
                  Icon(Icons.build_outlined,
                      size: 14, color: remaining <= 0 ? FN.ink : FN.inkSoft),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      remaining <= 0
                          ? 'WAKTUNYA SERVIS · LEWAT ${(-remaining).round()} KM'
                          : 'SERVIS DALAM ${remaining.round()} KM',
                      style: FN.label(size: 10, color: FN.ink)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: LinearProgressIndicator(
                      value: (1 - remaining / reminder.intervalKm)
                          .clamp(0.0, 1.0),
                      color: FN.ink,
                      backgroundColor: FN.paperLine,
                    ),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

class AddGearDialog extends ConsumerStatefulWidget {
  const AddGearDialog({super.key});

  @override
  ConsumerState<AddGearDialog> createState() => _AddGearDialogState();
}

class _AddGearDialogState extends ConsumerState<AddGearDialog> {
  final _name = TextEditingController();
  final _brand = TextEditingController();
  String _type = 'gravelBike';

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      DataActions.toast(context, 'Beri nama dulu.');
      return;
    }
    final db = ref.read(databaseProvider);
    final hasAny = (await db.gearsDao.getActiveGears()).isNotEmpty;
    await db.gearsDao.insertGear(GearsCompanion.insert(
      id: const Uuid().v4(),
      name: _name.text.trim(),
      gearType: _type,
      brandModel: Value(_brand.text.trim().isEmpty ? null : _brand.text.trim()),
      isDefault: Value(!hasAny),
      createdAt: DateTime.now(),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('GEAR BARU'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'NAMA')),
            const SizedBox(height: 10),
            TextField(
                controller: _brand,
                decoration:
                    const InputDecoration(labelText: 'MEREK / MODEL')),
            const SizedBox(height: 14),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final e in gearTypes.entries)
                StampChip(
                  text: e.value,
                  fontSize: 10,
                  selected: _type == e.key,
                  onTap: () => setState(() => _type = e.key),
                ),
            ]),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL')),
        TextButton(
          onPressed: _save,
          style: TextButton.styleFrom(foregroundColor: FN.signal),
          child: const Text('TAMBAH'),
        ),
      ],
    );
  }
}

/// Keeps `Fmt` import meaningful for callers that format odometers.
String gearOdometer(Fmt fmt, double m) => fmt.distanceFull(m, decimals: 0);
