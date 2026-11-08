import 'dart:typed_data';

/// Fill null elevations by linear interpolation on index; edges take the
/// nearest known value. Returns null when no elevation is known at all.
Float64List? fillElevation(List<double?> raw) {
  final n = raw.length;
  final out = Float64List(n);
  var prev = -1;
  for (var i = 0; i < n; i++) {
    final v = raw[i];
    if (v == null || v.isNaN) continue;
    out[i] = v;
    if (prev == -1) {
      for (var k = 0; k < i; k++) {
        out[k] = v;
      }
    } else if (i - prev > 1) {
      final a = out[prev];
      for (var k = prev + 1; k < i; k++) {
        out[k] = a + (v - a) * (k - prev) / (i - prev);
      }
    }
    prev = i;
  }
  if (prev == -1) return null;
  for (var k = prev + 1; k < n; k++) {
    out[k] = out[prev];
  }
  return out;
}

/// Sliding median with odd [window].
Float64List medianFilter(Float64List v, int window) {
  final n = v.length;
  final half = window ~/ 2;
  final out = Float64List(n);
  final buf = <double>[];
  for (var i = 0; i < n; i++) {
    final a = i - half < 0 ? 0 : i - half;
    final b = i + half >= n ? n - 1 : i + half;
    buf.clear();
    for (var k = a; k <= b; k++) {
      buf.add(v[k]);
    }
    buf.sort();
    out[i] = buf[buf.length >> 1];
  }
  return out;
}

/// Centered moving average with odd [window] (prefix sums, O(n)).
Float64List movingAverage(Float64List v, int window) {
  final n = v.length;
  final out = Float64List(n);
  if (n == 0) return out;
  final pre = Float64List(n + 1);
  for (var i = 0; i < n; i++) {
    pre[i + 1] = pre[i] + v[i];
  }
  final half = window ~/ 2;
  for (var i = 0; i < n; i++) {
    final a = i - half < 0 ? 0 : i - half;
    final b = i + half >= n ? n - 1 : i + half;
    out[i] = (pre[b + 1] - pre[a]) / (b - a + 1);
  }
  return out;
}

/// Median(5) then moving average(7) — removes spikes, then jitter.
Float64List smoothElevation(Float64List filled) =>
    movingAverage(medianFilter(filled, 5), 7);

/// Gain/loss with hysteresis: a direction change only counts once the
/// profile has moved [threshold] meters away from the last extreme.
({double gain, double loss}) gainLoss(List<double> ele,
    {double threshold = 3.0}) {
  if (ele.isEmpty) return (gain: 0, loss: 0);
  var gain = 0.0, loss = 0.0;
  var anchor = ele[0], extreme = ele[0];
  var dir = 0;
  for (var i = 1; i < ele.length; i++) {
    final e = ele[i];
    if (dir == 0) {
      if (e - anchor >= threshold) {
        dir = 1;
        extreme = e;
      } else if (anchor - e >= threshold) {
        dir = -1;
        extreme = e;
      }
    } else if (dir == 1) {
      if (e > extreme) {
        extreme = e;
      } else if (extreme - e >= threshold) {
        gain += extreme - anchor;
        anchor = extreme;
        dir = -1;
        extreme = e;
      }
    } else {
      if (e < extreme) {
        extreme = e;
      } else if (e - extreme >= threshold) {
        loss += anchor - extreme;
        anchor = extreme;
        dir = 1;
        extreme = e;
      }
    }
  }
  if (dir == 1) gain += extreme - anchor;
  if (dir == -1) loss += anchor - extreme;
  return (gain: gain, loss: loss);
}
