import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/domain/session_draft.dart';

/// Judul sesi + blok durasi hitam, lalu strip VOLUME · SET · GERAKAN.
class GymSessionHeader extends StatelessWidget {
  final String title;
  final DateTime start;
  final DateTime now;
  final DraftSummary summary;
  final VoidCallback? onRename;

  const GymSessionHeader({
    super.key,
    required this.title,
    required this.start,
    required this.now,
    required this.summary,
    this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final secs = now.difference(start).inSeconds;
    final d = secs < 0 ? 0 : secs;
    final hms =
        '${(d ~/ 3600).toString().padLeft(2, '0')}:'
        '${(d % 3600 ~/ 60).toString().padLeft(2, '0')}:'
        '${(d % 60).toString().padLeft(2, '0')}';
    final local = start.toLocal();
    final name = title.replaceFirst(RegExp(r'^Gym · '), '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: FN.ink, width: 2),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onRename,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: FN.display,
                              fontSize: 34,
                              height: 1.0,
                              color: FN.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${Fmt.daysShort[local.weekday - 1]}, ${local.day} '
                            '${Fmt.monthsShort[local.month - 1]} · '
                            '${summary.totalExercises} GERAKAN',
                            style: FN.label(size: 9.5, color: FN.inkSoft),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: FN.ink,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('DURASI', style: FN.label(size: 9, color: FN.acid)),
                      Text(hms, style: FN.bigNumber(34, color: FN.paper)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: FN.ink, width: 2),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Cell('VOLUME', '${Fmt.number(summary.volumeKg)} kg'),
                Container(width: 2, color: FN.ink),
                _Cell('SET', '${summary.doneSets} / ${summary.totalSets}'),
                Container(width: 2, color: FN.ink),
                _Cell(
                  'GERAKAN',
                  '${summary.doneExercises} / ${summary.totalExercises}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  final String label;
  final String value;
  const _Cell(this.label, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 7, 8, 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FN.label(size: 9)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: FN
                  .label(size: 16, color: FN.ink)
                  .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    ),
  );
}
