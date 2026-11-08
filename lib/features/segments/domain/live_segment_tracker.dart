import 'package:virya/core/analytics/geo.dart';
import 'package:virya/features/segments/domain/segment_path.dart';

enum LiveSegmentPhase { idle, approaching, active, finished, abandoned }

class LiveSegmentState {
  final LiveSegmentPhase phase;

  /// Distance to the segment start (idle / approaching).
  final double? distanceToStartM;
  final double progressM;
  final double segmentLengthM;
  final int elapsedS;

  /// Seconds versus the PR ghost at the same progress: negative = ahead.
  final double? ghostDeltaS;

  /// Set when [phase] is finished.
  final int? finalTimeS;
  final bool? isNewPr;
  final List<int>? progressMarksS;

  const LiveSegmentState({
    required this.phase,
    this.distanceToStartM,
    this.progressM = 0,
    required this.segmentLengthM,
    this.elapsedS = 0,
    this.ghostDeltaS,
    this.finalTimeS,
    this.isNewPr,
    this.progressMarksS,
  });

  double get fraction =>
      segmentLengthM <= 0 ? 0 : (progressM / segmentLengthM).clamp(0.0, 1.0);
}

/// Streaming segment matcher for live recording. Feed every GPS fix to
/// [update]; it returns the current state:
/// idle → approaching (≤ [approachRadiusM]) → active (left the start
/// radius on the path) → finished (closest fix within [endpointRadiusM] of
/// the end after ≥ 90% progress) or abandoned (off course / too long).
class LiveSegmentTracker {
  final SegmentPath path;
  final List<int>? prProgressS;
  final int? prTimeS;
  final double approachRadiusM;
  final double endpointRadiusM;
  final double corridorM;
  final int maxOffFixes;

  LiveSegmentTracker({
    required List<(double lat, double lon)> polyline,
    this.prProgressS,
    int? prTimeS,
    this.approachRadiusM = 300,
    this.endpointRadiusM = 25,
    this.corridorM = 40,
    this.maxOffFixes = 5,
  })  : path = SegmentPath(polyline),
        prTimeS = prTimeS ??
            ((prProgressS == null || prProgressS.isEmpty)
                ? null
                : prProgressS.last);

  late LiveSegmentState _state = LiveSegmentState(
      phase: LiveSegmentPhase.idle, segmentLengthM: path.lengthM);
  LiveSegmentState get state => _state;

  // Arming at the start.
  bool _armed = false;
  double _armBestD = double.infinity;
  DateTime? _armTime;

  // Active effort.
  DateTime? _t0;
  MarkRecorder? _rec;
  int _leg = 0, _off = 0;
  double _prog = 0, _endBestD = double.infinity;
  DateTime? _endBestTime;
  double? _lastLat, _lastLon;
  double _traveled = 0;

  void reset() {
    _armed = false;
    _armBestD = double.infinity;
    _armTime = null;
    _t0 = null;
    _rec = null;
    _leg = 0;
    _off = 0;
    _prog = 0;
    _endBestD = double.infinity;
    _endBestTime = null;
    _traveled = 0;
    _lastLat = null;
    _lastLon = null;
    _state = LiveSegmentState(
        phase: LiveSegmentPhase.idle, segmentLengthM: path.lengthM);
  }

  LiveSegmentState update(double lat, double lon, DateTime time) {
    _state = _t0 == null ? _idle(lat, lon, time) : _active(lat, lon, time);
    return _state;
  }

  LiveSegmentState _idle(double lat, double lon, DateTime time) {
    final d = path.distanceToStart(lat, lon);
    if (d <= endpointRadiusM) {
      _armed = true;
      if (d < _armBestD) {
        _armBestD = d;
        _armTime = time;
      }
    }
    if (_armed && (d > _armBestD + 2 || d > endpointRadiusM)) {
      final pr = path.project(lat, lon);
      if (pr.deviationM <= corridorM && pr.progressM > 0) {
        _t0 = _armTime;
        _rec = MarkRecorder(path);
        _armed = false;
        _armBestD = double.infinity;
        _lastLat = lat;
        _lastLon = lon;
        return _active(lat, lon, time);
      }
      if (d > endpointRadiusM) {
        _armed = false;
        _armBestD = double.infinity;
      }
    }
    return LiveSegmentState(
      phase: d <= approachRadiusM
          ? LiveSegmentPhase.approaching
          : LiveSegmentPhase.idle,
      distanceToStartM: d,
      segmentLengthM: path.lengthM,
    );
  }

  LiveSegmentState _active(double lat, double lon, DateTime time) {
    final len = path.lengthM;
    final tS = time.difference(_t0!).inMilliseconds / 1000;
    if (_lastLat != null) {
      _traveled += haversineM(_lastLat!, _lastLon!, lat, lon);
    }
    _lastLat = lat;
    _lastLon = lon;
    final pr = path.project(lat, lon, fromLeg: _leg);
    if (pr.deviationM > corridorM) {
      if (++_off > maxOffFixes) return _abandon(tS);
    } else {
      _off = 0;
      _leg = pr.legIndex;
      if (pr.progressM > _prog) {
        _prog = pr.progressM;
        _rec!.add(_prog, tS);
      }
    }
    final limit = prTimeS == null ? null : prTimeS! * 3 + 120;
    if ((limit != null && tS > limit) || _traveled > 1.5 * len + 200) {
      return _abandon(tS);
    }
    final dEnd = path.distanceToEnd(lat, lon);
    if (_prog >= 0.9 * len && dEnd <= endpointRadiusM) {
      if (dEnd < _endBestD) {
        _endBestD = dEnd;
        _endBestTime = time;
        if (_prog >= len - 0.5) return _finish();
      } else {
        return _finish();
      }
    } else if (_endBestTime != null) {
      return _finish();
    }
    double? delta;
    final pr0 = prProgressS;
    if (pr0 != null && pr0.length > 1) {
      delta = tS - timeAtProgress(pr0, _prog);
    }
    return LiveSegmentState(
      phase: LiveSegmentPhase.active,
      progressM: _prog,
      segmentLengthM: len,
      elapsedS: tS.round(),
      ghostDeltaS: delta,
    );
  }

  LiveSegmentState _finish() {
    final total = _endBestTime!.difference(_t0!).inMilliseconds / 1000;
    final marks = [
      for (final m in _rec!.finish(total)) m > total ? total.round() : m
    ];
    final time = total.round();
    final pr = prTimeS;
    final s = LiveSegmentState(
      phase: LiveSegmentPhase.finished,
      progressM: path.lengthM,
      segmentLengthM: path.lengthM,
      elapsedS: time,
      ghostDeltaS: pr == null ? null : (time - pr).toDouble(),
      finalTimeS: time,
      isNewPr: pr == null || time < pr,
      progressMarksS: List.unmodifiable(marks),
    );
    _clearEffort();
    return s;
  }

  LiveSegmentState _abandon(double tS) {
    final s = LiveSegmentState(
      phase: LiveSegmentPhase.abandoned,
      progressM: _prog,
      segmentLengthM: path.lengthM,
      elapsedS: tS.round(),
    );
    _clearEffort();
    return s;
  }

  void _clearEffort() {
    _t0 = null;
    _rec = null;
    _leg = 0;
    _off = 0;
    _prog = 0;
    _endBestD = double.infinity;
    _endBestTime = null;
    _traveled = 0;
    _lastLat = null;
    _lastLon = null;
  }
}
