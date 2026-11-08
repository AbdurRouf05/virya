import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/domain/share_options.dart';
import 'package:virya/features/share/render/paper_painters.dart';
import 'package:virya/features/share/render/route_projection.dart';
import 'package:virya/features/share/video/recap_draw.dart';
import 'package:virya/features/share/video/recap_stage.dart';
import 'package:virya/features/share/video/recap_timeline.dart';

/// Outro card: flat route, big distance, stat grid, finish note.
void paintRecapOutro(Canvas c, RecapStage s, double t, double sceneS) {
  final data = s.data;
  final h = s.h;
  s.background(c, paper: true);
  final ink = FN.ink;
  final a = s.pal.accent == FN.acid ? FN.signal : s.pal.accent;
  recapText(c, 'VIRYA · FIELD NOTES', 22, 40, mono: true, size: 9, color: ink, bold: true);
  recapTextR(c, SF.date(data.start), 338, 40, size: 9, color: ink);
  c.drawRect(const Rect.fromLTWH(22, 56, 316, 1.6), Paint()..color = ink);

  final box = Rect.fromLTWH(22, 70, 316, h * 0.42);
  if (data.hasRoute) {
    final pts = RouteProjection.fitPoints(data.lat, data.lon, box, padding: 16);
    paintRoute(c, pts, color: ink, width: 2.4);
    paintStartFinish(c, pts.first, pts.last, color: a, size: 5, fill: FN.paper);
  }
  final y = box.bottom + 10;
  final big = TextPainter(
    text: TextSpan(children: [
      TextSpan(text: SF.km(data.distanceM), style: FN.bigNumber(110, color: ink)),
      TextSpan(text: ' KM', style: FN.bigNumber(28, color: a)),
    ]),
    textDirection: TextDirection.ltr,
  )..layout();
  final sc = math.min(1.0, 316 / big.width);
  c.save();
  c.translate(22, y);
  c.scale(sc);
  big.paint(c, Offset.zero);
  c.restore();
  final gy = y + big.height * sc + 10;
  c.drawRect(Rect.fromLTWH(22, gy, 316, 0.8), Paint()..color = ink);
  final cells = statValues(data, const {
    ShareStat.time,
    ShareStat.elevation,
    ShareStat.speed,
    ShareStat.grit,
  });
  for (var k = 0; k < cells.length && k < 4; k++) {
    final x = 22 + (k % 2) * 160.0, yy = gy + 10 + (k ~/ 2) * 52.0;
    recapText(c, cells[k].label, x, yy, mono: true, size: 7, color: FN.inkMuted);
    recapText(c, '${cells[k].value} ${cells[k].unit}'.trim(), x, yy + 10, size: 28, color: ink);
  }
  if (sceneS > 0.45) {
    final k = recapEase(((sceneS - 0.45) / 0.25).clamp(0.0, 1.0));
    recapNote(c, Offset(22, box.bottom - 34), ['FINIS', SF.coord(data.startLat, data.startLon)],
        a, alpha: k, fill: FN.paper);
  }
  recapText(c, 'DICATAT OFFLINE · VIRYA', 22, h - 40, mono: true, size: 8, color: FN.inkMuted);
  s.grain(c, RecapScene.outro);
}
