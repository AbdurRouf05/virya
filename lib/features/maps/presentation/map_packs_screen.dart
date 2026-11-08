import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/offline_maps/map_pack.dart' show formatBytes;
import 'package:virya/core/offline_maps/offline_region.dart';
import 'package:virya/features/maps/application/region_download_controller.dart';
import 'package:virya/features/maps/data/offline_map_providers.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_advanced.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_box.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_confirm.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_section_title.dart';
import 'package:virya/features/maps/presentation/widgets/offline_map_status_card.dart';
import 'package:virya/features/maps/presentation/widgets/offline_region_tile.dart';
import 'package:virya/features/maps/presentation/widgets/region_download_progress.dart';
import 'package:virya/features/maps/presentation/widgets/region_download_sheet.dart';

/// "Peta offline": online by default, cache status, downloaded regions,
/// and the advanced PMTiles section.
class MapPacksScreen extends ConsumerWidget {
  const MapPacksScreen({super.key});

  Future<void> _download(BuildContext context, WidgetRef ref, [OfflineRegion? resume]) async {
    final region = resume ?? await RegionDownloadSheet.show(context);
    if (region == null) return;
    final msg = await ref.read(regionDownloadProvider.notifier).start(region);
    if (context.mounted) mapToast(context, msg);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, OfflineRegion r) async {
    final ok = await confirmMapDelete(context,
        title: 'HAPUS WILAYAH?',
        body: '${r.name}\n${formatBytes(r.sizeBytes)} akan dihapus.');
    if (ok) await ref.read(regionDownloadProvider.notifier).delete(r);
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref, int bytes) async {
    final ok = await confirmMapDelete(context,
        title: 'HAPUS CACHE?',
        body: '${formatBytes(bytes)} peta yang pernah dilihat akan dihapus. '
            'Wilayah yang diunduh tidak ikut terhapus.');
    if (ok) await ref.read(regionDownloadProvider.notifier).clearCache();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(offlineMapStatusProvider);
    final running = ref.watch(regionDownloadProvider);
    return Scaffold(
      backgroundColor: FN.paper,
      appBar: AppBar(
        backgroundColor: FN.paper,
        foregroundColor: FN.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('PETA OFFLINE', style: FN.bigNumber(26)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: ColoredBox(
              color: FN.ink, child: const SizedBox(height: 2, width: double.infinity)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          status.when(
            loading: () => Center(child: CircularProgressIndicator(color: FN.ink)),
            error: (e, _) => Text('Gagal memuat status peta: $e',
                style: FN.label(color: FN.warn)),
            data: (s) => OfflineMapStatusCard(
              status: s,
              onClearCache: () => _clearCache(context, ref, s.cacheBytes),
            ),
          ),
          const SizedBox(height: 16),
          if (running != null)
            RegionDownloadProgressCard(
              state: running,
              onCancel: () => ref.read(regionDownloadProvider.notifier).cancel(),
            )
          else
            _downloadButton(context, ref),
          const SizedBox(height: 24),
          ..._regions(context, ref, status.valueOrNull, running),
          const SizedBox(height: 16),
          const MapPacksAdvanced(),
        ],
      ),
    );
  }

  Widget _downloadButton(BuildContext context, WidgetRef ref) => SizedBox(
        height: 52,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: FN.ink,
            foregroundColor: FN.paper,
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: () => _download(context, ref),
          icon: const Icon(Icons.download_for_offline_outlined),
          label: Text('UNDUH WILAYAH', style: FN.label(size: 13, color: FN.paper)),
        ),
      );

  List<Widget> _regions(BuildContext context, WidgetRef ref, OfflineMapStatus? s,
      RegionDownloadState? running) {
    final regions = s?.regions ?? const <OfflineRegion>[];
    return [
      MapPacksSectionTitle('WILAYAH TERUNDUH',
          trailing: s == null ? null : formatBytes(s.regionBytes)),
      if (regions.isEmpty)
        MapPacksBox(
          child: Text(
            'Belum ada. Unduh wilayah sebelum ke tempat tanpa sinyal agar '
            'peta tetap tampil.',
            style: TextStyle(fontFamily: FN.sans, color: FN.inkSoft, height: 1.4),
          ),
        ),
      for (final r in regions)
        OfflineRegionTile(
          region: r,
          onResume: running != null ? null : () => _download(context, ref, r),
          onDelete: running?.region.id == r.id ? null : () => _delete(context, ref, r),
        ),
    ];
  }
}
