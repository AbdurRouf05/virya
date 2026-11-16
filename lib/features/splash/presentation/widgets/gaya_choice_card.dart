import 'package:flutter/material.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Kartu pilihan gaya di layar pilih gaya. Bingkainya mengikuti gaya aktif;
/// contoh kecil di dalamnya selalu digambar dengan gaya [gaya] sendiri
/// (warna dari [preview]), jadi keduanya bisa dibandingkan.
class GayaChoiceCard extends StatelessWidget {
  final UiGaya gaya;
  final Palette preview;
  final String about;
  final bool selected;
  final VoidCallback onTap;

  const GayaChoiceCard({
    super.key,
    required this.gaya,
    required this.preview,
    required this.about,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${gaya.label}. $about',
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(14),
            decoration: FN.card(
              borderColor: selected ? FN.signal : null,
              width: selected ? 3 : 2,
              shadow: selected,
              shadowOffset: 3,
            ),
            child: Row(
              children: [
                _Preview(gaya: gaya, p: preview),
                const SizedBox(width: 14),
                Expanded(child: _text()),
                const SizedBox(width: 8),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  size: 22,
                  color: selected ? FN.signal : FN.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _text() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(FN.caps(gaya.label), style: FN.title(26, height: 1.0)),
      const SizedBox(height: 4),
      Text(about, style: FN.body(size: 12.5, color: FN.inkSoft)),
    ],
  );
}

/// Kartu jarak mini dalam gaya [gaya] dengan warna [p].
class _Preview extends StatelessWidget {
  final UiGaya gaya;
  final Palette p;
  const _Preview({required this.gaya, required this.p});

  @override
  Widget build(BuildContext context) {
    final clean = gaya == UiGaya.bersih;
    return Container(
      width: 108,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.card ?? p.paper,
        border: Border.all(
          color: clean ? p.paperLine : p.ink,
          width: clean ? 1 : 2,
        ),
        borderRadius: clean ? BorderRadius.circular(12) : null,
        boxShadow:
            clean
                ? null
                : [BoxShadow(color: p.ink, offset: const Offset(3, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            clean ? 'Jarak' : 'JARAK',
            style:
                clean
                    ? TextStyle(
                      fontFamily: p.sans,
                      fontSize: 11,
                      color: p.inkMuted,
                    )
                    : TextStyle(
                      fontFamily: p.mono,
                      fontSize: 9,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                      color: p.inkMuted,
                    ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '42,2',
                  style:
                      clean
                          ? TextStyle(
                            fontFamily: p.sans,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.9,
                            height: 1.0,
                            color: p.ink,
                            fontFeatures: FN.tabular,
                          )
                          : TextStyle(
                            fontFamily: p.display,
                            fontSize: 30,
                            height: 0.95,
                            color: p.ink,
                            fontFeatures: FN.tabular,
                          ),
                ),
                const SizedBox(width: 3),
                Text(
                  clean ? 'km' : 'KM',
                  style: TextStyle(
                    fontFamily: clean ? p.sans : p.mono,
                    fontSize: 10,
                    color: clean ? p.inkMuted : p.signal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(clean ? 3 : 0),
            child: SizedBox(
              height: clean ? 5 : 6,
              child: Row(
                children: [
                  Expanded(flex: 7, child: ColoredBox(color: p.signal)),
                  Expanded(
                    flex: 3,
                    child: ColoredBox(color: clean ? p.paperDeep : p.ink),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
