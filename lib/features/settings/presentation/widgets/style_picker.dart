import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/app/theme/styles/styles.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Pilihan tampilan: gaya (Tegas/Bersih), lalu warna Tegas atau kecerahan
/// Bersih. Tiap baris warna digambar dengan warnanya sendiri, jadi bisa
/// dibandingkan sebelum diterapkan. Menerapkan pilihan membangun ulang
/// seluruh aplikasi dan kembali ke layar utama.
class StylePicker extends ConsumerStatefulWidget {
  const StylePicker({super.key});

  @override
  ConsumerState<StylePicker> createState() => _StylePickerState();
}

class _StylePickerState extends ConsumerState<StylePicker> {
  UiGaya? _gaya;
  String? _style;
  BersihMode? _mode;

  @override
  Widget build(BuildContext context) {
    final activeGaya = ref.watch(uiGayaProvider);
    final activeStyle = styleById(ref.watch(styleIdProvider)).id;
    final activeMode = ref.watch(bersihModeProvider);
    final gaya = _gaya ?? activeGaya;
    final style = _style ?? activeStyle;
    final mode = _mode ?? activeMode;
    final changed =
        gaya != activeGaya ||
        (gaya == UiGaya.tegas && style != activeStyle) ||
        (gaya == UiGaya.bersih && mode != activeMode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(FN.caps('Gaya'), style: FN.label(size: 10)),
        const SizedBox(height: 6),
        SegmentedPick<UiGaya>(
          options: [for (final g in UiGaya.values) (g, g.label)],
          value: gaya,
          onChanged: (g) => setState(() => _gaya = g),
        ),
        const SizedBox(height: 6),
        Text(
          gaya == UiGaya.tegas
              ? 'Garis tinta tebal, huruf poster, label kapital.'
              : 'Tenang dan rapi: kartu putih, sudut membulat, tanpa bayangan.',
          style: FN.body(size: 12, color: FN.inkSoft),
        ),
        const SizedBox(height: 14),
        if (gaya == UiGaya.tegas) ...[
          Text(FN.caps('Warna'), style: FN.label(size: 10)),
          const SizedBox(height: 6),
          for (final s in allStyles)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StyleTile(
                style: s,
                selected: s.id == style,
                onTap: () => setState(() => _style = s.id),
              ),
            ),
        ] else ...[
          Text(FN.caps('Kecerahan'), style: FN.label(size: 10)),
          const SizedBox(height: 6),
          SegmentedPick<BersihMode>(
            options: [for (final m in BersihMode.values) (m, m.label)],
            value: mode,
            onChanged: (m) => setState(() => _mode = m),
          ),
          const SizedBox(height: 8),
        ],
        if (changed) ...[
          const SizedBox(height: 4),
          InkButton(
            label: FN.caps('Terapkan'),
            onPressed: () => _apply(gaya, style, mode),
          ),
          const SizedBox(height: 6),
          Text(
            'Aplikasi akan kembali ke layar utama. '
            'Kartu dan video yang dibagikan tidak berubah.',
            style: FN.label(size: 10),
          ),
        ],
      ],
    );
  }

  Future<void> _apply(UiGaya gaya, String style, BersihMode mode) async {
    final s = ref.read(settingsProvider.notifier);
    _gaya = null;
    _style = null;
    _mode = null;
    if (gaya == UiGaya.tegas) {
      await s.set(SettingKeys.styleId, style);
    } else {
      await s.set(SettingKeys.bersihMode, mode.name);
    }
    await s.set(SettingKeys.uiGaya, gaya.name);
  }
}

class _StyleTile extends StatelessWidget {
  final Palette style;
  final bool selected;
  final VoidCallback onTap;

  const _StyleTile({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${style.name}. ${style.description}',
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: style.paper,
              border: FN.frame(color: selected ? FN.signal : style.ink, width: selected ? 3 : 1), borderRadius: FN.boxRadius,),
            child: Row(
              children: [
                Expanded(child: _names()),
                for (final c in [style.ink, style.signal, style.acid])
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: c,
                      border: FN.frame(color: style.ink, width: 1), borderRadius: FN.boxRadius,),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _names() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        FN.caps(style.name),
        style: TextStyle(
          fontFamily: style.display,
          fontSize: 20,
          color: style.ink,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        style.description,
        style: TextStyle(
          fontFamily: style.sans,
          fontSize: 12,
          color: style.inkSoft,
        ),
      ),
    ],
  );
}
