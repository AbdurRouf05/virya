import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/today/domain/today_models.dart';

/// "TERAKHIR": aktivitas terakhir, ketuk untuk membuka detail.
class TodayLastCard extends StatelessWidget {
  final TodayActivity activity;
  final Fmt fmt;
  final VoidCallback onTap;

  const TodayLastCard({
    super.key,
    required this.activity,
    required this.fmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final d = a.start.toLocal();
    final when =
        '${Fmt.daysShort[d.weekday - 1]} ${d.day} ${Fmt.monthsShort[d.month - 1]}';
    return Semantics(
      button: true,
      label: 'Buka aktivitas terakhir',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: FN.paper,
            border: Border.all(color: FN.ink, width: 2),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 10, color: FN.category(a.category)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TERAKHIR · $when',
                          style: FN.label(size: 10.5, color: FN.inkSoft),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          a.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FN.sans,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: FN.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${a.sport.label} · ${fmt.distanceFull(a.distanceMeters, decimals: 1)} · ${Fmt.durationShort(a.movingSeconds)}',
                          style: FN.label(size: 10.5),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.chevron_right, color: FN.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
