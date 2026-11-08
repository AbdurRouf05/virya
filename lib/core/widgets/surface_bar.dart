import 'package:flutter/material.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/enums.dart';

const surfaceOrder = [
  SurfaceType.asphalt,
  SurfaceType.smoothGravel,
  SurfaceType.roughGravel,
  SurfaceType.dirt,
  SurfaceType.cobblestone,
  SurfaceType.unknown,
];

/// Stacked share bar of surfaces with an optional ledger legend.
class SurfaceBar extends StatelessWidget {
  final Map<SurfaceType, double> distanceM;
  final double height;
  final bool legend;
  final String Function(double meters)? formatDistance;

  const SurfaceBar({
    super.key,
    required this.distanceM,
    this.height = 18,
    this.legend = false,
    this.formatDistance,
  });

  @override
  Widget build(BuildContext context) {
    final total = distanceM.values.fold<double>(0, (a, b) => a + b);
    final fg = Theme.of(context).colorScheme.onSurface;
    final entries = [
      for (final s in surfaceOrder)
        if ((distanceM[s] ?? 0) > 0) (s, distanceM[s]!),
    ];
    final bar = Container(
      height: height,
      decoration: BoxDecoration(border: Border.all(color: fg, width: 1)),
      child: total <= 0
          ? const SizedBox.expand()
          : Row(
              children: [
                for (final (s, d) in entries)
                  Expanded(
                    flex: (d / total * 1000).round().clamp(1, 1000),
                    child: Container(color: FN.surface[s]),
                  ),
              ],
            ),
    );
    if (!legend || total <= 0) return bar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bar,
        const SizedBox(height: 10),
        for (final (s, d) in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: FN.surface[s],
                    border: Border.all(color: fg, width: 0.8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    surfaceShort(s),
                    style: FN.label(size: 11, color: fg),
                  ),
                ),
                if (formatDistance != null)
                  Text(
                    formatDistance!(d),
                    style: FN.label(size: 11, color: fg),
                  ),
                SizedBox(
                  width: 52,
                  child: Text(
                    '${(d / total * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: FN
                        .label(size: 11, color: fg)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Two-part "gravel vs rest" bar used in journal entries.
class GravelShareBar extends StatelessWidget {
  final double gravelPct;
  final double height;
  const GravelShareBar({super.key, required this.gravelPct, this.height = 5});

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final g = gravelPct.clamp(0, 100).toDouble();
    return Container(
      height: height,
      decoration: BoxDecoration(border: Border.all(color: fg, width: 0.8)),
      child: Row(
        children: [
          if (g > 0)
            Expanded(
              flex: g.round().clamp(1, 100),
              child: Container(color: FN.surface[SurfaceType.roughGravel]),
            ),
          if (g < 100)
            Expanded(
              flex: (100 - g).round().clamp(1, 100),
              child: Container(color: FN.paperDeep),
            ),
        ],
      ),
    );
  }
}

/// HR zone stacked bar (Z1..Z5) with per-zone legend.
class HrZoneBar extends StatelessWidget {
  final Map<int, int> zoneSeconds;
  final String Function(int seconds) formatTime;
  const HrZoneBar({
    super.key,
    required this.zoneSeconds,
    required this.formatTime,
  });

  static List<Color> get zoneColors => [
    const Color(0xFFBDB6A6),
    const Color(0xFF8C8A80),
    const Color(0xFFD8B23A),
    const Color(0xFFE8812A),
    FN.signal,
  ];
  static const zoneNames = [
    'PEMULIHAN',
    'DAYA TAHAN',
    'TEMPO',
    'AMBANG',
    'ANAEROBIK',
  ];

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final total = zoneSeconds.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var z = 5; z >= 1; z--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    'Z$z',
                    style: FN
                        .label(size: 11, color: fg)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  width: 86,
                  child: Text(
                    zoneNames[z - 1],
                    style: FN.label(size: 9.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final f = (zoneSeconds[z] ?? 0) / total;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 12,
                          width: (c.maxWidth * f).clamp(1, c.maxWidth),
                          color: zoneColors[z - 1],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    formatTime(zoneSeconds[z] ?? 0),
                    textAlign: TextAlign.right,
                    style: FN.label(size: 11, color: fg),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
