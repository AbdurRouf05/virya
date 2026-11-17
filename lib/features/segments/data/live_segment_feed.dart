import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/features/segments/data/segment_providers.dart';
import 'package:virya/features/segments/domain/live_segment_board.dart';
import 'package:virya/features/segments/domain/segment_cues.dart';

/// Pintu modul segmen untuk perekaman. Bukan bagian widget, supaya tetap
/// berjalan saat layar mati. Keadaannya dibaca HUD di layar rekam.
class LiveSegmentFeed extends Notifier<LiveSegmentView?> {
  LiveSegmentBoard? _board;
  SegmentCuePlanner _cues = SegmentCuePlanner();
  int _run = 0;

  @override
  LiveSegmentView? build() => null;

  /// Gagal memuat segmen tidak boleh menghalangi perekaman.
  Future<void> begin(SportType sport) async {
    end();
    final run = _run;
    try {
      final seeds = await ref.read(segmentRepositoryProvider).liveSeeds(sport);
      if (run != _run) return; // Sesi sudah ditutup selagi memuat.
      final board = LiveSegmentBoard(seeds);
      _board = board.isEmpty ? null : board;
    } catch (e) {
      debugPrint('Gagal memuat segmen: $e');
    }
  }

  /// Memproses satu fix; mengembalikan teks untuk dibacakan, bila ada.
  String? onFix(double lat, double lon, DateTime time) {
    final board = _board;
    if (board == null) return null;
    final view = board.update(lat, lon, time);
    state = view;
    return _cues.next(view);
  }

  void end() {
    _run++;
    _board = null;
    _cues = SegmentCuePlanner();
    state = null;
  }
}

final liveSegmentFeedProvider =
    NotifierProvider<LiveSegmentFeed, LiveSegmentView?>(LiveSegmentFeed.new);
