import 'dart:math' as math;

/// Accumulates ~50 Hz linear-acceleration samples into one RMS value per
/// window (default 1 s). Per-axis mean is removed first so any residual
/// gravity/bias leak from the OS "user accelerometer" does not count.
class VibrationRmsWindow {
  final Duration window;

  final List<double> _x = [], _y = [], _z = [];
  DateTime? _windowStart;

  VibrationRmsWindow({this.window = const Duration(seconds: 1)});

  int get pendingSamples => _x.length;

  /// Adds a sample; returns the RMS when a window just completed.
  double? add(double x, double y, double z, DateTime t) {
    _windowStart ??= t;
    double? out;
    if (t.difference(_windowStart!) >= window) {
      out = _flush();
      _windowStart = t;
    }
    _x.add(x);
    _y.add(y);
    _z.add(z);
    return out;
  }

  double? _flush() {
    final n = _x.length;
    if (n < 2) {
      _x.clear();
      _y.clear();
      _z.clear();
      return null;
    }
    double mean(List<double> v) => v.reduce((a, b) => a + b) / v.length;
    final mx = mean(_x), my = mean(_y), mz = mean(_z);
    var sum = 0.0;
    for (var i = 0; i < n; i++) {
      final dx = _x[i] - mx, dy = _y[i] - my, dz = _z[i] - mz;
      sum += dx * dx + dy * dy + dz * dz;
    }
    _x.clear();
    _y.clear();
    _z.clear();
    return math.sqrt(sum / n);
  }

  void reset() {
    _x.clear();
    _y.clear();
    _z.clear();
    _windowStart = null;
  }
}
