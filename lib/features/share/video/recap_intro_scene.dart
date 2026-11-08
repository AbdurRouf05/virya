import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:virya/app/theme/export_tokens.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/video/recap_draw.dart';
import 'package:virya/features/share/video/recap_stage.dart';
import 'package:virya/features/share/video/recap_timeline.dart';

/// Intro card: sport title reveal, activity title typing, start note.
void paintRecapIntro(Canvas c, RecapStage s, double t) {
  final data = s.data;
  final h = s.h;
  s.background(c, paper: true);
  final ink = FNExport.ink;
  final a = s.pal.accent == FNExport.acid ? FNExport.signal : s.pal.accent;
  recapText(c, 'VIRYA · FIELD NOTES', 22, 40, mono: true, size: 9, color: ink, bold: true);
  recapTextR(c, SF.entryNo(data), 338, 40, size: 9, color: ink);
  final rule = recapEase((t / 0.5).clamp(0, 1));
  c.drawRect(Rect.fromLTWH(22, 56, 316 * rule, 1.6), Paint()..color = ink);

  final y0 = h * 0.28;
  final big = TextPainter(
    text: TextSpan(text: SF.sport(data.sport), style: FNExport.bigNumber(62, color: ink)),
    textDirection: TextDirection.ltr,
  )..layout();
  final sc = math.min(1.0, 316 / big.width);
  c.save();
  c.translate(22, y0);
  c.scale(sc);
  final reveal = recapEase((t / 0.4).clamp(0, 1));
  // Toleransi vertikal -24..+48 agar ascender font Anton tidak terpotong klip.
  c.clipRect(Rect.fromLTWH(0, -24, big.width * reveal, big.height + 48));
  big.paint(c, Offset.zero);
  c.restore();

  final title = data.title.toUpperCase();
  final chars = (title.length * ((t - 0.2) / 0.55).clamp(0.0, 1.0)).round();
  final titleY = y0 + big.height * sc + 10;
  recapText(c, title.substring(0, chars), 22, titleY,
      size: 14, color: ink, family: FNExport.sans, bold: true, maxW: 316);
  final dateY = titleY + 24;
  recapText(c, '${SF.date(data.start)} · MULAI ${SF.time(data.start)}', 22, dateY,
      mono: true, size: 9, color: FNExport.inkSoft);

  if (t > 0.55) {
    final k = recapEase(((t - 0.55) / 0.3).clamp(0, 1));
    final noteY = math.max(dateY + 36, h * 0.58);
    recapNote(c, Offset(22, noteY), [
      SF.coord(data.startLat, data.startLon),
      '${SF.km(data.distanceM)} KM',
    ], a, alpha: k);
  }
  recapText(c, 'RECAP · ${s.timeline.durationS.round()} DTK', 22, h - 40,
      mono: true, size: 8, color: FNExport.inkMuted);
  s.grain(c, RecapScene.intro);
}
