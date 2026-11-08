import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/core/time/day_key.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/body/data/body_providers.dart';
import 'package:virya/features/body/domain/body_models.dart';
import 'package:virya/features/body/presentation/body_checkin_screen.dart';
import 'package:virya/features/body/presentation/body_compare_screen.dart';
import 'package:virya/features/body/presentation/widgets/body_entry_tile.dart';
import 'package:virya/features/body/presentation/widgets/body_timelapse_dialog.dart';
import 'package:virya/features/body/presentation/widgets/body_weight_chart.dart';

/// "PROGRES TUBUH": check-in hari ini, grafik berat, dan foto per tanggal.
class BodyScreen extends ConsumerWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bodyEntriesProvider);
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Gagal memuat progres: $e',
                style: FN.label(size: 12, color: FN.ink),
              ),
            ),
            data: (entries) => _content(context, ref, entries),
          ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    List<BodyEntry> entries,
  ) {
    final today = ref.watch(currentDayProvider);
    final hasToday = ref.watch(bodyEntryOnProvider(dayKeyOf(today))) != null;
    return ListView(
      padding: const EdgeInsets.only(bottom: 48),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Kembali',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ],
        ),
        const Masthead(kicker: 'Foto & ukuran', title: 'Progres tubuh'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: InkButton(
            label: hasToday ? 'Lanjutkan hari ini' : 'Check-in hari ini',
            icon: Icons.photo_camera_outlined,
            style: InkButtonStyle.primary,
            expand: true,
            onPressed: () => openBodyCheckin(context, today),
          ),
        ),
        if (entries.isEmpty)
          const _Empty()
        else ...[
          const SectionHeader(title: 'Berat'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BodyWeightChart(entries: entries),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: InkButton(
                    label: 'Bandingkan',
                    icon: Icons.compare,
                    expand: true,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const BodyCompareScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkButton(
                    label: 'Timelapse',
                    icon: Icons.movie_outlined,
                    expand: true,
                    onPressed: () => showBodyTimelapseDialog(context),
                  ),
                ),
              ],
            ),
          ),
          SectionHeader(
            title: 'Riwayat',
            trailing: Text('${entries.length}', style: FN.label(size: 11)),
          ),
          for (final e in entries)
            BodyEntryTile(
              entry: e,
              onTap: () => openBodyCheckin(context, e.day),
            ),
        ],
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
    child: Text(
      'Belum ada check-in. Foto tersimpan privat di HP, tidak masuk galeri, '
      'dan ikut saat backup.',
      style: TextStyle(fontFamily: FN.sans, fontSize: 14, color: FN.inkMuted),
    ),
  );
}
