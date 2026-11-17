import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/updater/update_banner.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/features/today/application/today_controller.dart';
import 'package:virya/features/today/domain/today_models.dart';
import 'package:virya/features/today/presentation/widgets/today_header.dart';
import 'package:virya/features/today/presentation/widgets/today_last_card.dart';
import 'package:virya/features/today/presentation/widgets/today_training_card.dart';
import 'package:virya/features/today/presentation/widgets/today_week_strip.dart';

/// "HARI INI": sapaan + tanggal, tugas, fokus, latihan hari ini & streak,
/// minggu ini, pengingat foto tubuh, dan aktivitas terakhir.
class TodayScreen extends ConsumerWidget {
  /// Dipanggil tombol "MULAI" bila hari ini belum ada latihan.
  final VoidCallback? onStart;

  const TodayScreen({super.key, this.onStart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(todaySummaryProvider);
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          bottom: false,
          child: async.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Center(
              child: Text(
                'Gagal memuat hari ini: $e',
                style: FN.label(size: 12, color: FN.ink),
              ),
            ),
            data: (s) => _content(context, ref, s),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, TodaySummary s) {
    final fmt = ref.watch(fmtProvider);
    const gap = SizedBox(height: 14);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const UpdateBanner(),
        TodayHeader(now: s.now),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ref.read(integrationsProvider).todayTasksCard(),
              ref.read(integrationsProvider).todayFocusCard(),
              TodayTrainingCard(summary: s, fmt: fmt, onStart: onStart),
              gap,
              TodayWeekStrip(week: s.week),
              ref.read(integrationsProvider).todayBodyCard(),
              if (s.last != null) ...[
                gap,
                TodayLastCard(
                  activity: s.last!,
                  fmt: fmt,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ref
                          .read(integrationsProvider)
                          .activityDetail(s.last!.id),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
