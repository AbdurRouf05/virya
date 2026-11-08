import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/app/theme/styles/styles.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Pilihan tampilan. Tiap baris digambar dengan warna style-nya sendiri, jadi
/// bisa dibandingkan sebelum diterapkan. Menerapkan style membangun ulang
/// seluruh aplikasi dan kembali ke layar utama.
class StylePicker extends ConsumerStatefulWidget {
  const StylePicker({super.key});

  @override
  ConsumerState<StylePicker> createState() => _StylePickerState();
}

class _StylePickerState extends ConsumerState<StylePicker> {
  String? _chosen;

  @override
  Widget build(BuildContext context) {
    final active = styleById(ref.watch(styleIdProvider)).id;
    final chosen = _chosen ?? active;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in allStyles)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _StyleTile(
              style: s,
              selected: s.id == chosen,
              onTap: () => setState(() => _chosen = s.id),
            ),
          ),
        if (chosen != active) ...[
          const SizedBox(height: 4),
          InkButton(
            label: 'TERAPKAN',
            onPressed: () => ref
                .read(settingsProvider.notifier)
                .set(SettingKeys.styleId, chosen),
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
              border: Border.all(
                color: selected ? FN.signal : style.ink,
                width: selected ? 3 : 1,
              ),
            ),
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
                      border: Border.all(color: style.ink),
                    ),
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
        style.name.toUpperCase(),
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
