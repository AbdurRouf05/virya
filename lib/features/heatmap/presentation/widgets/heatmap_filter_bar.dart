import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/heatmap/domain/heatmap_builder.dart';

/// Pilihan kategori heatmap.
class HeatmapFilterBar extends StatelessWidget {
  final HeatmapFilter selected;
  final ValueChanged<HeatmapFilter> onChanged;

  const HeatmapFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final f in HeatmapFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: StampChip(
                text: f.label,
                selected: f == selected,
                onTap: () => onChanged(f),
              ),
            ),
        ],
      ),
    );
  }
}
