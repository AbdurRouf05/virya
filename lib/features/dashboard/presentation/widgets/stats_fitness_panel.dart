import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/dashboard/application/fitness_timeline_provider.dart';

/// Current form verdict + 90-day fitness/fatigue chart.
class StatsFitnessPanel extends ConsumerWidget {
  const StatsFitnessPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(fitnessTimelineProvider);
    final last = days.isEmpty ? null : days.last;
    final st = last == null ? null : formStatus(last.form);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (last != null && st != null)
            InkBox(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  MarkLabel(st.title, color: st.color, fontSize: 14),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          st.note,
                          style: TextStyle(
                            fontFamily: FN.sans,
                            fontSize: 13.5,
                            height: 1.35,
                            color: FN.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'KEBUGARAN ${last.fitness.round()} · '
                          'KELELAHAN ${last.fatigue.round()} · '
                          'BENTUK ${last.form >= 0 ? '+' : ''}${last.form.round()}',
                          style: FN.label(size: 9.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          FitnessChart(days: days),
        ],
      ),
    );
  }
}
