import 'package:virya/features/segments/domain/live_segment_tracker.dart';
import 'package:virya/features/segments/domain/route_measure.dart';
import 'package:virya/features/segments/domain/segment_models.dart';

/// Segmen yang sedang ditampilkan saat merekam.
class LiveSegmentView {
  final String id;
  final String name;
  final LiveSegmentState state;

  /// Waktu fix GPS yang menghasilkan keadaan ini.
  final DateTime at;

  const LiveSegmentView({
    required this.id,
    required this.name,
    required this.state,
    required this.at,
  });
}

class _Entry {
  final LiveSegmentSeed seed;
  final LiveSegmentTracker tracker;
  final SegmentBounds bounds;

  _Entry(this.seed)
    : tracker = LiveSegmentTracker(
        polyline: seed.polyline,
        prProgressS: seed.ghostMarksS,
        prTimeS: seed.ghostTimeS,
      ),
      bounds = SegmentBounds.of(seed.polyline);
}

/// Memantau banyak segmen sekaligus dan memilih satu untuk ditampilkan.
///
/// Segmen yang jauh disaring dengan kotak pembatas, jadi biaya tiap fix tidak
/// bergantung pada jumlah segmen di daftar. Urutan tampil: yang baru berakhir,
/// yang sedang aktif, hasil yang masih ditahan, lalu yang terdekat.
class LiveSegmentBoard {
  /// Sedikit lebih besar dari radius "mendekati" milik tracker (300 m).
  static const double boundsMarginM = 350;
  static const int holdResultS = 10;

  final List<_Entry> _entries;
  String? _focusId;
  LiveSegmentView? _held;
  DateTime? _heldUntil;

  /// Jumlah tracker yang benar-benar dihitung pada fix terakhir.
  int lastEvaluated = 0;

  LiveSegmentBoard(List<LiveSegmentSeed> seeds)
    : _entries = [
        for (final s in seeds)
          if (s.polyline.length >= 2) _Entry(s),
      ];

  bool get isEmpty => _entries.isEmpty;

  LiveSegmentView? update(double lat, double lon, DateTime time) {
    final active = <LiveSegmentView>[];
    LiveSegmentView? near, ended;
    var nearD = double.infinity;
    lastEvaluated = 0;

    for (final e in _entries) {
      final phase = e.tracker.state.phase;
      if (phase != LiveSegmentPhase.active &&
          !e.bounds.contains(lat, lon, boundsMarginM)) {
        if (phase != LiveSegmentPhase.idle) e.tracker.reset();
        continue;
      }
      lastEvaluated++;
      final st = e.tracker.update(lat, lon, time);
      final view = LiveSegmentView(
        id: e.seed.id,
        name: e.seed.name,
        state: st,
        at: time,
      );
      switch (st.phase) {
        case LiveSegmentPhase.active:
          active.add(view);
        case LiveSegmentPhase.finished:
        case LiveSegmentPhase.abandoned:
          if (ended == null || e.seed.id == _focusId) ended = view;
        case LiveSegmentPhase.approaching:
          final d = st.distanceToStartM ?? double.infinity;
          if (d < nearD) {
            nearD = d;
            near = view;
          }
        case LiveSegmentPhase.idle:
          break;
      }
    }

    if (ended != null && (ended.id == _focusId || active.isEmpty)) {
      _focusId = null;
      _held = ended;
      _heldUntil = time.add(const Duration(seconds: holdResultS));
      return ended;
    }
    if (active.isNotEmpty) {
      final pick = active.firstWhere(
        (v) => v.id == _focusId,
        orElse: () => active.first,
      );
      _focusId = pick.id;
      _held = null;
      return pick;
    }
    _focusId = null;
    final held = _held;
    if (held != null && time.isBefore(_heldUntil!)) return held;
    _held = null;
    return near;
  }
}
