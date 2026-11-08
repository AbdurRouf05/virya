import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Bar istirahat malam: label, progres, hitung mundur, −15 / +15 / LEWATI.
class GymRestBar extends StatelessWidget {
  final int remainingS;
  final int totalS;
  final String? label;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onSkip;

  const GymRestBar({
    super.key,
    required this.remainingS,
    required this.totalS,
    required this.label,
    required this.onMinus,
    required this.onPlus,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final r = remainingS < 0 ? 0 : remainingS;
    final mmss =
        '${(r ~/ 60).toString().padLeft(2, '0')}:${(r % 60).toString().padLeft(2, '0')}';
    final frac = totalS <= 0 ? 0.0 : (1 - r / totalS).clamp(0.0, 1.0);
    return Container(
      color: FN.night,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ['ISTIRAHAT', ?label].join(' · '),
                      overflow: TextOverflow.ellipsis,
                      style: FN
                          .label(size: 10.5, color: FN.acid)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      color: FN.nightLine,
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: frac,
                        child: Container(color: FN.acid),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(mmss, style: FN.bigNumber(44, color: FN.paper)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _btn('−15 D', onMinus, FN.paper),
              const SizedBox(width: 8),
              _btn('+15 D', onPlus, FN.paper),
              const SizedBox(width: 8),
              _btn('LEWATI', onSkip, FN.acid),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(String t, VoidCallback onTap, Color c) => Expanded(
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: c, width: 2)),
        child: Text(
          t,
          style: FN
              .label(size: 11, color: c)
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    ),
  );
}
