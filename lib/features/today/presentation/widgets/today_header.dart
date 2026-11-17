import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/today/domain/today_math.dart';

/// Sapaan + tanggal besar: "SELAMAT PAGI · MINGGU KE-45" / "MINGGU, 8 NOV 2026".
class TodayHeader extends StatelessWidget {
  final DateTime now;
  const TodayHeader({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    final d = now.toLocal();
    final day = FN.caps(Fmt.daysLong[d.weekday - 1]);
    final big = FN.title(46, color: FN.ink, height: 1.0).copyWith(letterSpacing: FN.track(0.3));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FN.caps('Selamat ${greetingPart(d)} · minggu ke-${isoWeekNumber(d)}'),
            style: FN.label(size: 11, color: FN.inkSoft),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                style: big,
                children: [
                  TextSpan(
                    text: '$day, ${d.day} ${FN.caps(Fmt.monthsShort[d.month - 1])} ',
                  ),
                  TextSpan(
                    text: '${d.year}',
                    style: big.copyWith(color: FN.inkMuted),
                  ),
                ],
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
