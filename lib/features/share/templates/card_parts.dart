import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/features/share/domain/share_data.dart';
import 'package:stravo/features/share/domain/share_format.dart';
import 'package:stravo/features/share/render/paper_painters.dart';
import 'package:stravo/features/share/render/route_projection.dart';

/// Mono uppercase label.
class MonoLabel extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final FontWeight weight;
  final double spacing;
  final TextAlign? align;
  const MonoLabel(
    this.text, {
    super.key,
    this.size = 8,
    this.color = FN.inkMuted,
    this.weight = FontWeight.w500,
    this.spacing = 1.4,
    this.align,
  });

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    textAlign: align,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    softWrap: false,
    style: TextStyle(
      fontFamily: FN.mono,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color,
      height: 1.15,
    ),
  );
}

/// Anton poster numeral that shrinks to fit.
class PosterNumber extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final List<Shadow>? shadows;
  final Alignment alignment;
  const PosterNumber(
    this.text, {
    super.key,
    required this.size,
    this.color = FN.ink,
    this.shadows,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: alignment,
    child: Text(
      text,
      maxLines: 1,
      style: FN
          .bigNumber(size, color: color)
          .copyWith(height: 0.9, shadows: shadows),
    ),
  );
}

class HairRule extends StatelessWidget {
  final Color color;
  final double thickness;
  const HairRule({super.key, this.color = FN.ink, this.thickness = 0.8});
  @override
  Widget build(BuildContext context) =>
      Container(height: thickness, color: color);
}

/// Catatan lurus dengan garis aksen di kiri (pengganti Stamp).
class CardNote extends StatelessWidget {
  final List<String> lines;
  final Color color;
  final double size;
  const CardNote({super.key, required this.lines, this.color = FN.signal, this.size = 9});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(left: size * 0.7),
        decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: size * 0.25))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lines.length; i++)
              Text(lines[i],
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: FN.mono,
                    fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                    fontSize: i == 0 ? size : size * 0.82,
                    letterSpacing: 1.4,
                    color: color,
                    height: 1.25,
                  )),
          ],
        ),
      );
}

