import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/sensors/surface_classifier.dart';
import 'package:virya/core/sensors/vibration_rms.dart';

/// Feeds 1 s of synthetic 50 Hz vibration: sine of [amp] on z plus a gravity
/// leak offset of 0.3 m/s^2 that must be removed.
double rmsOf(double amp, {int hz = 50, double freq = 13}) {
  final w = VibrationRmsWindow();
  final t0 = DateTime(2026);
  double? out;
  for (var i = 0; i <= hz; i++) {
    final t = t0.add(Duration(microseconds: (i * 1e6 / hz).round()));
    final z = 0.3 + amp * math.sin(2 * math.pi * freq * i / hz);
    out = w.add(0.3, -0.2, z, t) ?? out;
  }
  return out!;
}

void main() {
  group('VibrationRmsWindow', () {
    test('removes DC offset and returns sine RMS (amp / sqrt2)', () {
      expect(rmsOf(2.0), closeTo(2.0 / math.sqrt2, 0.08));
      expect(rmsOf(0.0), closeTo(0, 1e-9));
    });

    test('emits once per window', () {
      final w = VibrationRmsWindow();
      final t0 = DateTime(2026);
      var emitted = 0;
      for (var i = 0; i < 50 * 5 + 1; i++) {
        if (w.add(1, 0, 0, t0.add(Duration(milliseconds: i * 20))) != null) {
          emitted++;
        }
      }
      expect(emitted, 5);
    });
  });

  group('SurfaceClassifier', () {
    final c = SurfaceClassifier();

    test('handlebar at reference speed: bands', () {
      expect(c.classifyInstant(0.8, 6), SurfaceType.asphalt);
      expect(c.classifyInstant(2.2, 6), SurfaceType.smoothGravel);
      expect(c.classifyInstant(3.4, 6), SurfaceType.dirt);
      expect(c.classifyInstant(5.0, 6), SurfaceType.roughGravel);
    });

    test('synthetic sine signals map to the right surface', () {
      expect(c.classifyInstant(rmsOf(1.2), 6), SurfaceType.asphalt); // 0.85
      expect(c.classifyInstant(rmsOf(3.2), 6), SurfaceType.smoothGravel); // 2.26
      expect(c.classifyInstant(rmsOf(7.5), 6), SurfaceType.roughGravel); // 5.3
    });

    test('same vibration at higher speed reads smoother', () {
      // 2.0 m/s^2 is gravel at 6 m/s but asphalt-ish buzz at 15 m/s.
      expect(c.classifyInstant(2.0, 6), SurfaceType.smoothGravel);
      expect(c.classifyInstant(2.0, 15), SurfaceType.asphalt);
      // And rougher when slow.
      expect(c.classifyInstant(2.2, 2.2), SurfaceType.dirt);
    });

    test('pocket mount is damped: lower RMS still detects gravel', () {
      final pocket = SurfaceClassifier(mount: PhoneMount.pocket);
      expect(c.classifyInstant(1.3, 6), SurfaceType.asphalt);
      expect(pocket.classifyInstant(1.3, 6), SurfaceType.smoothGravel);
    });

    test('calibration factor scales thresholds', () {
      final stiff = SurfaceClassifier(calibration: 2.0);
      expect(stiff.classifyInstant(2.2, 6), SurfaceType.asphalt);
      expect(SurfaceClassifier(calibration: 0).calibration, 1.0);
    });

    test('unknown when slow or disabled (non-cycling)', () {
      expect(c.classifyInstant(5, 0.5), SurfaceType.unknown);
      final off = SurfaceClassifier(enabled: false);
      expect(off.update(5, 6), SurfaceType.unknown);
    });

    test('majority smoothing ignores single spikes, keeps surface when stopped',
        () {
      final s = SurfaceClassifier();
      for (var i = 0; i < 5; i++) {
        s.update(0.8, 6);
      }
      expect(s.update(6.0, 6), SurfaceType.asphalt); // one pothole
      expect(s.current, SurfaceType.asphalt);
      for (var i = 0; i < 4; i++) {
        s.update(2.3, 6);
      }
      expect(s.current, SurfaceType.smoothGravel);
      expect(s.update(0.1, 0), SurfaceType.smoothGravel); // stopped
    });

    test('PhoneMount.parse', () {
      expect(PhoneMount.parse('pocket'), PhoneMount.pocket);
      expect(PhoneMount.parse(null), PhoneMount.handlebar);
      expect(PhoneMount.parse('weird'), PhoneMount.handlebar);
    });
  });
}
