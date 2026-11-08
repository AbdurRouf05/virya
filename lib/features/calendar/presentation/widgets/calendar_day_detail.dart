import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/calendar/domain/calendar_day.dart';

/// Boxed list of what happened on [date]: one row per activity.
class CalendarDayDetail extends StatelessWidget {
  final DateTime date;

  /// Activities of that day (already filtered), oldest first.
  final List<CalendarEntry> entries;
  final ValueChanged<String> onOpen;

  const CalendarDayDetail({
    super.key,
    required this.date,
    required this.entries,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        '${Fmt.daysLong[date.weekday - 1]}, ${date.day} '
        '${Fmt.monthsShort[date.month - 1]}';
    return Container(
      decoration: BoxDecoration(border: Border.all(color: FN.ink, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: FN
                        .label(size: 12, color: FN.ink)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${entries.length} AKTIVITAS',
                  style: FN.label(size: 11, color: FN.ink),
                ),
              ],
            ),
          ),
          Container(height: 2, color: FN.ink),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Hari istirahat. Tidak ada aktivitas tercatat.',
                style: TextStyle(
                  fontFamily: FN.sans,
                  fontSize: 14,
                  color: FN.inkMuted,
                ),
              ),
            ),
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) Container(height: 1, color: FN.paperLine),
            _EntryRow(entry: entries[i], onTap: () => onOpen(entries[i].id)),
          ],
        ],
      ),
    );
  }
}

class _EntryRow extends ConsumerWidget {
  final CalendarEntry entry;
  final VoidCallback onTap;

  const _EntryRow({required this.entry, required this.onTap});

  String _sportLabel() => entry.category == SportCategory.strength
      ? entry.category.label
      : sportFromName(entry.sportName).label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = ref.watch(fmtProvider);
    final e = entry;
    final bits = <String>[
      if (e.distanceMeters > 0) fmt.distanceFull(e.distanceMeters),
      Fmt.duration(e.durationSeconds),
      if (e.elevationGainMeters >= 1)
        '↑ ${fmt.elevation(e.elevationGainMeters)} ${fmt.eleUnit.toLowerCase()}',
    ];
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(width: 8, height: 44, color: FN.category(e.category)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FN.sans,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: FN.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_sportLabel()} · ${bits.join(' · ')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FN.sans,
                      fontSize: 13,
                      color: FN.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(Fmt.time(e.start), style: FN.label(size: 11)),
          ],
        ),
      ),
    );
  }
}
