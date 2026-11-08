import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/body/domain/body_logic.dart';
import 'package:virya/features/body/domain/body_models.dart';

/// `01 NOV 2026`
String bodyShortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${Fmt.monthsShort[d.month - 1]} ${d.year}';

/// Selisih berat bertanda, mis. `+1,2 kg` atau `−0,4 kg`.
String bodyKgDelta(double delta) {
  final rounded = (delta * 10).round() / 10;
  final sign = rounded > 0 ? '+' : (rounded < 0 ? '−' : '');
  return '$sign${Fmt.number(rounded.abs(), decimals: 1)} kg';
}

/// Grafik berat dari seluruh check-in. Jarak antar titik mengikuti jarak
/// tanggalnya. Tanpa padding luar; pemanggil yang mengatur.
class BodyWeightChart extends StatelessWidget {
  final List<BodyEntry> entries;

  const BodyWeightChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final series = bodyWeightSeries(entries);
    if (series.length < 2) {
      return Text(
        'Catat berat di dua check-in untuk melihat grafik',
        style: TextStyle(fontFamily: FN.sans, fontSize: 14, color: FN.inkMuted),
      );
    }
    final first = series.first;
    final last = series.last;
    final delta = bodyKgDelta(last.kg - first.kg);
    final summary =
        'Grafik berat dari ${_kg(first.kg)} pada ${bodyShortDate(first.day)} '
        'sampai ${_kg(last.kg)} pada ${bodyShortDate(last.day)}, '
        'perubahan $delta.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Text(_kg(last.kg), style: FN.bigNumber(30))),
            Text(delta, style: FN.label(size: 13, color: FN.ink)),
          ],
        ),
        const SizedBox(height: 10),
        Semantics(
          image: true,
          label: summary,
          child: SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _WeightPainter(
                points: _normalize(series),
                line: FN.ink,
                guide: FN.paperLine,
                latest: FN.signal,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _End(day: first.day, kg: first.kg, end: false),
              _End(day: last.day, kg: last.kg, end: true),
            ],
          ),
        ),
      ],
    );
  }

  String _kg(double v) => '${Fmt.number(v, decimals: 1)} kg';

  /// Titik dalam rentang 0–1. Rentang berat diberi ruang supaya garis datar
  /// tidak menempel di tepi dan pembagiannya tidak pernah nol.
  List<Offset> _normalize(List<BodyWeightPoint> series) {
    final values = series.map((p) => p.kg);
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    final pad = math.max((high - low) * 0.15, 0.5);
    final bottom = low - pad;
    final range = high + pad - bottom;
    final span = math.max(
      1,
      bodyDaysBetween(series.first.day, series.last.day),
    );
    return [
      for (final p in series)
        Offset(
          bodyDaysBetween(series.first.day, p.day) / span,
          1 - (p.kg - bottom) / range,
        ),
    ];
  }
}

class _End extends StatelessWidget {
  final DateTime day;
  final double kg;
  final bool end;

  const _End({required this.day, required this.kg, required this.end});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(bodyShortDate(day), style: FN.label(size: 10)),
        Text(
          '${Fmt.number(kg, decimals: 1)} kg',
          style: FN.label(size: 11, color: FN.ink),
        ),
      ],
    );
  }
}

class _WeightPainter extends CustomPainter {
  final List<Offset> points;
  final Color line;
  final Color guide;
  final Color latest;

  _WeightPainter({
    required this.points,
    required this.line,
    required this.guide,
    required this.latest,
  });

  static const _inset = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = guide
      ..strokeWidth = 1;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), guidePaint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      guidePaint,
    );

    Offset place(Offset p) => Offset(
      _inset + p.dx * (size.width - _inset * 2),
      _inset + p.dy * (size.height - _inset * 2),
    );
    final placed = points.map(place).toList();
    final path = Path()..moveTo(placed.first.dx, placed.first.dy);
    for (final p in placed.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    final dot = Paint()..color = line;
    for (final p in placed) {
      canvas.drawCircle(p, 2.5, dot);
    }
    canvas.drawCircle(placed.last, 4.5, Paint()..color = latest);
  }

  @override
  bool shouldRepaint(_WeightPainter old) =>
      old.line != line ||
      old.guide != guide ||
      old.latest != latest ||
      !_same(old.points, points);

  bool _same(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
