import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/body/data/body_providers.dart';
import 'package:virya/features/body/domain/body_logic.dart';

/// Pilihan jarak pengingat check-in yang muncul di layar Hari Ini.
class BodyReminderPicker extends ConsumerWidget {
  const BodyReminderPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(bodyCheckinIntervalProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final days in bodyCheckinIntervalChoices)
            _Option(
              label: days == 0 ? 'MATI' : '$days HARI',
              selected: days == current,
              onTap: () => ref
                  .read(settingsProvider.notifier)
                  .set(SettingKeys.bodyCheckinDays, '$days'),
            ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? FN.ink : null,
          border: Border.all(color: FN.ink, width: 2),
        ),
        child: Text(
          label,
          style: FN
              .label(size: 11, color: selected ? FN.paper : FN.ink)
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    ),
  );
}
