import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/settings/data/data_actions.dart';
import 'package:virya/features/settings/presentation/widgets/settings_row.dart';
import 'package:virya/features/settings/presentation/widgets/style_picker.dart';

/// "PENGATURAN" — units, recording, voice, data, about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final sec = SectionCounter();
    Widget toggle(String key, String title, [String? note]) => SettingRow(
      title: title,
      note: note,
      trailing: InkToggle(
        value: s.flag(key),
        onChanged: (v) => ctl.setBool(key, v),
      ),
    );
    Widget chips(List<(String, String)> opts, String key) => Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (v, label) in opts)
          StampChip(
            text: label,
            fontSize: 10,
            selected: (s[key] ?? settingDefaults[key]) == v,
            onTap: () => ctl.set(key, v),
          ),
      ],
    );
    final calib = s.number(SettingKeys.vibrationCalibration, 1.0);
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
              const Masthead(
                kicker: 'Catatan teknis',
                title: 'Pengaturan',
                subtitle: 'Semua tersimpan di perangkat, tanpa akun',
              ),
              SectionHeader(number: sec.next(), title: 'Tampilan'),
              _pad(const StylePicker()),
              SectionHeader(number: sec.next(), title: 'Satuan'),
              _pad(
                chips(const [
                  ('metric', 'METRIK · KM'),
                  ('imperial', 'IMPERIAL · MIL'),
                ], SettingKeys.units),
              ),
              SectionHeader(number: sec.next(), title: 'Perekaman'),
              _pad(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OLAHRAGA DEFAULT', style: FN.label(size: 10)),
                    const SizedBox(height: 6),
                    chips([
                      for (final t in SportType.gps) (t.name, t.label),
                    ], SettingKeys.defaultSport),
                  ],
                ),
              ),
              toggle(
                SettingKeys.autoPause,
                'Jeda otomatis',
                'Berhenti mencatat saat kamu diam',
              ),
              toggle(SettingKeys.keepScreenOn, 'Layar tetap menyala'),
              SettingRow(
                title: 'Posisi ponsel',
                note: 'Memengaruhi klasifikasi permukaan dari getaran',
                below: chips(const [
                  ('handlebar', 'STANG'),
                  ('pocket', 'SAKU / TAS'),
                ], SettingKeys.phoneMount),
              ),
              SettingRow(
                title: 'Kalibrasi getaran',
                note:
                    '×${calib.toStringAsFixed(2)} — naikkan jika jalan '
                    'kasar terbaca mulus',
                below: Slider(
                  min: 0.5,
                  max: 2.0,
                  divisions: 30,
                  value: calib.clamp(0.5, 2.0),
                  onChanged: (v) => ctl.set(
                    SettingKeys.vibrationCalibration,
                    v.toStringAsFixed(2),
                  ),
                ),
              ),
              toggle(
                SettingKeys.useSimulatedGps,
                'Mode GPS simulasi (dev)',
                'Memutar rute demo sebagai sinyal GPS',
              ),
              SectionHeader(number: sec.next(), title: 'Suara'),
              toggle(
                SettingKeys.ttsEnabled,
                'Pengumuman suara',
                'Membacakan jarak, waktu & tempo tiap split',
              ),
              SettingRow(
                title: 'Interval pengumuman',
                below: chips(const [
                  ('0.5', '0,5 KM'),
                  ('1', '1 KM'),
                  ('2', '2 KM'),
                  ('5', '5 KM'),
                ], SettingKeys.ttsSplitKm),
              ),
              SectionHeader(number: sec.next(), title: 'Data'),
              _pad(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkButton(
                      label: 'Impor riwayat (GPX/TCX/FIT/ZIP Strava)',
                      icon: Icons.file_download_outlined,
                      style: InkButtonStyle.primary,
                      expand: true,
                      onPressed: () => DataActions.importFile(context, ref),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'GPX, TCX, FIT, .gz atau ZIP. Pindah dari Strava: '
                      'Pengaturan → Akun → Unduh atau hapus akun → Minta '
                      'arsip. File ZIP-nya bisa langsung diimpor di sini.',
                      style: FN.label(size: 9.5),
                    ),
                    const SizedBox(height: 14),
                    InkButton(
                      label: 'Buat cadangan',
                      icon: Icons.inventory_2_outlined,
                      style: InkButtonStyle.outline,
                      expand: true,
                      onPressed: () => DataActions.createBackup(context, ref),
                    ),
                    const SizedBox(height: 10),
                    InkButton(
                      label: 'Pulihkan cadangan',
                      icon: Icons.restore,
                      style: InkButtonStyle.outline,
                      expand: true,
                      onPressed: () => DataActions.restoreBackup(context, ref),
                    ),
                    const SizedBox(height: 10),
                    InkButton(
                      label: 'Hitung ulang semua aktivitas',
                      icon: Icons.refresh_outlined,
                      style: InkButtonStyle.outline,
                      expand: true,
                      onPressed: () =>
                          DataActions.recalculateAllActivities(context, ref),
                    ),
                    const SizedBox(height: 10),
                    InkButton(
                      label: 'Peta offline',
                      icon: Icons.map_outlined,
                      style: InkButtonStyle.outline,
                      expand: true,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ref.read(integrationsProvider).mapPacks(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkButton(
                      label: 'Muat rute demo',
                      icon: Icons.route_outlined,
                      style: InkButtonStyle.ink,
                      expand: true,
                      onPressed: () => DataActions.loadDemo(context, ref),
                    ),
                  ],
                ),
              ),
              SectionHeader(number: sec.next(), title: 'Tentang'),
              _pad(
                InkBox(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VIRYA', style: FN.bigNumber(30)),
                      const SizedBox(height: 4),
                      Text(
                        'Jurnal lapangan untuk gravel, sepeda & lari. '
                        '100% offline — data tidak pernah meninggalkan '
                        'perangkat kecuali kamu membagikannya.',
                        style: FN.label(size: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _pad(Widget child) =>
      Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: child);
}
