import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/render/paper_painters.dart';
import 'package:virya/features/share/render/route_projection.dart';

/// 2D route map with start/finish and optional sector tags.
/// [ink] defaults to `FN.ink`, [accent] to `FN.signal`.
class RouteMapPainter extends CustomPainter {
  final ShareData data;
  final Color? ink;
  final Color? accent;
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
    this.ink,
    this.accent,
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
    final ink = this.ink ?? FN.ink;
    final accent = this.accent ?? FN.signal;
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
    if (sectors) _paintSectors(canvas, size, pts, ink, accent);
    paintStartFinish(
      canvas,
      pts.first,
      pts.last,
      color: accent,
      size: 5,
      fill: markFill,
    );
  }

  void _paintSectors(
      Canvas canvas, Size size, List<Offset> pts, Color ink, Color accent) {
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
      final away =
          dir.distance < 1e-3 ? const Offset(0, -1) : dir / dir.distance;
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

  @override
  bool shouldRepaint(RouteMapPainter old) =>
      old.data != data || old.ink != ink || old.accent != accent;
}
