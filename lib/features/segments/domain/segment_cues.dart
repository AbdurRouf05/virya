import 'package:virya/features/segments/domain/live_segment_board.dart';
import 'package:virya/features/segments/domain/live_segment_tracker.dart';

/// "2 menit 5 detik", untuk dibacakan.
String spokenDuration(int seconds) {
  final s = seconds.abs();
  final m = s ~/ 60, r = s % 60;
  if (m == 0) return '$r detik';
  return r == 0 ? '$m menit' : '$m menit $r detik';
}

/// Selisih terhadap ghost; negatif berarti di depan.
String ghostPhrase(double deltaS) {
  final s = deltaS.abs().round();
  if (s == 0) return 'Kamu sejajar dengan ghost.';
  final where = deltaS < 0 ? 'di depan' : 'di belakang';
  return 'Kamu ${spokenDuration(s)} $where ghost.';
}

/// "+0:05" di belakang, "-0:05" di depan, untuk HUD.
String ghostDeltaLabel(double deltaS) {
  final s = deltaS.abs().round();
  final clock = '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  if (s == 0) return clock;
  return '${deltaS < 0 ? '-' : '+'}$clock';
}

String finishPhrase(String name, LiveSegmentState s) {
  final time = spokenDuration(s.finalTimeS ?? s.elapsedS);
  final delta = s.ghostDeltaS;
  if (delta == null) {
    return 'Segmen $name selesai. Waktumu $time. Ini jadi ghost berikutnya.';
  }
  final gap = spokenDuration(delta.round());
  if (s.isNewPr == true) {
    return 'Rekor baru di $name! Waktumu $time, lebih cepat $gap.';
  }
  if (delta.round() == 0) {
    return 'Segmen $name selesai. Waktumu $time, sama dengan rekor.';
  }
  return 'Segmen $name selesai. Waktumu $time, $gap lebih lambat dari rekor.';
}

/// Menentukan kapan dan apa yang dibacakan, supaya suara tidak terus bicara.
class SegmentCuePlanner {
  static const int ghostEveryS = 30;
  static const Duration approachCooldown = Duration(minutes: 3);

  String? _id;
  LiveSegmentPhase? _phase;
  int _lastGhostS = 0;
  final Map<String, DateTime> _approachSaid = {};

  /// Teks untuk dibacakan pada keadaan [v], atau `null`.
  String? next(LiveSegmentView? v) {
    if (v == null) {
      _id = null;
      _phase = null;
      return null;
    }
    final s = v.state;
    final changed = v.id != _id || s.phase != _phase;
    _id = v.id;
    _phase = s.phase;
    switch (s.phase) {
      case LiveSegmentPhase.idle:
        return null;
      case LiveSegmentPhase.approaching:
        return changed ? _approach(v) : null;
      case LiveSegmentPhase.active:
        if (changed) {
          _lastGhostS = 0;
          return 'Segmen ${v.name} dimulai.';
        }
        final delta = s.ghostDeltaS;
        if (delta == null || s.elapsedS - _lastGhostS < ghostEveryS) {
          return null;
        }
        _lastGhostS = s.elapsedS;
        return ghostPhrase(delta);
      case LiveSegmentPhase.finished:
        return changed ? finishPhrase(v.name, s) : null;
      case LiveSegmentPhase.abandoned:
        return changed ? 'Kamu keluar dari segmen ${v.name}.' : null;
    }
  }

  String? _approach(LiveSegmentView v) {
    final last = _approachSaid[v.id];
    if (last != null && v.at.difference(last) < approachCooldown) return null;
    _approachSaid[v.id] = v.at;
    final d = v.state.distanceToStartM ?? 0;
    final rounded = ((d / 50).round() * 50).clamp(50, 300);
    return 'Segmen ${v.name}, $rounded meter lagi.';
  }
}
