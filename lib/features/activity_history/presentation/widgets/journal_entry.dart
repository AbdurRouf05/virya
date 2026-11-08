import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/activity_history/data/journal_providers.dart';

/// One notebook line: date stamp | text & numbers | route sketch.
class JournalEntry extends ConsumerWidget {
  final Activity activity;
  final VoidCallback? onTap;
  const JournalEntry({super.key, required this.activity, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = activity;
    final fmt = ref.watch(fmtProvider);
    final sport = sportFromName(a.sportType);
    final thumb = ref.watch(routeThumbProvider(a.id));
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateStamp(date: a.startTime),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(sport.icon, size: 13, color: FN.inkMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${sport.label} · ${Fmt.time(a.startTime)}',
                          style: FN.label(size: 9.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    a.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FN.sans,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      height: 1.2,
                      color: FN.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        fmt.distance(a.totalDistanceMeters),
                        style: FN.bigNumber(30),
                      ),
                      const SizedBox(width: 3),
                      Text(fmt.distUnit, style: FN.label(size: 10)),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          '${Fmt.duration(a.movingTimeSeconds)}  ▲${fmt.elevation(a.elevationGainMeters)}${fmt.eleUnit.toLowerCase()}',
                          overflow: TextOverflow.ellipsis,
                          style: FN.label(size: 11, color: FN.ink),
                        ),
                      ),
                    ],
                  ),
                  if (a.gravelPercentage > 0.5) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: GravelShareBar(gravelPct: a.gravelPercentage),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'GRAVEL ${a.gravelPercentage.round()}%',
                          style: FN.label(size: 9.5, color: FN.ink),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: FN.paper,
                border: Border.all(color: FN.ink, width: 1),
              ),
              child: thumb.maybeWhen(
                data: (pts) => pts.length < 2
                    ? const Center(child: Text('—'))
                    : RouteThumbnail(points: pts, strokeWidth: 1.4),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateStamp extends StatelessWidget {
  final DateTime date;
  const _DateStamp({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      decoration: BoxDecoration(border: Border.all(color: FN.ink, width: 1.2)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: FN.ink,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              Fmt.daysShort[date.weekday - 1],
              textAlign: TextAlign.center,
              style: FN
                  .label(size: 9, color: FN.paper)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              date.day.toString().padLeft(2, '0'),
              style: FN.bigNumber(26),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              Fmt.monthsShort[date.month - 1],
              style: FN.label(size: 8.5),
            ),
          ),
        ],
      ),
    );
  }
}
