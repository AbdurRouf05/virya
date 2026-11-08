import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/templates/parts/mono_label.dart';

/// Row of stats split by hairlines. Colors default to `FN.ink` /
/// `FN.inkMuted` / `FN.ink`.
class StatStrip extends StatelessWidget {
  final List<StatValue> stats;
  final Color? ink;
  final Color? muted;
  final Color? rule;
  final double valueSize;
  const StatStrip({
    super.key,
    required this.stats,
    this.ink,
    this.muted,
    this.rule,
    this.valueSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
    final ink = this.ink ?? FN.ink;
    final muted = this.muted ?? FN.inkMuted;
    final rule = this.rule ?? FN.ink;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) Container(width: 0.8, color: rule),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 7, right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MonoLabel(stats[i].label, size: 7, color: muted),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: stats[i].value,
                              style: FN.bigNumber(valueSize, color: ink),
                            ),
                            if (stats[i].unit.isNotEmpty)
                              TextSpan(
                                text: ' ${stats[i].unit}',
                                style: FN.label(size: 7, color: muted),
                              ),
                          ],
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