/// Row of stats split by hairlines.
class StatStrip extends StatelessWidget {
  final List<StatValue> stats;
  final Color ink;
  final Color muted;
  final Color rule;
  final double valueSize;
  const StatStrip({
    super.key,
    required this.stats,
    this.ink = FN.ink,
    this.muted = FN.inkMuted,
    this.rule = FN.ink,
    this.valueSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
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

/// Paper background: fill, contours, grain.
class PaperPainter extends CustomPainter {
  final int seed;
  final Color fill;
  final Color contour;
  final Color? indexContour;
  final bool grain;
  final Color grainDark;
  final Color grainLight;
  const PaperPainter({
    required this.seed,
    this.fill = FN.paper,
    this.contour = FN.paperLine,
    this.indexContour,
    this.grain = true,
    this.grainDark = const Color(0x1E141414),
    this.grainLight = const Color(0x40FFFFFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, Paint()..color = fill);
    paintContours(
      canvas,
      r,
      seed: seed,
      color: contour,
      indexColor: indexContour,
      width: 0.6,
    );
    if (grain) {
      paintGrain(
        canvas,
        r,
        seed: seed + 3,
        dark: grainDark,
        light: grainLight,
        density: 0.09,
      );
    }
  }

  @override
  bool shouldRepaint(PaperPainter old) =>
      old.seed != seed || old.fill != fill || old.contour != contour;
}

/// Grain overlay only (on top of photos/content).
class GrainPainter extends CustomPainter {
  final int seed;
  final double density;
  final Color dark;
  final Color light;
  const GrainPainter({
    required this.seed,
    this.density = 0.12,
    this.dark = const Color(0x30000000),
    this.light = const Color(0x30FFFFFF),
  });
  @override
  void paint(Canvas canvas, Size size) => paintGrain(
    canvas,
    Offset.zero & size,
    seed: seed,
    density: density,
    dark: dark,
    light: light,
    dot: 0.8,
  );
  @override
  bool shouldRepaint(GrainPainter old) => old.seed != seed;
}

/// 2D route map with start/finish and optional sector tags.
class RouteMapPainter extends CustomPainter {
  final ShareData data;
  final Color ink;
  final Color accent;
  final double width;
  final bool bleed;
  final bool sectors;
  final Color? outline;
  final double outlineWidth;
  final Shadow? shadow;
  final Color? markFill;
  final double padding;

  const RouteMapPainter({
    required this.data,
    this.ink = FN.ink,
    this.accent = FN.signal,
    this.width = 2.2,
    this.bleed = true,
    this.sectors = false,
    this.outline,
    this.outlineWidth = 0,
    this.shadow,
    this.markFill,
    this.padding = 18,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!data.hasRoute) return;
    final pts = RouteProjection.fitPoints(
      data.lat,
      data.lon,
      Offset.zero & size,
      padding: padding,
    );
    paintRoute(
      canvas,
      pts,
      color: ink,
      width: width,
      bleed: bleed,
      outline: outline,
      outlineWidth: outlineWidth,
      shadow: shadow,
    );

    if (sectors) {
      final tick = Paint()
        ..color = accent
        ..strokeWidth = 1.1;
      for (final s in data.sectors.take(6)) {
        final i0 = data.indexAtDistance(s.startDistanceM);
        final i1 = math.max(i0 + 1, data.indexAtDistance(s.endDistanceM));
        final seg = pts.sublist(i0, math.min(i1 + 1, pts.length));
        paintRoute(
          canvas,
          seg,
          color: accent,
          width: width * 1.9,
          bleed: false,
        );
        // Cross-hatch ticks across the sector.
        for (var i = 1; i < seg.length; i += 3) {
          final d = seg[i] - seg[i - 1];
          if (d.distance < 1e-3) continue;
          final nrm = Offset(-d.dy, d.dx) / d.distance * 4.5;
          canvas.drawLine(seg[i] - nrm, seg[i] + nrm, tick);
        }
        final mid = seg[seg.length ~/ 2];
        final label = monoText(
          'S${s.number}  ${SF.stars(s.stars)}',
          size: 6.5,
          color: ink,
          weight: FontWeight.w700,
          spacing: 0.8,
        );
        final dir = (mid - Offset(size.width / 2, size.height / 2));
        final away = dir.distance < 1e-3
            ? const Offset(0, -1)
            : dir / dir.distance;
        final at = mid + away * 16;
        canvas.drawLine(
          mid,
          at,
          Paint()
            ..color = ink
            ..strokeWidth = 0.6,
        );
        final box = Rect.fromLTWH(
          at.dx - (away.dx < 0 ? label.width + 6 : 0),
          at.dy - label.height / 2 - 1.5,
          label.width + 6,
          label.height + 3,
        );
        canvas.drawRect(box, Paint()..color = markFill ?? FN.paper);
        canvas.drawRect(
          box,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7
            ..color = ink,
        );
        label.paint(canvas, box.topLeft + const Offset(3, 1.5));
      }
    }
    paintStartFinish(
      canvas,
      pts.first,
      pts.last,
      color: accent,
      size: 5,
      fill: markFill,
    );
  }

  @override
  bool shouldRepaint(RouteMapPainter old) =>
      old.data != data || old.ink != ink || old.accent != accent;
}

/// Elevation silhouette painter for widgets.
class ElevationPainter extends CustomPainter {
  final ShareData data;
  final bool byGrade;
  final Color fill;
  final Color edge;
  final bool hatch;
  final double? cursorFrac;
  final Color cursor;
  const ElevationPainter({
    required this.data,
    this.byGrade = true,
    this.fill = FN.ink,
    this.edge = FN.ink,
    this.hatch = true,
    this.cursorFrac,
    this.cursor = FN.signal,
  });
  @override
  void paint(Canvas canvas, Size size) {
    paintElevation(
      canvas,
      Offset.zero & size,
      dist: data.dist,
      ele: data.ele,
      grade: data.grade,
      byGrade: byGrade,
      fill: fill,
      edge: edge,
      hatch: hatch,
    );
  }

  @override
  bool shouldRepaint(ElevationPainter old) => old.data != data;
}
