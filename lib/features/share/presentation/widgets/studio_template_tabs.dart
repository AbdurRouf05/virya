import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/domain/share_options.dart';

/// Horizontal template tab strip with an underline on the selected tab.
class StudioTemplateTabs extends StatelessWidget {
  final List<CardTemplate> templates;
  final CardTemplate selected;
  final ValueChanged<CardTemplate> onTap;
  const StudioTemplateTabs({
    super.key,
    required this.templates,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            for (final t in templates)
              GestureDetector(
                onTap: () => onTap(t),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: t == selected ? FN.signal : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    t.label,
                    style: FN.label(
                      size: 11,
                      color: t == selected ? FN.onNight : FN.inkMuted,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      );
}
