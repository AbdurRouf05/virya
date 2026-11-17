import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/offline_maps/map_pack.dart' show formatBytes;
import 'package:virya/core/offline_maps/offline_region.dart';
import 'package:virya/core/offline_maps/online_tile_source.dart';
import 'package:virya/core/offline_maps/region_downloader.dart';
import 'package:virya/features/maps/data/offline_map_providers.dart';

class RegionDownloadState {
  final OfflineRegion region;
  final RegionDownloadProgress progress;
  final bool cancelling;
  const RegionDownloadState(this.region, this.progress, {this.cancelling = false});
}

/// Runs one region download at a time; survives leaving the screen.
class RegionDownloadController extends Notifier<RegionDownloadState?> {
  bool _cancel = false;

  @override
  RegionDownloadState? build() => null;

  bool get busy => state != null;

  /// Downloads (or resumes) [region]. Returns a short Indonesian summary.
  Future<String> start(OfflineRegion region) async {
    if (state != null) return 'Unduhan lain sedang berjalan';
    final tiles = ref.read(offlineTilesProvider);
    _cancel = false;
    state = RegionDownloadState(
        region, RegionDownloadProgress(0, region.tileCount, 0, 0));
    await tiles.regions.save(region.copyWith(complete: false));
    ref.invalidate(offlineMapStatusProvider);
    var last = state!.progress;
    String msg;
    try {
      last = await tiles.downloader().run(
        region,
        isCancelled: () => _cancel,
        onProgress: (p) {
          last = p;
          final s = state;
          if (s != null) {
            state = RegionDownloadState(s.region, p, cancelling: s.cancelling);
          }
        },
      );
      final ok = !_cancel && last.failed == 0 && last.done >= last.total;
      await tiles.regions
          .save(region.copyWith(sizeBytes: last.bytes, complete: ok));
      msg = _cancel
          ? 'Unduhan dibatalkan. Bagian yang sudah terunduh tetap tersimpan.'
          : ok
              ? 'Wilayah siap offline (${formatBytes(last.bytes)})'
              : 'Selesai, ${last.failed} ubin gagal. Coba "Lanjutkan" nanti.';
    } on TileFetchException {
      await tiles.regions.save(region.copyWith(sizeBytes: last.bytes));
      msg = 'Koneksi terputus. Coba "Lanjutkan" saat online.';
    } catch (e) {
      await tiles.regions.save(region.copyWith(sizeBytes: last.bytes));
      msg = 'Unduhan gagal: $e';
    } finally {
      state = null;
      ref.invalidate(offlineMapStatusProvider);
    }
    return msg;
  }

  void cancel() {
    final s = state;
    if (s == null) return;
    _cancel = true;
    state = RegionDownloadState(s.region, s.progress, cancelling: true);
  }

  Future<void> delete(OfflineRegion region) async {
    await ref.read(offlineTilesProvider).regions.delete(region.id);
    ref.invalidate(offlineMapStatusProvider);
  }

  Future<void> clearCache() async {
    await ref.read(offlineTilesProvider).cache.clear();
    ref.invalidate(offlineMapStatusProvider);
  }
}

final regionDownloadProvider =
    NotifierProvider<RegionDownloadController, RegionDownloadState?>(
        RegionDownloadController.new);
