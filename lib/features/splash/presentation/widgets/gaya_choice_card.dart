import 'package:flutter/material.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/core/widgets/look_preview.dart';

/// Kartu pilihan gaya: layar contoh "Hari ini" yang digambar dengan gaya
/// [gaya] sendiri (warna dari [preview]), lalu nama dan penjelasannya.
/// Bingkai kartu mengikuti gaya aktif. Dua kartu dipasang berdampingan
/// supaya mudah dibandingkan.
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
            padding: const EdgeInsets.all(10),
            decoration: FN.card(
              borderColor: selected ? FN.signal : null,
              width: selected ? 3 : 2,
              shadow: selected,
              shadowOffset: 3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LookPreview(palette: preview),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        FN.caps(gaya.label),
                        style: FN.title(24, height: 1.0),
                      ),
                    ),
                    Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      size: 20,
                      color: selected ? FN.signal : FN.inkMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(about, style: FN.body(size: 12, color: FN.inkSoft)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
