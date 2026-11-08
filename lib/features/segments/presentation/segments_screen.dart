import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/segments/data/segment_providers.dart';
import 'package:virya/features/segments/presentation/segment_detail_screen.dart';
import 'package:virya/features/segments/presentation/widgets/segment_tile.dart';

/// Daftar segmen beserta rekornya.
class SegmentsScreen extends ConsumerWidget {
  const SegmentsScreen({super.key});

  Widget _message(String text) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      text,
      style: TextStyle(fontFamily: FN.sans, fontSize: 14, color: FN.inkMuted),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(segmentListProvider);
    final fmt = ref.watch(fmtProvider);
    final list = async.valueOrNull;
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: ListView(
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
              Masthead(
                kicker: 'Rute pilihan · Rekor · Ghost',
                title: 'Segmen',
                subtitle: list == null ? null : '${list.length} segmen',
              ),
              const SizedBox(height: 12),
              if (async.hasError) _message('Gagal memuat segmen.'),
              if (list != null && list.isEmpty)
                _message(
                  'Belum ada segmen. Buka aktivitas, lalu pilih '
                  'BUAT SEGMEN DARI RUTE INI.',
                ),
              for (final s in list ?? const [])
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: SegmentTile(
                    segment: s,
                    fmt: fmt,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SegmentDetailScreen(segmentId: s.id),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
