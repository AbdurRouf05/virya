import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/app/format.dart';
import 'package:stravo/app/settings.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/widgets/field_kit.dart';
import 'package:stravo/features/activity_history/data/journal_providers.dart';
import 'package:stravo/features/profile/presentation/gear_garage.dart';
import 'package:stravo/features/settings/data/data_actions.dart';
import 'package:stravo/features/settings/presentation/settings_screen.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.userProfiles)..limit(1)).watchSingleOrNull();
});

/// "PROFIL" — athlete card, lifetime totals, gear garage.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final list = ref.watch(completedActivitiesProvider).valueOrNull ?? const [];
    final fmt = ref.watch(fmtProvider);
    final dist = list.fold<double>(0, (s, a) => s + a.totalDistanceMeters);
    final ele = list.fold<double>(0, (s, a) => s + a.elevationGainMeters);
    final time = list.fold<int>(0, (s, a) => s + a.movingTimeSeconds);
    final sec = SectionCounter();
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              Masthead(
                kicker: 'Kartu atlet',
                title: profile?.displayName ?? 'Tanpa nama',
                subtitle: profile == null
                    ? 'Isi profil agar kalori & zona akurat'
                    : 'Sejak ${Fmt.dateStamp(profile.createdAt, withTime: false)}',
                actions: [
                  InkIconButton(
                    icon: Icons.tune,
                    tooltip: 'Pengaturan',
                    size: 36,
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),
              SectionHeader(number: sec.next(), title: 'Seumur hidup'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StatGrid(columns: 2, children: [
                  StatBlock(
                      label: 'Jarak',
                      value: fmt.distance(dist, decimals: 0),
                      unit: fmt.distUnit,
                      size: 38),
                  StatBlock(
                      label: 'Tanjakan',
                      value: fmt.elevation(ele),
                      unit: fmt.eleUnit,
                      size: 38),
                  StatBlock(
                      label: 'Waktu bergerak',
                      value: Fmt.durationShort(time),
                      size: 24),
                  StatBlock(
                      label: 'Aktivitas', value: '${list.length}', size: 24),
                ]),
              ),
              SectionHeader(
                number: sec.next(),
                title: 'Data atlet',
                trailing: GestureDetector(
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => AthleteEditDialog(profile: profile),
                  ),
                  child: Text('UBAH',
                      style: FN.label(size: 11, color: FN.signal)
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StatGrid(columns: 3, children: [
                  StatBlock(
                      label: 'Berat',
                      value: (profile?.weightKg ?? 70).toStringAsFixed(0),
                      unit: 'kg',
                      size: 26),
                  StatBlock(
                      label: 'HR maks',
                      value: '${profile?.maxHeartRate ?? 190}',
                      unit: 'bpm',
                      size: 26),
                  StatBlock(
                      label: 'FTP',
                      value: profile?.ftpWatts?.toString() ?? '–',
                      unit: 'W',
                      size: 26),
                ]),
              ),
              SectionHeader(number: sec.next(), title: 'Garasi'),
              const GearGarage(),
            ],
          ),
        ),
      ),
    );
  }
}

class AthleteEditDialog extends ConsumerStatefulWidget {
  final UserProfile? profile;
  const AthleteEditDialog({super.key, this.profile});

  @override
  ConsumerState<AthleteEditDialog> createState() => _AthleteEditDialogState();
}

class _AthleteEditDialogState extends ConsumerState<AthleteEditDialog> {
  late final _name =
      TextEditingController(text: widget.profile?.displayName ?? '');
  late final _weight = TextEditingController(
      text: (widget.profile?.weightKg ?? 70).toStringAsFixed(0));
  late final _hr =
      TextEditingController(text: '${widget.profile?.maxHeartRate ?? 190}');
  late final _ftp =
      TextEditingController(text: widget.profile?.ftpWatts?.toString() ?? '');

  @override
  void dispose() {
    for (final c in [_name, _weight, _hr, _ftp]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    final weight =
        double.tryParse(_weight.text.replaceAll(',', '.')) ?? 70;
    final hr = int.tryParse(_hr.text) ?? 190;
    final ftp = int.tryParse(_ftp.text);
    final name = _name.text.trim().isEmpty ? 'Atlet' : _name.text.trim();
    try {
      final p = widget.profile;
      if (p == null) {
        await db.into(db.userProfiles).insert(UserProfilesCompanion.insert(
              id: 'me',
              displayName: name,
              weightKg: Value(weight),
              maxHeartRate: Value(hr),
              ftpWatts: Value(ftp),
              createdAt: DateTime.now(),
            ));
      } else {
        await (db.update(db.userProfiles)..where((t) => t.id.equals(p.id)))
            .write(UserProfilesCompanion(
          displayName: Value(name),
          weightKg: Value(weight),
          maxHeartRate: Value(hr),
          ftpWatts: Value(ftp),
        ));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) DataActions.toast(context, 'Gagal menyimpan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
    return AlertDialog(
      title: const Text('DATA ATLET'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'NAMA')),
          const SizedBox(height: 10),
          TextField(
              controller: _weight,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: const InputDecoration(
                  labelText: 'BERAT (KG)', suffixText: 'kg')),
          const SizedBox(height: 10),
          TextField(
              controller: _hr,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: const InputDecoration(
                  labelText: 'DETAK JANTUNG MAKS', suffixText: 'bpm')),
          const SizedBox(height: 10),
          TextField(
              controller: _ftp,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: const InputDecoration(
                  labelText: 'FTP (OPSIONAL)', suffixText: 'W')),
          const SizedBox(height: 8),
          Text(
              'Dipakai untuk estimasi daya, kalori & zona. Analisis ulang '
              'aktivitas lama lewat "Ubah catatan".',
              style: FN.label(size: 9.5)),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL')),
        TextButton(
          onPressed: _save,
          style: TextButton.styleFrom(foregroundColor: FN.signal),
          child: const Text('SIMPAN'),
        ),
      ],
    );
  }
}
