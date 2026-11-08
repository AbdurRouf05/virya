import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/domain/share_options.dart';
import 'package:virya/features/share/render/paper_painters.dart';
import 'package:virya/features/share/templates/card_parts.dart';

/// PROFIL — the ride as a mountain: grade-colored silhouette with annotated
/// climbs and minimal stats.
class ProfilCard extends StatelessWidget {
  final ShareData data;
  final ShareOptions options;
  const ProfilCard({super.key, required this.data, required this.options});

  @override
  Widget build(BuildContext context) {
    final f = options.format;
    final accent = options.accent.resolve(dark: false);
    final compact = f == CardFormat.square;
    final big = switch (f) {
      CardFormat.story => 92.0,
      CardFormat.feed => 70.0,
      CardFormat.square => 54.0,
    };
    final stats = statValues(
      data,
      options.stats,
    ).where((s) => s.label != 'ELEV').take(3).toList();

    return CustomPaint(
      painter: PaperPainter(
        seed: data.seed + 5,
        contour: FN.paperLine.withValues(alpha: 0.5),
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
                    'PROFIL ELEVASI',
                    color: FN.ink,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                MonoLabel(SF.date(data.start), color: FN.ink),
              ],
            ),
            const SizedBox(height: 5),
            const HairRule(thickness: 1.4),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: PosterNumber(
                    '+${SF.meters(data.elevationGainM)}',
                    size: big,
                  ),
                ),
                const SizedBox(width: 5),
                Padding(
                  padding: EdgeInsets.only(bottom: big * 0.1),
                  child: Text(
                    'M',
                    style: FN.bigNumber(big * 0.3, color: accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            MonoLabel(
              '${SF.km(data.distanceM)} KM · PUNCAK ${SF.meters(data.maxEleM)} MDPL · ${data.climbs.length} TANJAKAN',
              color: FN.inkSoft,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: CustomPaint(
                painter: _ProfilePainter(
                  data: data,
                  accent: accent,
                  compact: compact,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 6),
            _GradeLegend(),
            const SizedBox(height: 8),
            const HairRule(),
            const SizedBox(height: 7),
            StatStrip(stats: stats, valueSize: compact ? 17 : 21),
          ],
        ),
      ),
    );
  }
}

class _GradeLegend extends StatelessWidget {
  static const _steps = [
    (0.0, '<3'),
    (4.0, '3-5'),
    (6.0, '5-8'),
    (9.0, '8-11'),
    (12.0, '11-15'),
    (16.0, '15+'),
  ];
  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MonoLabel('KEMIRINGAN %', size: 6.5),
        const SizedBox(width: 6),
        for (final s in _steps) ...[
          Container(width: 8, height: 8, color: FN.grade(s.$1)),
          const SizedBox(width: 2),
          MonoLabel(s.$2, size: 6.2, spacing: 0.4, color: FN.inkSoft),
          const SizedBox(width: 5),
        ],
      ],
    ),
  );
}

class _ProfilePainter extends CustomPainter {
  final ShareData data;
  final Color accent;
  final bool compact;
  _ProfilePainter({
    required this.data,
    required this.accent,
    required this.compact,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.dist.length < 2) return;
    const axis = 12.0;
    final top = compact ? 26.0 : 54.0;
    final rect = Rect.fromLTRB(0, top, size.width, size.height - axis);
    final pts = paintElevation(
      canvas,
      rect,
      dist: data.dist,
      ele: data.ele,
      grade: data.grade,
      hatch: true,
      hatchColor: const Color(0x26000000),
      edgeWidth: 1.6,
    );
    if (pts.isEmpty) return;

    // Km ticks.
    final total = data.dist.last - data.dist.first;
    final km = total / 1000;
    final stepKm = km > 80
        ? 20
        : km > 40
        ? 10
        : km > 15
        ? 5
        : km > 5
        ? 2
        : 1;
    final tick = Paint()
      ..color = FN.ink
      ..strokeWidth = 0.8;
    for (var k = 0; k <= km; k += stepKm) {
      final x = rect.left + k * 1000 / math.max(total, 1) * rect.width;
      canvas.drawLine(Offset(x, rect.bottom), Offset(x, rect.bottom + 3), tick);
      final tp = monoText('$k', size: 6.5, color: FN.inkMuted, spacing: 0.4);
      tp.paint(
        canvas,
        Offset(math.min(x + 1.5, size.width - tp.width), rect.bottom + 3),
      );
    }

    // Climb annotations (largest first, staggered).
    final climbs = List.of(data.climbs)
      ..sort((a, b) => b.gainM.compareTo(a.gainM));
    final placed = <Rect>[];
    var lane = 0;
    for (final c in climbs.take(compact ? 2 : 4)) {
      final i = data.indexAtDistance(c.endDistanceM).clamp(0, pts.length - 1);
      final peak = pts[i];
      final l1 = monoText(
        SF.climbCat(c.category),
        size: 8,
        color: accent,
        weight: FontWeight.w700,
      );
      final l2 = monoText(
        '+${c.gainM.round()} M · ${c.avgGradePct.toStringAsFixed(1)}% · ${SF.km(c.lengthM)} KM',
        size: 6.2,
        color: FN.ink,
        spacing: 0.5,
      );
      final w = math.max(l1.width, l2.width) + 8;
      final h = l1.height + l2.height + 5;
      var y = math.max(2.0, peak.dy - 26 - h - lane * (h + 4));
      var x = (peak.dx - w / 2).clamp(0.0, size.width - w);
      var box = Rect.fromLTWH(x, y, w, h);
      while (placed.any((r) => r.overlaps(box.inflate(2))) && y > 0) {
        y -= h + 4;
        box = Rect.fromLTWH(x, math.max(0, y), w, h);
        if (y <= 0) break;
      }
      placed.add(box);
      lane = (lane + 1) % 2;
      canvas.drawLine(
        Offset(peak.dx, peak.dy - 3),
        Offset(peak.dx, box.bottom),
        Paint()
          ..color = FN.ink
          ..strokeWidth = 0.7,
      );
      canvas.drawCircle(peak, 2.6, Paint()..color = accent);
      canvas.drawRect(box, Paint()..color = FN.paper);
      canvas.drawRect(
        box,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = FN.ink,
      );
      l1.paint(canvas, box.topLeft + const Offset(4, 2));
      l2.paint(canvas, box.topLeft + Offset(4, 3 + l1.height));
    }

    // Max/min elevation marks.
    final hi = monoText(
      '${SF.meters(data.maxEleM)} M',
      size: 6.5,
      color: FN.inkMuted,
    );
    hi.paint(canvas, Offset(size.width - hi.width, top - hi.height - 1));
  }

  @override
  bool shouldRepaint(_ProfilePainter old) =>
      old.data != data || old.accent != accent;
}
