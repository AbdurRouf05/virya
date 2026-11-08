import 'package:flutter/material.dart';
import 'package:virya/app/theme/export_tokens.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/domain/share_options.dart';
import 'package:virya/features/share/templates/card_parts.dart';

/// FIELD NOTES — expedition notebook page: contour paper, inked route,
/// giant distance, mono stat row, coordinate stamp, sector stamps.
class FieldNotesCard extends StatelessWidget {
  final ShareData data;
  final ShareOptions options;
  const FieldNotesCard({super.key, required this.data, required this.options});

  @override
  Widget build(BuildContext context) {
    final f = options.format;
    final accent = options.accent.resolve(dark: false);
    final isStory = f == CardFormat.story;
    final isSquare = f == CardFormat.square;
    final big = switch (f) {
      CardFormat.story => 132.0,
      CardFormat.feed => 84.0,
      CardFormat.square => 70.0,
    };
    final sectors = data.sectors;
    final topSector = sectors.isEmpty
        ? null
        : (List.of(sectors)..sort((a, b) => b.stars.compareTo(a.stars))).first;

    return CustomPaint(
      painter: PaperPainter(seed: data.seed),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          isStory ? 22 : (isSquare ? 14 : 16),
          20,
          isStory ? 20 : (isSquare ? 12 : 14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: MonoLabel(
                    'VIRYA · FIELD NOTES',
                    color: FNExport.ink,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                MonoLabel(SF.entryNo(data), color: FNExport.ink),
              ],
            ),
            const SizedBox(height: 5),
            const HairRule(thickness: 1.4),
            const SizedBox(height: 2),
            const HairRule(thickness: 0.5),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: MonoLabel(
                    '${SF.sport(data.sport)} · ${SF.date(data.start)}',
                    color: FNExport.inkSoft,
                  ),
                ),
                const SizedBox(width: 8),
                MonoLabel('MULAI ${SF.time(data.start)}', color: FNExport.inkSoft),
              ],
            ),
            if (isStory) ...[
              const SizedBox(height: 4),
              Text(
                data.title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FNExport.sans,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: FNExport.ink,
                ),
              ),
            ],
            Expanded(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: RouteMapPainter(
                        data: data,
                        accent: accent,
                        sectors: true,
                        width: 2.2,
                        markFill: FNExport.paper,
                        padding: isStory ? 24 : 14,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: isStory ? 12 : 4,
                    child: CardNote(
                      lines: [
                        SF.coord(data.startLat, data.startLon),
                        'TITIK NOL',
                      ],
                      color: FNExport.ink,
                      size: isStory ? 7.5 : 7.0,
                    ),
                  ),
                  if (topSector != null && isStory)
                    Positioned(
                      left: 0,
                      bottom: 6,
                      child: CardNote(
                        lines: [
                          'SEKTOR ${topSector.number} ${SF.stars(topSector.stars)}',
                          '${SF.km(topSector.lengthM)} KM · ${SF.surface(topSector.dominantSurface)}',
                        ],
                        color: accent,
                        size: 8,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: PosterNumber(SF.km(data.distanceM), size: big)),
                const SizedBox(width: 6),
                Padding(
                  padding: EdgeInsets.only(bottom: big * 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'KM',
                        style: FNExport.bigNumber(big * 0.22, color: accent),
                      ),
                      const MonoLabel('JARAK', size: 7),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const HairRule(),
            const SizedBox(height: 6),
            StatStrip(
              stats: statValues(data, options.stats),
              valueSize: isStory ? 22 : 18,
            ),
            const SizedBox(height: 6),
            const HairRule(),
            if (isStory) ...[
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: MonoLabel(
                      sectors.isEmpty
                          ? '${data.gravelPct.round()}% TANPA ASPAL'
                          : '★ ${sectors.length} SEKTOR · ${data.gravelPct.round()}% TANPA ASPAL',
                      color: accent,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const MonoLabel('DICATAT OFFLINE', size: 7),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
