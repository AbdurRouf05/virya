import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:virya/app/theme/export_tokens.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/render/paper_painters.dart';

/// Ease-out cubic.
double recapEase(double x) => 1 - math.pow(1 - x, 3).toDouble();

/// Text at ([x],[y]): mono label, sans ([family]) or poster numeral.
/// [color] defaults to `FNExport.ink`.
void recapText(Canvas c, String s, double x, double y,
    {bool mono = false,
    double size = 10,
    Color? color,
    bool bold = false,
    String? family,
    double? maxW}) {
  final col = color ?? FNExport.ink;
  final tp = TextPainter(
    text: TextSpan(
      text: s,
      style: mono || family != null
          ? TextStyle(
              fontFamily: family ?? FNExport.mono,
              fontSize: size,
              letterSpacing: mono ? 1.3 : 0.4,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: col,
            )
          : FNExport.bigNumber(size, color: col),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: maxW != null ? '…' : null,
  )..layout(maxWidth: maxW ?? double.infinity);
  tp.paint(c, Offset(x, y));
}

/// Right-aligned mono text ending at [right]. [color] defaults to `FNExport.ink`.
void recapTextR(Canvas c, String s, double right, double y,
    {double size = 9, Color? color}) {
  final tp = monoText(s, size: size, color: color ?? FNExport.ink);
  tp.paint(c, Offset(right - tp.width, y));
}

/// Straight note block with an accent bar on the left.
void recapNote(Canvas c, Offset topLeft, List<String> lines, Color color,
    {double alpha = 1, Color? fill}) {
  final tps = [
    for (var i = 0; i < lines.length; i++)
      monoText(lines[i],
          size: i == 0 ? 11 : 8.5,
          color: color.withValues(alpha: color.a * alpha),
          weight: FontWeight.w700,
          spacing: 1.4),
  ];
  final w = tps.fold<double>(0, (m, t) => math.max(m, t.width)) + 16;
  final h = tps.fold<double>(0, (m, t) => m + t.height) + 10;
  final dy = (1 - alpha) * 6;
  final r = Rect.fromLTWH(topLeft.dx, topLeft.dy + dy, w, h);
  if (fill != null) {
    c.drawRect(r, Paint()..color = fill.withValues(alpha: 0.9 * alpha));
  }
  c.drawRect(Rect.fromLTWH(r.left, r.top, 3, r.height),
      Paint()..color = color.withValues(alpha: color.a * alpha));
  var y = r.top + 5;
  for (final t in tps) {
    t.paint(c, Offset(r.left + 10, y));
    y += t.height;
  }
}

/// Framed photo print with caption, centered on [center].
void recapPolaroid(Canvas c, ui.Image img, SharePhoto p, Offset center,
    double scale, double alpha) {
  const w = 200.0;
  final ar = img.height / img.width;
  final ih = (w - 16) * ar.clamp(0.6, 1.3);
  final h = ih + 16 + 22;
  c.save();
  c.translate(center.dx, center.dy);
  c.scale(scale);
  final frame = Rect.fromCenter(center: Offset.zero, width: w, height: h);
  c.saveLayer(frame.inflate(20), Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
  c.drawRect(frame.shift(const Offset(3, 5)),
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  c.drawRect(frame, Paint()..color = FNExport.paper);
  final ir = Rect.fromLTWH(frame.left + 8, frame.top + 8, w - 16, ih);
  paintImage(canvas: c, rect: ir, image: img, fit: BoxFit.cover,
      filterQuality: FilterQuality.medium);
  final cap = p.caption?.toUpperCase() ?? 'FOTO';
  recapText(c, '$cap · KM ${SF.km(p.distanceM)}', frame.left + 10, ir.bottom + 6,
      mono: true, size: 7.5, color: FNExport.ink, bold: true, maxW: w - 20);
  c.restore();
  c.restore();
}
