import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/offline_maps/map_pack_repository.dart';
import 'package:virya/core/offline_maps/offline_region.dart';
import 'package:virya/core/offline_maps/offline_tiles.dart';

final offlineTilesProvider = Provider<OfflineTiles>((_) => OfflineTiles.instance);

/// Snapshot for the "Peta offline" screen.
class OfflineMapStatus {
  final bool online;
  final int cacheBytes;
  final int regionBytes;
  final List<OfflineRegion> regions;
  const OfflineMapStatus({
    required this.online,
    required this.cacheBytes,
    required this.regionBytes,
    required this.regions,
  });
}

final offlineMapStatusProvider = FutureProvider<OfflineMapStatus>((ref) async {
  final t = ref.watch(offlineTilesProvider);
  final results = await Future.wait<Object>([
    MapPackRepository.isOnline(),
    t.cache.sizeBytes(),
    t.regions.totalBytes(),
    t.regions.list(),
  ]);
  return OfflineMapStatus(
    online: results[0] as bool,
    cacheBytes: results[1] as int,
    regionBytes: results[2] as int,
    regions: results[3] as List<OfflineRegion>,
  );
});
