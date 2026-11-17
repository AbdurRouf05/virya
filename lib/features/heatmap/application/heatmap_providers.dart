import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/features/heatmap/data/heatmap_repository.dart';
import 'package:virya/features/heatmap/domain/heatmap_builder.dart';

/// Jalur dibaca sekali selama layar terbuka, jadi ganti filter cukup menghitung
/// ulang grid tanpa membaca database lagi.
final heatmapTracksProvider = FutureProvider.autoDispose<List<HeatmapTrack>>(
  (ref) => ref.watch(heatmapRepositoryProvider).loadTracks(),
);

/// Grid dihitung di isolate terpisah supaya UI tidak macet.
final heatmapProvider = FutureProvider.autoDispose
    .family<HeatmapResult, HeatmapFilter>((ref, filter) async {
      final tracks = await ref.watch(heatmapTracksProvider.future);
      return compute(buildHeatmap, HeatmapJob(tracks, filter));
    });
