import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:stravo/core/location/sources/simulated_location_source.dart';
import 'package:stravo/core/sensors/vibration_rms.dart';

/// Per-second vibration RMS (m/s^2, gravity removed).
abstract class VibrationSource {
  Stream<double> start();
  Future<void> stop();
}

/// Barometric pressure in hPa (roughly 1 Hz or faster).
abstract class PressureSource {
  Stream<double> start();
  Future<void> stop();
}

/// Real accelerometer at ~50 Hz via sensors_plus.
class AccelerometerVibrationSource implements VibrationSource {
  StreamSubscription<UserAccelerometerEvent>? _sub;
  StreamController<double>? _out;
  final VibrationRmsWindow _window = VibrationRmsWindow();

  @override
  Stream<double> start() {
    _out?.close();
    final out = StreamController<double>();
    _out = out;
    _window.reset();
    _sub = userAccelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 20),
    ).listen(
      (e) {
        final rms = _window.add(e.x, e.y, e.z, e.timestamp);
        if (rms != null) out.add(rms);
      },
      // No accelerometer: surface simply stays unknown.
      onError: (_) {},
      cancelOnError: true,
    );
    return out.stream;
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _out?.close();
    _out = null;
  }
}

/// Real barometer via sensors_plus. Emits nothing on devices without one.
class BarometerPressureSource implements PressureSource {
  StreamSubscription<BarometerEvent>? _sub;
  StreamController<double>? _out;

  @override
  Stream<double> start() {
    _out?.close();
    final out = StreamController<double>();
    _out = out;
    try {
      _sub = barometerEventStream(
        samplingPeriod: SensorInterval.normalInterval,
      ).listen(
        (e) => out.add(e.pressure),
        onError: (_) {},
        cancelOnError: true,
      );
    } catch (_) {
      // Sensor missing: stay silent.
    }
    return out.stream;
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _out?.close();
    _out = null;
  }
}

/// Emits the recorded vibration of the sample a [SimulatedLocationSource]
/// is currently replaying.
class SimulatedVibrationSource implements VibrationSource {
  final SimulatedLocationSource replay;
  Timer? _timer;
  StreamController<double>? _out;

  SimulatedVibrationSource(this.replay);

  @override
  Stream<double> start() {
    _out?.close();
    final out = StreamController<double>();
    _out = out;
    final periodMs = (1000 / replay.speedUp).clamp(1, 60000).round();
    _timer = Timer.periodic(Duration(milliseconds: periodMs), (_) {
      final s = replay.current;
      if (s != null) out.add(s.vibration);
    });
    return out.stream;
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await _out?.close();
    _out = null;
  }
}

/// No-op pressure source (simulation / tests).
class NoPressureSource implements PressureSource {
  @override
  Stream<double> start() => const Stream.empty();
  @override
  Future<void> stop() async {}
}
