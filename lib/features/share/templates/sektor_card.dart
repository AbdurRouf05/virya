import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/core/analytics/analysis_models.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/features/share/domain/share_data.dart';
import 'package:stravo/features/share/domain/share_format.dart';
import 'package:stravo/features/share/domain/share_options.dart';
import 'package:stravo/features/share/templates/card_parts.dart';

/// SEKTOR — classic-race gravel poster: numbered sector list, surface bar,
/// grit score stamp.
class SektorCard extends StatelessWidget {
  final ShareData data;
  final ShareOptions options;
  const SektorCard({super.key, required this.data, required this.options});

  @override
  Widget build(BuildContext context) {
    final f = options.format;
    final accent = options.accent.resolve(dark: false);
    final compact = f == CardFormat.square;
    final maxRows = switch (f) {
      CardFormat.story => 7,
      CardFormat.feed => 4,
      CardFormat.square => 3,
    };
    // Race order: as encountered along the route.
    final sectors = List.of(data.sectors)
      ..sort((a, b) => a.startDistanceM.compareTo(b.startDistanceM));

    return CustomPaint(
      painter: PaperPainter(
        seed: data.seed + 11,
        contour: FN.paperLine.withValues(alpha: 0.55),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          compact ? 14 : 22,
          20,
          compact ? 14 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: MonoLabel(
                    '${SF.sport(data.sport)} · ${SF.date(data.start)}',
                    color: FN.ink,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                MonoLabel(SF.entryNo(data), color: FN.ink),
              ],
            ),
            const SizedBox(height: 5),
            const HairRule(thickness: 1.4),
            const SizedBox(height: 8),
            SizedBox(
              height: compact ? 64 : 92,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: PosterNumber(
                            '${sectors.length} SEKTOR',
                            size: compact ? 44 : 58,
                          ),
                        ),
                        const SizedBox(height: 4),
                        MonoLabel(
                          '${SF.km(data.distanceM)} KM · ${data.gravelPct.round()}% TANPA ASPAL',
                          color: FN.inkSoft,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MonoLabel('GRIT', color: accent),
                      Text(
                          data.gritScore > 0
                              ? data.gritScore.round().toString()
                              : '—',
                          style: FN.bigNumber(compact ? 40 : 56, color: accent)),
                      if (data.gritScore > 0)
                        const MonoLabel('/100', color: FN.inkSoft),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const HairRule(),
            Expanded(
              child: ClipRect(
                child: sectors.isEmpty
                    ? const Center(
                        child: MonoLabel(
                          'TIDAK ADA SEKTOR — MURNI ASPAL',
                          color: FN.inkSoft,
                          size: 9,
                        ),
                      )
                    : Column(
                        children: [
                          for (final s in sectors.take(maxRows))
                            Expanded(
                              child: _SectorRow(sector: s, accent: accent),
                            ),
                          for (
                            var i = sectors.length;
                            i < maxRows && i < 3;
                            i++
                          )
                            const Spacer(),
                        ],
                      ),
              ),
            ),
            if (sectors.length > maxRows)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: MonoLabel(
                  '+${sectors.length - maxRows} SEKTOR LAIN',
                  size: 7,
                ),
              ),
            const SizedBox(height: 6),
            const MonoLabel('KOMPOSISI PERMUKAAN', size: 7),
            const SizedBox(height: 4),
            _SurfaceBar(data: data, height: compact ? 10 : 14),
            const SizedBox(height: 4),
            _SurfaceLegend(data: data),
            if (!compact) ...[
              const SizedBox(height: 8),
              const HairRule(),
              const SizedBox(height: 7),
              StatStrip(
                stats: statValues(
                  data,
                  options.stats,
                ).where((s) => s.label != 'GRIT').toList(),
                valueSize: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectorRow extends StatelessWidget {
  final GravelSector sector;
  final Color accent;
  const _SectorRow({required this.sector, required this.accent});

  @override
  Widget build(BuildContext context) {
    final s = sector;
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: FN.ink, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: PosterNumber(
              s.number.toString().padLeft(2, '0'),
              size: 30,
              color: accent,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: FN.sans,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: FN.ink,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                MonoLabel(
                  '${SF.km(s.lengthM)} KM · ${SF.surface(s.dominantSurface)} · ${s.avgGradePct.toStringAsFixed(1)}%',
                  size: 6.8,
                  spacing: 0.8,
                ),
              ],
            ),
          ),
          Text(
            SF.stars(s.stars),
            style: TextStyle(fontSize: 11, color: accent, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _SurfaceBar extends StatelessWidget {
  final ShareData data;
  final double height;
  const _SurfaceBar({required this.data, required this.height});

  @override
  Widget build(BuildContext context) {
    final entries = SurfaceType.values
        .map((s) => MapEntry(s, data.surfaceDistanceM[s] ?? 0))
        .where((e) => e.value > 0)
        .toList();
    final total = entries.fold<double>(0, (a, e) => a + e.value);
    if (total <= 0) {
      return Container(height: height, color: FN.paperDeep);
    }
    return Container(
      height: height,
      decoration: BoxDecoration(border: Border.all(color: FN.ink, width: 0.8)),
      child: Row(
        children: [
          for (final e in entries)
            Expanded(
              flex: math.max(1, (e.value / total * 1000).round()),
              child: Container(color: FN.surface[e.key]),
            ),
        ],
      ),
    );
  }
}

class _SurfaceLegend extends StatelessWidget {
  final ShareData data;
  const _SurfaceLegend({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.surfaceDistanceM.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 2,
      children: [
        for (final s in SurfaceType.values)
          if ((data.surfaceDistanceM[s] ?? 0) > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, color: FN.surface[s]),
                const SizedBox(width: 3),
                MonoLabel(
                  '${SF.surface(s)} ${((data.surfaceDistanceM[s] ?? 0) / total * 100).round()}%',
                  size: 6.2,
                  spacing: 0.6,
                  color: FN.inkSoft,
                ),
              ],
            ),
      ],
    );
  }
}
