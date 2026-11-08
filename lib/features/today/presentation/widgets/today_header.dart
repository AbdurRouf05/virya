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
    final day = Fmt.daysLong[d.weekday - 1].toUpperCase();
    final big = TextStyle(
      fontFamily: FN.display,
      fontSize: 46,
      height: 1.0,
      color: FN.ink,
      letterSpacing: 0.3,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELAMAT ${greetingPart(d)} · MINGGU KE-${isoWeekNumber(d)}',
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
                    text: '$day, ${d.day} ${Fmt.monthsShort[d.month - 1]} ',
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
