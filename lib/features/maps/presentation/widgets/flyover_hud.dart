import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/maps/domain/flyover_plan.dart';

/// Live stats (distance, elevation, pace/speed, grade, time) at keyframe [k].
class FlyoverHud extends StatelessWidget {
  const FlyoverHud({super.key, required this.k, required this.pace});
  final FlyKeyframe k;

  /// Show pace (min/km) instead of speed.
  final bool pace;

  static String _paceStr(double kmh) {
    if (kmh < 1) return '--:--';
    final s = (3600 / kmh).round();
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  static String _fmtTime(double s) {
    final t = s.round();
    final h = t ~/ 3600, m = (t % 3600) ~/ 60, x = t % 60;
    final mm = m.toString().padLeft(2, '0'), xx = x.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$xx' : '$m:$xx';
  }

  @override
  Widget build(BuildContext context) {
    final gradeCol = k.gradePct < 3 ? FN.paper : FN.grade(k.gradePct);
    return Column(
      children: [
        Row(
          children: [
            _Cell('JARAK', (k.distM / 1000).toStringAsFixed(2), 'KM'),
            _Cell('ELEVASI', '${k.eleM.round()}', 'M'),
            pace
                ? _Cell('TEMPO', _paceStr(k.speedKmh), '/KM')
                : _Cell('KECEPATAN', k.speedKmh.toStringAsFixed(1), 'KM/J'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Cell(
              'TANJAKAN',
              '${k.gradePct >= 0 ? '+' : ''}${k.gradePct.toStringAsFixed(1)}',
              '%',
              color: gradeCol,
            ),
            _Cell('WAKTU', _fmtTime(k.elapsedS), ''),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.label, this.value, this.unit, {this.color});
  final String label, value, unit;

  /// Defaults to [FN.paper].
  final Color? color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: FN.label(size: 9, color: FN.inkMuted)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: FN.bigNumber(30, color: color ?? FN.paper),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: FN.label(size: 10, color: FN.paperLine),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
