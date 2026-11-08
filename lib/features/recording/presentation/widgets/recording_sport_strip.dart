import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/features/recording/presentation/widgets/recording_sport_icon.dart';

/// Horizontal quick-pick of sports shown while idle.
class RecordingSportStrip extends StatelessWidget {
  final SportType selected;
  final ValueChanged<SportType> onSelect;

  const RecordingSportStrip({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const _items = [
    (SportType.gravelCycling, 'GRAVEL'),
    (SportType.roadCycling, 'ROAD'),
    (SportType.mountainBiking, 'MTB'),
    (SportType.roadRunning, 'LARI'),
    (SportType.trailRunning, 'TRAIL'),
    (SportType.hiking, 'HIKING'),
    (SportType.walking, 'JALAN'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (sport, label) = _items[index];
          return _SportChip(
            sport: sport,
            label: label,
            selected: sport == selected,
            onTap: () => onSelect(sport),
          );
        },
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  final SportType sport;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SportChip({
    required this.sport,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? FN.onAccent : FN.onNight;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? FN.acid : Colors.transparent,
            border:
                selected ? null : Border.all(color: FN.onNightMuted, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(sportIcon(sport), size: 20, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: FN.label(size: 12, color: fg)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
