import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/today/domain/today_models.dart';

/// "LATIHAN HARI INI": sudah/belum, ringkasan hari ini, dan panel streak.
class TodayTrainingCard extends StatelessWidget {
  final TodaySummary summary;
  final Fmt fmt;
  final VoidCallback? onStart;

  const TodayTrainingCard({
    super.key,
    required this.summary,
    required this.fmt,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FN.paper,
        border: Border.all(color: FN.ink, width: 2),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _body()),
            _StreakPanel(days: summary.streakDays),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    final today = summary.today;
    final done = summary.doneToday;
    final title = !done
        ? 'Belum ada latihan'
        : today.length == 1
        ? today.first.title
        : '${today.length} aktivitas';
    final detail = done
        ? [
            if (today.length == 1) _cap(today.first.sport.label),
            fmt.distanceFull(summary.todayDistance, decimals: 1),
            Fmt.durationShort(summary.todayMovingSeconds),
          ].join(' · ')
        : summary.streakDays > 0
        ? 'Bergerak hari ini agar streak tetap jalan'
        : 'Mulai catat hari ini';
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 11,
                height: 11,
                color: done ? FN.category(today.first.category) : FN.inkMuted,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'LATIHAN HARI INI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FN
                      .label(size: 11, color: FN.ink)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FN.sans,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: FN.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: TextStyle(
              fontFamily: FN.sans,
              fontSize: 13,
              color: FN.inkMuted,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _Tag(text: done ? 'SUDAH' : 'BELUM', color: done ? FN.ok : null),
              if (!done && onStart != null) _StartButton(onTap: onStart!),
            ],
          ),
        ],
      ),
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0] + s.substring(1).toLowerCase();
}

class _Tag extends StatelessWidget {
  final String text;
  final Color? _color;
  Color get color => _color ?? FN.ink;
  const _Tag({required this.text, Color? color}) : _color = color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
    child: Text(
      text,
      style: FN
          .label(size: 11, color: color)
          .copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _StartButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: FN.signal,
        border: Border.all(color: FN.ink, width: 2),
      ),
      child: Text(
        'MULAI →',
        style: FN
            .label(size: 11, color: FN.onAccent)
            .copyWith(fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class _StreakPanel extends StatelessWidget {
  final int days;
  const _StreakPanel({required this.days});

  @override
  Widget build(BuildContext context) => Container(
    width: 112,
    color: FN.night,
    padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STREAK',
          style: FN
              .label(size: 11, color: FN.acid)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text('$days', style: FN.bigNumber(56, color: FN.onNight)),
        ),
        const SizedBox(height: 4),
        Text('HARI', style: FN.label(size: 11, color: FN.onNight)),
      ],
    ),
  );
}
