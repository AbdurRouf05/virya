import 'package:flutter/material.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/core/widgets/look_preview_parts.dart';

/// Layar mini "Hari ini" yang digambar dengan [palette] dan gayanya sendiri,
/// tidak bergantung pada gaya aktif (`FN`). Dipakai untuk membandingkan
/// Tegas dan Bersih sebelum dipilih. Ukuran mengikuti lebar induk (9:16).
class LookPreview extends StatelessWidget {
  final Palette palette;
  const LookPreview({super.key, required this.palette});

  static const Size _design = Size(180, 320);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _design.width / _design.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: FittedBox(
              child: SizedBox.fromSize(
                size: _design,
                child: _Screen(MiniLook(palette)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Screen extends StatelessWidget {
  final MiniLook l;
  const _Screen(this.l);

  @override
  Widget build(BuildContext context) {
    final p = l.p;
    return ColoredBox(
      color: p.paper,
      child: Stack(
        children: [
          if (!l.clean)
            Positioned.fill(child: CustomPaint(painter: MiniGrid(p.paperLine))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.caps('Senin, 17 nov'), style: l.label()),
                    const SizedBox(height: 2),
                    Text(l.caps('Hari ini'), style: l.title(26)),
                    const SizedBox(height: 10),
                    _week(),
                    const SizedBox(height: 8),
                    _tasks(),
                    const SizedBox(height: 10),
                    _button(),
                  ],
                ),
              ),
              const Spacer(),
              _nav(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _week() {
    final p = l.p;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: l.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.caps('Minggu ini'), style: l.label()),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('42,2', style: l.title(30)),
                const SizedBox(width: 3),
                Text(
                  l.clean ? 'km' : 'KM',
                  style: l.label(color: l.clean ? p.inkMuted : p.signal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(l.clean ? 3 : 0),
            child: SizedBox(
              height: l.clean ? 4 : 5,
              child: Row(
                children: [
                  Expanded(flex: 7, child: ColoredBox(color: p.signal)),
                  Expanded(
                    flex: 3,
                    child: ColoredBox(color: l.clean ? p.paperDeep : p.ink),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tasks() {
    const items = [
      ('Latihan kaki', true),
      ('Lari pagi 5 km', false),
      ('Baca 20 menit', false),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 4),
      decoration: l.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.caps('Tugas'), style: l.label()),
          const SizedBox(height: 4),
          for (final (t, done) in items) _task(t, done),
        ],
      ),
    );
  }

  Widget _task(String t, bool done) {
    final p = l.p;
    final box = Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: done ? (l.clean ? p.signal : p.ink) : null,
        shape: l.clean ? BoxShape.circle : BoxShape.rectangle,
        border:
            done
                ? null
                : Border.all(
                  color: l.clean ? p.inkMuted : p.ink,
                  width: l.clean ? 0.8 : 1.2,
                ),
      ),
      child: done ? Icon(Icons.check, size: 7, color: p.paper) : null,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          box,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              t,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: l.body(color: done ? p.inkMuted : null, strike: done),
            ),
          ),
        ],
      ),
    );
  }

  Widget _button() {
    final p = l.p;
    return Container(
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.signal,
        borderRadius: BorderRadius.circular(l.clean ? 13 : 0),
        border: l.clean ? null : Border.all(color: p.ink, width: 1.5),
        boxShadow:
            l.clean
                ? null
                : [BoxShadow(color: p.ink, offset: const Offset(2.5, 2.5))],
      ),
      child: Text(
        l.caps('Mulai rekam'),
        style:
            l.clean
                ? TextStyle(
                  fontFamily: p.sans,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: p.onAccent,
                )
                : TextStyle(
                  fontFamily: p.display,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: p.onAccent,
                ),
      ),
    );
  }

  Widget _nav() {
    final p = l.p;
    const icons = [
      Icons.today,
      Icons.fitness_center,
      Icons.check_box_outlined,
      Icons.menu_book_outlined,
    ];
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: l.clean ? l.cardFill : p.paper,
        border: Border(
          top: BorderSide(
            color: l.clean ? p.paperLine : p.ink,
            width: l.clean ? 0.8 : 1.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < icons.length; i++)
            Icon(icons[i], size: 12, color: i == 0 ? p.signal : p.inkMuted),
        ],
      ),
    );
  }
}
