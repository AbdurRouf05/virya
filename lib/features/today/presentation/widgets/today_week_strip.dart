import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/widgets/today_card.dart';
import 'package:virya/features/today/domain/today_models.dart';

/// "MINGGU INI": tujuh kotak Senin–Minggu, diwarnai per kategori olahraga.
class TodayWeekStrip extends StatelessWidget {
  final List<WeekDayCell> week;
  const TodayWeekStrip({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    final active = week.where((d) => d.active).length;
    return TodayCard(
      title: FN.caps('Minggu ini'),
      trailing: FN.caps('$active/7 aktif'),
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
    if (FN.isClean) return _clean();
    final filled = cell.active;
    final numColor = filled ? FN.paper : (cell.isFuture ? FN.inkMuted : FN.ink);
    final border = cell.isToday
        ? FN.frame(color: FN.signal, width: 2.5)
        : filled
        ? null
        : FN.frame(color: cell.isFuture ? FN.inkMuted : FN.ink, width: 1);
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

  /// Bersih: nama hari kecil abu-abu di atas titik bulat.
  Widget _clean() {
    final filled = cell.active;
    return Column(
      children: [
        Text(
          FN.caps(Fmt.daysShort[cell.date.weekday - 1]),
          style: FN.label(
            size: 10,
            color: cell.isToday ? FN.signal : FN.inkMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 30,
          height: 30,
          padding: EdgeInsets.all(cell.isToday ? 2 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: cell.isToday
                ? Border.all(color: FN.signal, width: 1.5)
                : null,
          ),
          child: ClipOval(
            child: CustomPaint(
              painter: _SplitPainter([
                for (final c in cell.categories) FN.category(c),
              ], empty: FN.fill),
              child: Center(
                child: Text(
                  '${cell.date.day}',
                  style: FN.labelStrong(
                    size: 10,
                    color: filled
                        ? FN.onAccent
                        : (cell.isFuture ? FN.inkMuted : FN.inkSoft),
                  ),
                ),
              ),
            ),
          ),
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
