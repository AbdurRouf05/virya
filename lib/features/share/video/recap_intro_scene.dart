import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/video/recap_draw.dart';
import 'package:virya/features/share/video/recap_stage.dart';
import 'package:virya/features/share/video/recap_timeline.dart';

/// Intro card: sport title reveal, activity title typing, start note.
void paintRecapIntro(Canvas c, RecapStage s, double t) {
  final data = s.data;
  final h = s.h;
  s.background(c, paper: true);
  final ink = FN.ink;
  final a = s.pal.accent == FN.acid ? FN.signal : s.pal.accent;
  recapText(c, 'VIRYA · FIELD NOTES', 22, 40, mono: true, size: 9, color: ink, bold: true);
  recapTextR(c, SF.entryNo(data), 338, 40, size: 9, color: ink);
  final rule = recapEase((t / 0.5).clamp(0, 1));
  c.drawRect(Rect.fromLTWH(22, 56, 316 * rule, 1.6), Paint()..color = ink);

  final y0 = h * 0.36;
  final big = TextPainter(
    text: TextSpan(text: SF.sport(data.sport), style: FN.bigNumber(92, color: ink)),
    textDirection: TextDirection.ltr,
  )..layout();
  final sc = math.min(1.0, 316 / big.width);
  c.save();
  c.translate(22, y0);
  c.scale(sc);
  final reveal = recapEase((t / 0.4).clamp(0, 1));
  c.clipRect(Rect.fromLTWH(0, 0, big.width * reveal, big.height));
  big.paint(c, Offset.zero);
  c.restore();

  final title = data.title.toUpperCase();
  final chars = (title.length * ((t - 0.2) / 0.55).clamp(0.0, 1.0)).round();
  recapText(c, title.substring(0, chars), 22, y0 + big.height * sc + 10,
      size: 15, color: ink, family: FN.sans, bold: true, maxW: 316);
  recapText(c, '${SF.date(data.start)} · MULAI ${SF.time(data.start)}', 22,
      y0 + big.height * sc + 36,
      mono: true, size: 9, color: FN.inkSoft);

  if (t > 0.55) {
    final k = recapEase(((t - 0.55) / 0.3).clamp(0, 1));
    recapNote(c, Offset(22, h * 0.68), [
      SF.coord(data.startLat, data.startLon),
      '${SF.km(data.distanceM)} KM',
    ], a, alpha: k);
  }
  recapText(c, 'RECAP · ${s.timeline.durationS.round()} DTK', 22, h - 40,
      mono: true, size: 8, color: FN.inkMuted);
  s.grain(c, RecapScene.intro);
}
