import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/data/gym_providers.dart';
import 'package:virya/features/gym/domain/gym_models.dart';

/// Hasil pemilih: [template] null = sesi kosong.
typedef GymStartChoice = ({GymTemplate? template});

Future<GymStartChoice?> showGymTemplatePicker(BuildContext context) =>
    showModalBottomSheet<GymStartChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FN.paper,
      shape: const RoundedRectangleBorder(),
      builder: (_) => const GymTemplatePickerSheet(),
    );

/// Lembar "MULAI GYM": sesi kosong atau salah satu template.
class GymTemplatePickerSheet extends ConsumerWidget {
  const GymTemplatePickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider).valueOrNull ?? const [];
    final lib = ref.watch(exerciseMapProvider);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          children: [
            Text('MULAI GYM', style: FN.label(size: 11, color: FN.ink)),
            const SizedBox(height: 12),
            InkButton(
              label: 'Sesi kosong',
              icon: Icons.add,
              style: InkButtonStyle.primary,
              expand: true,
              onPressed: () =>
                  Navigator.pop<GymStartChoice>(context, (template: null)),
            ),
            if (templates.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text('DARI TEMPLATE', style: FN.label(size: 10)),
              const SizedBox(height: 8),
            ],
            for (final t in templates)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkBox(
                  onTap: () =>
                      Navigator.pop<GymStartChoice>(context, (template: t)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name.toUpperCase(),
                              style: TextStyle(
                                fontFamily: FN.display,
                                fontSize: 20,
                                color: FN.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.items
                                  .map((i) => lib[i.exerciseId]?.name ?? '?')
                                  .join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: FN.label(size: 9.5),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.play_arrow, color: FN.ink),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
