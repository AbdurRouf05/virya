/// Speed-based auto-pause state machine.
///
/// Pauses after speed stays below [thresholdMps] for [pauseDelay]; resumes
/// after it stays at/above the threshold for [resumeDelay].
class AutoPauseDetector {
  final double thresholdMps;
  final Duration pauseDelay;
  final Duration resumeDelay;
  bool enabled;

  bool _paused = false;
  DateTime? _belowSince;
  DateTime? _aboveSince;

  AutoPauseDetector({
    required this.thresholdMps,
    this.pauseDelay = const Duration(seconds: 4),
    this.resumeDelay = const Duration(seconds: 2),
    this.enabled = true,
  });

  bool get isPaused => _paused;

  void reset() {
    _paused = false;
    _belowSince = _aboveSince = null;
  }

  /// Feed a speed sample. Returns true when the paused state changed.
  bool update(double speedMps, DateTime time) {
    if (!enabled) {
      final changed = _paused;
      reset();
      return changed;
    }
    if (speedMps < thresholdMps) {
      _aboveSince = null;
      _belowSince ??= time;
      if (!_paused && time.difference(_belowSince!) >= pauseDelay) {
        _paused = true;
        return true;
      }
    } else {
      _belowSince = null;
      _aboveSince ??= time;
      if (_paused && time.difference(_aboveSince!) >= resumeDelay) {
        _paused = false;
        return true;
      }
    }
    return false;
  }
}
