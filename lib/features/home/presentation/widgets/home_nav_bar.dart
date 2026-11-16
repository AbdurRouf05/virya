import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/home/presentation/widgets/record_button.dart';

/// Bottom bar: HARI INI · KALENDER · [REKAM] · LATIHAN · PROFIL.
///
/// [onRecord] is called by the centre button (the shell opens the
/// quick-start sheet with it).
///
/// The widget is [_raise] px taller than the visible bar so the round record
/// button can rise above the bar edge and still receive taps.
class FieldNotesNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTab;
  final VoidCallback onRecord;

  const FieldNotesNavBar({
    super.key,
    required this.index,
    required this.onTab,
    required this.onRecord,
  });

  static const _tabs = ['Hari ini', 'Kalender', 'Latihan', 'Profil'];
  static const _barHeight = 64.0;
  static const _raise = 14.0;
  static const _centerWidth = 84.0;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    Widget tab(int i) => Expanded(
      child: _NavTab(
        number: (i + 1).toString().padLeft(2, '0'),
        label: _tabs[i],
        selected: index == i,
        onTap: () => onTab(i),
      ),
    );
    return SizedBox(
      height: _raise + _barHeight + bottom,
      child: Stack(
        children: [
          Positioned.fill(
            top: _raise,
            child: Container(
              decoration: BoxDecoration(
                color: FN.paper,
                border: Border(
                  top: FN.side(color: FN.cardLine, width: FN.stroke),
                ),
              ),
              padding: EdgeInsets.only(bottom: bottom),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  tab(0),
                  tab(1),
                  const SizedBox(width: _centerWidth),
                  tab(2),
                  tab(3),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: bottom,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: _centerWidth,
                child: RecordButton(onTap: onRecord),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final String number;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavTab({
    required this.number,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (FN.isClean) return _clean();
    final fg = selected ? FN.paper : FN.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: FN.caps(label),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.fromLTRB(3, 6, 3, 6),
          color: selected ? FN.ink : Colors.transparent,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: FN.label(
                  size: 9,
                  color: selected ? FN.signal : FN.inkMuted,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  FN.caps(label),
                  style: FN
                      .label(size: 10.5, color: fg)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bersih: teks saja; tab aktif tinta tebal, lainnya abu-abu.
  Widget _clean() => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: selected
                ? FN.heading(size: 12.5, color: FN.ink)
                : FN.label(size: 11, color: FN.inkMuted),
          ),
        ),
      ),
    ),
  );
}
