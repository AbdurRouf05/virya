import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/render/paper_painters.dart';
import 'package:virya/features/share/render/topo_ink_renderer.dart';
import 'package:virya/features/share/video/recap_draw.dart';
import 'package:virya/features/share/video/recap_stage.dart';
import 'package:virya/features/share/video/recap_timeline.dart';

/// Route scene: Topo-Ink flyover with HUD, surface, elevation strip,
/// sector notes and photo pop-ups.
void paintRecapRoute(Canvas c, RecapStage s, RecapFrame f) {
  final data = s.data;
  final h = s.h;
  final pal = s.pal;
  s.background(c, paper: !s.night);
  final p = f.progress;
  final yaw = -0.75 + f.local * 1.3;
  final vp = Rect.fromLTWH(0, h * 0.17, 360, h * 0.58);
  s.topo.paint(c, Size(360, h),
      t: p,
      yaw: yaw,
      tilt: 1.0,
      viewport: vp,
      style: s.night
          ? TopoInkStyle.night(accent: pal.accent, background: false)
          : TopoInkStyle.paper(accent: pal.accent, background: false));

  final idx = data.indexAtDistance(p * s.seriesTotal);
  final distShown = p * data.distanceM;
  _hud(c, s, idx, distShown);

  // Surface under the tracer.
  if (data.surface.isNotEmpty) {
    final sf = data.surface[idx.clamp(0, data.surface.length - 1)];
    final y = h * 0.77;
    c.drawRect(Rect.fromLTWH(22, y + 1, 8, 8), Paint()..color = FN.surface[sf]!);
    recapText(c, 'PERMUKAAN · ${SF.surface(sf)}', 36, y,
        mono: true, size: 8, color: pal.ink, bold: true);
  }
  if (data.dist.length >= 2) _elevationStrip(c, s, p, idx, distShown);

  // Sector notes while inside a sector.
  for (var i = 0; i < data.sectors.length; i++) {
    final sec = data.sectors[i];
    final enter = s.sectorFrames[i];
    final d = p * s.seriesTotal;
    final age = (f.index - enter) / s.fps;
    final inside = d >= sec.startDistanceM && d <= sec.endDistanceM;
    if (age < 0 || !(inside || age < 1.4)) continue;
    final fade = (age / 0.25).clamp(0.0, 1.0);
    recapNote(c, Offset(22, h * 0.2), [
      'SEKTOR ${sec.number}  ${SF.stars(sec.stars)}',
      '${SF.km(sec.lengthM)} KM · ${SF.surface(sec.dominantSurface)}',
    ], pal.accent, alpha: fade, fill: pal.bg);
    break;
  }

  // Photo pop-ups.
  for (final (photo, img, at) in s.photos) {
    final age = (f.index - at) / s.fps;
    if (age < 0 || age > 2.2) continue;
    final inAlpha = (age / 0.28).clamp(0.0, 1.0);
    final outAlpha = age > 1.9 ? (1 - (age - 1.9) / 0.3).clamp(0.0, 1.0) : 1.0;
    final alpha = math.min(inAlpha, outAlpha);
    recapPolaroid(c, img, photo, Offset(180, h * 0.44), 1.0, alpha);
  }
  s.grain(c, RecapScene.route);
}

void _hud(Canvas c, RecapStage s, int idx, double distShown) {
  final data = s.data;
  final pal = s.pal;
  final gain = s.gain.isEmpty ? 0.0 : s.gain[idx.clamp(0, s.gain.length - 1)];
  var sp = 0.0, n = 0;
  for (var j = math.max(0, idx - 3); j <= math.min(data.speed.length - 1, idx + 3); j++) {
    sp += data.speed[j];
    n++;
  }
  sp = n == 0 ? 0 : sp / n;

  recapText(c, data.title.toUpperCase(), 22, 26,
      mono: true, size: 8, color: pal.muted, maxW: 230);
  recapTextR(c, SF.date(data.start), 338, 26, size: 8, color: pal.muted);
  c.drawRect(Rect.fromLTWH(22, 40, 316, 0.8), Paint()..color = pal.line);
  recapText(c, 'JARAK', 22, 50, mono: true, size: 7, color: pal.muted);
  final dv = TextPainter(
    text: TextSpan(children: [
      TextSpan(text: SF.km(distShown), style: FN.bigNumber(58, color: pal.ink)),
      TextSpan(text: ' KM', style: FN.bigNumber(18, color: pal.accent)),
    ]),
    textDirection: TextDirection.ltr,
  )..layout();
  dv.paint(c, const Offset(22, 62));
  recapText(c, 'ELEV', 232, 50, mono: true, size: 7, color: pal.muted);
  recapText(c, '+${gain.round()} M', 232, 60, size: 24, color: pal.ink);
  final runner = data.sport.isRunning;
  recapText(c, runner ? 'PACE' : 'KEC', 232, 92, mono: true, size: 7, color: pal.muted);
  recapText(c, runner ? '${SF.pace(sp)}/KM' : '${SF.kmh(sp)} KM/J', 232, 102,
      size: 24, color: pal.ink);
}

void _elevationStrip(Canvas c, RecapStage s, double p, int idx, double distShown) {
  final data = s.data;
  final pal = s.pal;
  final night = s.night;
  final strip = Rect.fromLTWH(22, s.h * 0.81, 316, s.h * 0.11);
  final pts = paintElevation(c, strip,
      dist: data.dist,
      ele: data.ele,
      grade: data.grade,
      byGrade: !night,
      fill: night ? pal.panel : FN.ink,
      edge: night ? pal.muted : FN.ink,
      edgeWidth: 1,
      hatch: !night,
      headroom: 0.05);
  final cx = strip.left + strip.width * p;
  if (night) {
    c.save();
    c.clipRect(Rect.fromLTRB(strip.left, strip.top - 2, cx, strip.bottom));
    final path = Path()..moveTo(pts.first.dx, strip.bottom);
    for (final q in pts) {
      path.lineTo(q.dx, q.dy);
    }
    path
      ..lineTo(pts.last.dx, strip.bottom)
      ..close();
    c.drawPath(path, Paint()..color = pal.accent.withValues(alpha: 0.35));
    c.restore();
  }
  c.drawLine(Offset(cx, strip.top - 6), Offset(cx, strip.bottom),
      Paint()
        ..color = pal.accent
        ..strokeWidth = 1.4);
  final cy = pts[idx.clamp(0, pts.length - 1)].dy;
  c.drawCircle(Offset(cx, cy), 3.2, Paint()..color = pal.accent);
  recapText(c, '${SF.km(distShown)} KM', math.min(cx + 4, 300), strip.top - 10,
      mono: true, size: 7, color: pal.accent, bold: true);
}
