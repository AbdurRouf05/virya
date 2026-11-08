import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/widgets/paper_background.dart';
import 'package:virya/features/calendar/application/calendar_controller.dart';
import 'package:virya/features/calendar/data/calendar_providers.dart';
import 'package:virya/features/calendar/presentation/widgets/calendar_day_detail.dart';
import 'package:virya/features/calendar/presentation/widgets/calendar_filter_chips.dart';
import 'package:virya/features/calendar/presentation/widgets/calendar_header.dart';
import 'package:virya/features/calendar/presentation/widgets/calendar_legend.dart';
import 'package:virya/features/calendar/presentation/widgets/calendar_month_grid.dart';
import 'package:virya/features/calendar/presentation/widgets/calendar_stats_row.dart';
import 'package:virya/features/calendar/presentation/widgets/calendar_year_heatmap.dart';

/// "KALENDER" tab: consistency heatmap, month grid, streaks and day detail.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(calendarDaysProvider);
    return Scaffold(
      body: PaperBackground(
        texture: PaperTexture.contours,
        child: SafeArea(
          bottom: false,
          child: days.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Gagal memuat kalender: $e',
                style: FN.label(size: 12, color: FN.ink),
              ),
            ),
            data: (d) => _CalendarBody(days: d),
          ),
        ),
      ),
    );
  }
}

class _CalendarBody extends ConsumerWidget {
  final Map<DateTime, CalendarDay> days;
  const _CalendarBody({required this.days});

  void _open(BuildContext context, WidgetRef ref, String id) {
    final screen = ref.read(integrationsProvider).activityDetail(id);
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(calendarControllerProvider);
    final ctl = ref.read(calendarControllerProvider.notifier);
    final stats = ref.watch(calendarStatsProvider(st.filter)).valueOrNull;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sel = st.selected;
    final selEntries = sel == null
        ? const <CalendarEntry>[]
        : (days[sel]?.entries ?? const <CalendarEntry>[])
              .where((e) => st.filter == null || e.category == st.filter)
              .toList();
    const gap = SizedBox(height: 16);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        CalendarHeader(year: st.year, view: st.view, onView: ctl.setView),
        gap,
        CalendarFilterChips(selected: st.filter, onSelect: ctl.setFilter),
        gap,
        if (stats != null) CalendarStatsRow(stats: stats),
        gap,
        if (st.view == CalendarView.year) ...[
          _YearNav(year: st.year, onShift: ctl.shiftYear),
          const SizedBox(height: 8),
        ],
        CalendarYearHeatmap(
          year: st.year,
          days: days,
          filter: st.filter,
          today: today,
          selected: sel,
          onTap: ctl.select,
        ),
        const SizedBox(height: 10),
        const CalendarLegend(),
        if (st.view == CalendarView.month) ...[
          const SizedBox(height: 14),
          Container(height: 3, color: FN.ink),
          const SizedBox(height: 8),
          CalendarMonthGrid(
            month: st.month,
            days: days,
            filter: st.filter,
            today: today,
            selected: sel,
            onTap: ctl.select,
            onShift: ctl.shiftMonth,
          ),
        ],
        if (sel != null) ...[
          const SizedBox(height: 20),
          CalendarDayDetail(
            date: sel,
            entries: selEntries,
            onOpen: (id) => _open(context, ref, id),
          ),
          ref.read(integrationsProvider).tasksDoneOn(sel),
          ref.read(integrationsProvider).focusDayUsage(sel),
          ref.read(integrationsProvider).bodyOnDay(sel),
        ],
      ],
    );
  }
}

class _YearNav extends StatelessWidget {
  final int year;
  final ValueChanged<int> onShift;
  const _YearNav({required this.year, required this.onShift});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Tahun sebelumnya',
          icon: Icon(Icons.chevron_left, color: FN.ink),
          onPressed: () => onShift(-1),
        ),
        Expanded(
          child: Text(
            '$year',
            textAlign: TextAlign.center,
            style: FN.bigNumber(28),
          ),
        ),
        IconButton(
          tooltip: 'Tahun berikutnya',
          icon: Icon(Icons.chevron_right, color: FN.ink),
          onPressed: () => onShift(1),
        ),
      ],
    );
  }
}
