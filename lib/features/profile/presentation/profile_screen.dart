import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/activity_history/data/journal_providers.dart';
import 'package:virya/features/profile/data/profile_providers.dart';
import 'package:virya/features/profile/presentation/gear_garage.dart';
import 'package:virya/features/profile/presentation/widgets/profile_athlete_edit_dialog.dart';
import 'package:virya/features/settings/presentation/settings_screen.dart';

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
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              SectionHeader(number: sec.next(), title: 'Seumur hidup'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StatGrid(
                  columns: 2,
                  children: [
                    StatBlock(
                      label: 'Jarak',
                      value: fmt.distance(dist, decimals: 0),
                      unit: fmt.distUnit,
                      size: 38,
                    ),
                    StatBlock(
                      label: 'Tanjakan',
                      value: fmt.elevation(ele),
                      unit: fmt.eleUnit,
                      size: 38,
                    ),
                    StatBlock(
                      label: 'Waktu bergerak',
                      value: Fmt.durationShort(time),
                      size: 24,
                    ),
                    StatBlock(
                      label: 'Aktivitas',
                      value: '${list.length}',
                      size: 24,
                    ),
                  ],
                ),
              ),
              SectionHeader(
                number: sec.next(),
                title: 'Data atlet',
                trailing: GestureDetector(
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => AthleteEditDialog(profile: profile),
                  ),
                  child: Text(
                    'UBAH',
                    style: FN
                        .label(size: 11, color: FN.signal)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StatGrid(
                  columns: 3,
                  children: [
                    StatBlock(
                      label: 'Berat',
                      value: (profile?.weightKg ?? 70).toStringAsFixed(0),
                      unit: 'kg',
                      size: 26,
                    ),
                    StatBlock(
                      label: 'HR maks',
                      value: '${profile?.maxHeartRate ?? 190}',
                      unit: 'bpm',
                      size: 26,
                    ),
                    StatBlock(
                      label: 'FTP',
                      value: profile?.ftpWatts?.toString() ?? '–',
                      unit: 'W',
                      size: 26,
                    ),
                  ],
                ),
              ),
              SectionHeader(number: sec.next(), title: 'Progres tubuh'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkButton(
                  label: 'Foto & ukuran',
                  icon: Icons.photo_camera_outlined,
                  expand: true,
                  onPressed: () {
                    final screen = ref.read(integrationsProvider).bodyHome();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => screen),
                    );
                  },
                ),
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
