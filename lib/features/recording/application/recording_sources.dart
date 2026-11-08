import 'dart:async';

import 'package:virya/core/location/location_fix.dart';
import 'package:virya/core/location/location_source.dart';
import 'package:virya/core/sensors/heart_rate_source.dart';
import 'package:virya/core/sensors/sensor_sources.dart';
import 'package:virya/features/recording/application/recording_platform.dart';
import 'package:virya/features/recording/application/recording_session.dart';

/// Owns the location / vibration / pressure sources, their subscriptions and
/// the 1 Hz GPS watchdog timer.
class RecordingSources {
  static const _gpsTimeout = Duration(seconds: 5);

  final RecordingPlatform Function() _platform;
  final HeartRateSource Function()? _heartRateFactory;
  RecordingSources(this._platform, {HeartRateSource Function()? heartRate})
    : _heartRateFactory = heartRate;

  LocationSource? _location;
  VibrationSource? _vibration;
  PressureSource? _pressure;
  HeartRateSource? _heartRate;
  StreamSubscription<LocationFix>? _fixSub;
  StreamSubscription<double>? _vibSub;
  StreamSubscription<double>? _pressSub;
  StreamSubscription<int?>? _heartRateSub;
  Timer? _watchdog;
  DateTime? _lastFixWall;

  /// True when no fix arrived within the GPS timeout (wall clock).
  bool get isStale {
    final last = _lastFixWall;
    return last == null || DateTime.now().difference(last) > _gpsTimeout;
  }

  bool get hasLocation => _location != null;
  bool get isSimulated => _location?.isSimulated == true;

  /// Creates the location source (not yet listening).
  LocationSource createLocation({
    required bool simulated,
    required double speedUp,
    required String notificationLabel,
  }) {
    final src = _platform().createLocationSource(
      simulated: simulated,
      speedUp: speedUp,
      notificationLabel: notificationLabel,
    );
    _location = src;
    return src;
  }

  /// Starts listening to the created location source and the watchdog.
  void listenLocation({
    required void Function(LocationFix) onFix,
    required void Function(Object) onError,
    required void Function() onTick,
  }) {
    _fixSub = _location!.start().listen((fix) {
      _lastFixWall = DateTime.now();
      onFix(fix);
    }, onError: onError);
    _watchdog?.cancel();
    _watchdog = Timer.periodic(const Duration(seconds: 1), (_) => onTick());
  }

  /// Starts vibration and pressure sensors feeding [session]
  /// (requires a location source).
  void startSensors(RecordingSession session, {required bool simulated}) {
    _vibration = _platform().createVibrationSource(_location!);
    _vibSub = _vibration!.start().listen(session.onVibration);
    _pressure = _platform().createPressureSource(simulated: simulated);
    _pressSub = _pressure!.start().listen(session.pipeline.setPressure);
    // Simulated routes carry their own pulse inside each fix.
    if (!simulated) {
      _heartRate = _heartRateFactory?.call();
      _heartRateSub = _heartRate?.start().listen(session.pipeline.setHeartRate);
    }
  }

  Future<void> teardown() async {
    _watchdog?.cancel();
    _watchdog = null;
    await _fixSub?.cancel();
    await _vibSub?.cancel();
    await _pressSub?.cancel();
    await _heartRateSub?.cancel();
    _fixSub = _vibSub = null;
    _pressSub = null;
    _heartRateSub = null;
    await _location?.stop();
    await _vibration?.stop();
    await _pressure?.stop();
    await _heartRate?.stop();
    _location = null;
    _vibration = null;
    _pressure = null;
    _heartRate = null;
  }
}
