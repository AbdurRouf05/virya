import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/dashboard/application/fitness_timeline_provider.dart';
import 'package:virya/features/profile/data/profile_providers.dart';
import 'package:virya/features/today/data/today_providers.dart';
import 'package:virya/features/today/presentation/widgets/today_cards.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  final _taskInputCtrl = TextEditingController();

  @override
  void dispose() {
    _taskInputCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  void _openRecording() {
    final integ = ref.read(integrationsProvider);
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => Theme(
        data: FieldNotesTheme.night,
        child: integ.recordingScreen(),
      ),
    ));
  }

  void _addTask() {
    final text = _taskInputCtrl.text.trim();
    if (text.isEmpty) return;
    ref.read(todayTasksProvider.notifier).addTask(text);
    _taskInputCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final name = profile?.displayName ?? 'Atlet';
    final fmt = ref.watch(fmtProvider);
    final todayActs = ref.watch(todayActivitiesProvider);
    final streak = ref.watch(currentStreakProvider);
    final weekDays = ref.watch(currentWeekDaysProvider);
    final tasks = ref.watch(todayTasksProvider);
    final timeline = ref.watch(fitnessTimelineProvider);
    final todayTsb = timeline.isEmpty ? null : timeline.last.form;

    final now = DateTime.now();
    String dateStr;
    try {
      dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
    } catch (_) {
      dateStr = '${now.day}/${now.month}/${now.year}';
    }
    final sec = SectionCounter();

    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 56),
            children: [
              Masthead(
                kicker: 'HARI INI // VIRYA',
                title: '${_greeting()}, $name',
                subtitle: dateStr,
                actions: [
                  InkIconButton(
                    icon: Icons.fiber_manual_record,
                    tooltip: 'Rekam',
                    onPressed: _openRecording,
                  ),
                ],
              ),

              // 01: Status Kebugaran (TSB)
              SectionHeader(
                number: sec.next(),
                title: 'Kondisi Kebugaran',
                trailing: Text(
                  todayTsb == null ? 'NETRAL' : (todayTsb >= 0 ? '+${todayTsb.round()}' : '${todayTsb.round()}'),
                  style: FN.monoStyle(size: 11, color: FN.signal).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FormConditionCard(tsb: todayTsb),
              ),

              // 02: Latihan Hari Ini
              SectionHeader(
                number: sec.next(),
                title: 'Latihan Hari Ini',
                trailing: todayActs.isNotEmpty
                    ? Text('${todayActs.length} SESI', style: FN.label(size: 10, color: FN.inkMuted))
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: todayActs.isNotEmpty
                    ? TodayActivitiesCard(acts: todayActs, fmt: fmt)
                    : NoActivityCard(onRecord: _openRecording),
              ),

              // 03: Konsistensi Minggu Ini (7 Kotak Mini Heatmap)
              SectionHeader(
                number: sec.next(),
                title: 'Minggu Ini',
                trailing: streak > 0
                    ? Text('STREAK $streak HARI 🔥',
                        style: FN.label(size: 10, color: FN.signal).copyWith(fontWeight: FontWeight.w700))
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: WeekStripCard(days: weekDays, fmt: fmt),
              ),

              // 04: Tugas Hari Ini
              SectionHeader(
                number: sec.next(),
                title: 'Tugas Hari Ini',
                trailing: Text(
                  '${tasks.where((t) => t.isDone).length}/${tasks.length}',
                  style: FN.monoStyle(size: 11, color: FN.inkMuted),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkBox(
                  child: Column(
                    children: [
                      for (final t in tasks)
                        InkWell(
                          onTap: () => ref.read(todayTasksProvider.notifier).toggleTask(t.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  t.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                                  size: 20,
                                  color: t.isDone ? FN.signal : FN.inkMuted,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t.title,
                                    style: FN.body(size: 13, color: t.isDone ? FN.inkMuted : FN.ink).copyWith(
                                      decoration: t.isDone ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  color: FN.inkMuted,
                                  onPressed: () => ref.read(todayTasksProvider.notifier).deleteTask(t.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: FN.paperLine, width: 1)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _taskInputCtrl,
                                style: FN.body(size: 13, color: FN.ink),
                                decoration: InputDecoration(
                                  hintText: '+ Tambah tugas baru...',
                                  hintStyle: FN.body(size: 13, color: FN.inkMuted),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _addTask(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              color: FN.signal,
                              onPressed: _addTask,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 05: Fokus & Kebiasaan (Fase 6 Preview)
              SectionHeader(number: sec.next(), title: 'Fokus & Batas Aplikasi'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkBox(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PENGGUNAAN LAYAR', style: FN.label(size: 10, color: FN.inkMuted)),
                            Text('KUOTA AKTIF', style: FN.monoStyle(size: 10, color: FN.signal)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const AppLimitBar(name: 'Instagram', usedMinutes: 24, maxMinutes: 45),
                        const SizedBox(height: 8),
                        const AppLimitBar(name: 'TikTok', usedMinutes: 12, maxMinutes: 30),
                        const SizedBox(height: 8),
                        const AppLimitBar(name: 'YouTube', usedMinutes: 35, maxMinutes: 60),
                      ],
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
