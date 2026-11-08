import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/activity_history/data/journal_providers.dart';
import 'package:virya/features/activity_history/presentation/activity_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  String _filter = 'all'; // all, cycling, running, walking
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  bool _matchesFilter(Activity a) {
    if (_filter == 'all') return true;
    final sport = sportFromName(a.sportType);
    if (_filter == 'cycling') return sport.isCycling;
    if (_filter == 'running') return sport == SportType.roadRunning || sport == SportType.trailRunning;
    if (_filter == 'walking') return sport == SportType.walking || sport == SportType.hiking;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(completedActivitiesProvider).valueOrNull ?? const [];
    final filtered = list.where(_matchesFilter).toList();
    final fmt = ref.watch(fmtProvider);

    // Group values by date (for heat strip)
    final dailyDist = <DateTime, double>{};
    for (final a in filtered) {
      final t = a.startTime.toLocal();
      final day = DateTime(t.year, t.month, t.day);
      dailyDist[day] = (dailyDist[day] ?? 0) + (a.totalDistanceMeters / 1000);
    }

    // Active days count
    final activeDays = dailyDist.keys.length;

    // Filtered activities on the selected day
    final selectedActs = filtered.where((a) {
      final t = a.startTime.toLocal();
      final day = DateTime(t.year, t.month, t.day);
      return day == _selectedDay;
    }).toList();

    final sec = SectionCounter();
    final selStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDay);

    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 56),
            children: [
              const Masthead(
                kicker: 'KONSISTENSI // KALENDER',
                title: 'Kalender & Heatmap',
                subtitle: 'Sumbu waktu aktivitas harian Anda',
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    _chip('all', 'SEMUA'),
                    const SizedBox(width: 6),
                    _chip('cycling', 'SEPEDA'),
                    const SizedBox(width: 6),
                    _chip('running', 'LARI'),
                    const SizedBox(width: 6),
                    _chip('walking', 'JALAN'),
                  ],
                ),
              ),

              // Section 01: Heatmap 24 Minggu Terakhir
              SectionHeader(
                number: sec.next(),
                title: 'Heatmap 24 Minggu',
                trailing: Text('$activeDays HARI AKTIF', style: FN.monoStyle(size: 11, color: FN.signal)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkBox(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CalendarHeatStrip(
                          dailyValue: dailyDist,
                          weeks: 24,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('24 MINGGU LALU', style: FN.monoStyle(size: 9, color: FN.inkMuted)),
                            Row(
                              children: [
                                Text('RINGAN', style: FN.monoStyle(size: 9, color: FN.inkMuted)),
                                const SizedBox(width: 4),
                                Container(width: 8, height: 8, color: FN.paperLine),
                                const SizedBox(width: 2),
                                Container(width: 8, height: 8, color: FN.inkSoft),
                                const SizedBox(width: 2),
                                Container(width: 8, height: 8, color: FN.signal),
                                const SizedBox(width: 4),
                                Text('INTENS', style: FN.monoStyle(size: 9, color: FN.inkMuted)),
                              ],
                            ),
                            Text('HARI INI', style: FN.monoStyle(size: 9, color: FN.inkMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Section 02: Riwayat Tanggal Terpilih
              SectionHeader(
                number: sec.next(),
                title: 'Aktivitas Tanggal',
                trailing: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDay,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                      builder: (c, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: FN.ink,
                            onPrimary: FN.paper,
                            surface: FN.paper,
                            onSurface: FN.ink,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setState(() => _selectedDay = DateTime(picked.year, picked.month, picked.day));
                    }
                  },
                  child: Text('GANTI TANGGAL',
                      style: FN.label(size: 10, color: FN.signal).copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(selStr.toUpperCase(), style: FN.monoStyle(size: 11, color: FN.inkSoft)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: selectedActs.isEmpty
                    ? InkBox(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Tidak ada aktivitas terekam pada tanggal ini.',
                              style: FN.body(size: 12, color: FN.inkMuted),
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (final a in selectedActs)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ActivityDetailScreen(activityId: a.id),
                                  ),
                                ),
                                child: InkBox(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 40,
                                          color: _sportColor(sportFromName(a.sportType)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(a.title,
                                                  style: FN.heading(size: 14, color: FN.ink),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${fmt.distance(a.totalDistanceMeters, decimals: 1)} ${fmt.distUnit} · ${Fmt.durationShort(a.movingTimeSeconds)} · +${fmt.elevation(a.elevationGainMeters)} ${fmt.eleUnit}',
                                                style: FN.monoStyle(size: 10.5, color: FN.inkMuted),
                                              ),
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
            ],
          ),
        ),
      ),
    );
  }

  Color _sportColor(SportType s) {
    if (s.isCycling) return FN.signal;
    if (s.isRunning) return FN.ok;
    return FN.warn;
  }

  Widget _chip(String key, String label) {
    final active = _filter == key;
    return GestureDetector(
      onTap: () => setState(() => _filter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? FN.ink : FN.paper,
          border: Border.all(color: FN.ink, width: 1.2),
        ),
        child: Text(
          label,
          style: FN.label(size: 10, color: active ? FN.paper : FN.ink).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

