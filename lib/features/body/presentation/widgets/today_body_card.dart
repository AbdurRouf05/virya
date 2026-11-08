import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/core/widgets/today_card.dart';
import 'package:virya/features/body/data/body_providers.dart';
import 'package:virya/features/body/domain/body_logic.dart';
import 'package:virya/features/body/domain/body_models.dart';
import 'package:virya/features/body/presentation/body_checkin_screen.dart';

/// Pengingat check-in di layar Hari Ini, hanya saat sudah waktunya. Jarak atas
/// ada di dalam kartu agar tidak tersisa celah saat kartu tersembunyi.
class TodayBodyCard extends ConsumerWidget {
  const TodayBodyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(bodyCheckinDueProvider)) return const SizedBox.shrink();
    final today = ref.watch(currentDayProvider);
    final entries =
        ref.watch(bodyEntriesProvider).valueOrNull ?? const <BodyEntry>[];
    if (entries.isEmpty) return const SizedBox.shrink();
    final days = bodyDaysBetween(entries.first.day, today);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: TodayCard(
        title: 'FOTO TUBUH',
        trailing: 'CHECK-IN →',
        onTap: () => openBodyCheckin(context, today),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            'Sudah $days hari sejak check-in terakhir.',
            style: TextStyle(
              fontFamily: FN.sans,
              fontSize: 14,
              color: FN.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}
