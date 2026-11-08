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
              SectionHeader(number: sec.next(), title: 'Garasi'),
              const GearGarage(),
              SectionHeader(number: sec.next(), title: 'Peta Offline & Wilayah'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ref.read(integrationsProvider).mapPacks(),
                    ),
                  ),
                  child: InkBox(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            color: FN.paper,
                            alignment: Alignment.center,
                            child: Icon(Icons.map_outlined, size: 20, color: FN.ink),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('KELOLA PAKET PETA (.PMTILES)', style: FN.heading(size: 13, color: FN.ink)),
                                const SizedBox(height: 2),
                                Text('Unduh atau impor peta vektor & elevasi DEM 3D',
                                    style: FN.body(size: 11, color: FN.inkMuted)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 20, color: FN.inkMuted),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
