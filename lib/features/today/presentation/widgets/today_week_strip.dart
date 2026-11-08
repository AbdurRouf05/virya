import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/today/domain/today_models.dart';
import 'package:virya/features/today/presentation/widgets/today_card.dart';

/// "MINGGU INI": tujuh kotak Senin–Minggu, diwarnai per kategori olahraga.
class TodayWeekStrip extends StatelessWidget {
  final List<WeekDayCell> week;
  const TodayWeekStrip({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    final active = week.where((d) => d.active).length;
    return TodayCard(
      title: 'MINGGU INI',
      trailing: '$active/7 AKTIF',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Row(
          children: [
            for (var i = 0; i < week.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(child: _DayColumn(cell: week[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  final WeekDayCell cell;
  const _DayColumn({required this.cell});

  @override
  Widget build(BuildContext context) {
    final filled = cell.active;
    final numColor = filled ? FN.paper : (cell.isFuture ? FN.inkMuted : FN.ink);
    final border = cell.isToday
        ? Border.all(color: FN.signal, width: 2.5)
        : filled
        ? null
        : Border.all(color: cell.isFuture ? FN.inkMuted : FN.ink);
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.1,
          child: Container(
            decoration: BoxDecoration(border: border),
            child: CustomPaint(
              painter: _SplitPainter([
                for (final c in cell.categories) FN.category(c),
              ], empty: cell.isFuture ? FN.paper : FN.paperDeep),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 4),
                  child: Text(
                    '${cell.date.day}',
                    style: FN
                        .label(size: 11, color: numColor)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          Fmt.daysShort[cell.date.weekday - 1],
          style: FN
              .label(size: 10, color: cell.isToday ? FN.signal : FN.ink)
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// 1 warna: penuh. 2 warna: dibelah diagonal. 3+: lajur tegak sama lebar.
class _SplitPainter extends CustomPainter {
  final List<Color> colors;
  final Color empty;
  _SplitPainter(this.colors, {required this.empty});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final p = Paint();
    if (colors.isEmpty) {
      canvas.drawRect(rect, p..color = empty);
    } else if (colors.length == 1) {
      canvas.drawRect(rect, p..color = colors.first);
    } else if (colors.length == 2) {
      canvas.drawRect(rect, p..color = colors[0]);
      final tri = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(tri, p..color = colors[1]);
    } else {
      final w = size.width / colors.length;
      for (var i = 0; i < colors.length; i++) {
        canvas.drawRect(
          Rect.fromLTWH(i * w, 0, w + 0.5, size.height),
          p..color = colors[i],
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SplitPainter old) =>
      old.empty != empty || !_sameColors(old.colors, colors);

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
