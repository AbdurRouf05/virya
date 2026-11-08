import 'dart:math' as math;

import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/location/filters/auto_pause.dart';
import 'package:virya/core/location/filters/elevation_filter.dart';
import 'package:virya/core/location/filters/fix_gate.dart';
import 'package:virya/core/location/filters/grade_calculator.dart';
import 'package:virya/core/location/filters/kalman_filter.dart';
import 'package:virya/core/location/geo_math.dart';
import 'package:virya/core/location/location_fix.dart';
import 'package:virya/core/location/models/telemetry_snapshot.dart';
import 'package:virya/core/location/tracking_profile.dart';
import 'package:virya/core/models/track_sample.dart';

/// Output of one [TelemetryPipeline.process] call.
class PipelineResult {
  final LiveTelemetrySnapshot snapshot;

  /// Filtered sample to persist; null when the fix was rejected.
  final TrackSample? sample;
  final FixRejectReason? rejected;

  /// Auto-pause state flipped on this fix.
  final bool autoPauseChanged;
  final double bearingDeg;
  final double gradePct;

  const PipelineResult({
    required this.snapshot,
    required this.sample,
    required this.rejected,
    required this.autoPauseChanged,
    required this.bearingDeg,
    required this.gradePct,
  });
}

/// Pure-Dart GNSS processing: gate → Kalman → distance → elevation → grade →
/// auto-pause → snapshot. No plugins; fully unit-testable.
class TelemetryPipeline {
  final SportType sport;
  final TrackingProfile profile;

  /// A single gap longer than this does not count as moving time.
  final double maxMovingGapS;

  late final FixGate _gate;
  late final LatLonKalmanFilter _kalman;
  late final AutoPauseDetector _autoPause;
  final ElevationFilter _elevation = ElevationFilter();
  final GradeCalculator _grade = GradeCalculator();

  DateTime? _startTime;
  DateTime? _lastTime;
  double? _lat, _lon;
  double _distanceM = 0;
  double _movingS = 0;
  double _maxSpeedMps = 0;
  double _speedMps = 0;
  double _bearing = 0;
  double _accuracy = 0;
  bool _manualPaused = false;
  double? _pressureHPa;
  SurfaceType _surface = SurfaceType.unknown;
  double _vibration = 0;
  int? _heartRate;
  int? _cadence;
  DateTime _lastFixTime = DateTime.fromMillisecondsSinceEpoch(0);

  TelemetryPipeline({
    required this.sport,
    TrackingProfile? profile,
    bool autoPauseEnabled = true,
    DateTime? startTime,
    this.maxMovingGapS = 15,
  }) : profile = profile ?? TrackingProfile.forSport(sport) {
    _startTime = startTime;
    _gate = FixGate(
      maxAccuracyM: this.profile.maxAccuracyM,
      maxPlausibleSpeedMps: this.profile.maxPlausibleSpeedMps,
    );
    _kalman = LatLonKalmanFilter(
      processNoiseMps: this.profile.kalmanProcessNoiseMps,
    );
    _autoPause = AutoPauseDetector(
      thresholdMps: this.profile.autoPauseSpeedMps,
      pauseDelay: this.profile.autoPauseDelay,
      resumeDelay: this.profile.autoResumeDelay,
      enabled: autoPauseEnabled,
    );
  }

  double get distanceM => _distanceM;
  int get movingTimeS => _movingS.round();
  bool get isAutoPaused => _autoPause.isPaused;
  bool get isManuallyPaused => _manualPaused;
  bool get hasFix => _lat != null;
  double? get latitude => _lat;
  double? get longitude => _lon;
  double? get altitude => _elevation.altitude;
  double get elevationGainM => _elevation.gain;
  double get elevationLossM => _elevation.loss;
  double get maxSpeedMps => _maxSpeedMps;
  double get avgSpeedMps => _movingS > 0 ? _distanceM / _movingS : 0;
  bool get usingBarometer => _elevation.usingBarometer;
  DateTime get lastFixTime => _lastFixTime;

  set autoPauseEnabled(bool v) => _autoPause.enabled = v;

  /// Manual pause from the UI. Resuming clears any auto-pause.
  void setManualPause(bool paused) {
    _manualPaused = paused;
    if (!paused) _autoPause.reset();
  }

  /// Latest barometer reading (hPa) or null when unavailable.
  void setPressure(double? hPa) => _pressureHPa = hPa;

  void setSurface(SurfaceType surface, double vibrationRms) {
    _surface = surface;
    _vibration = vibrationRms;
  }

  void setHeartRate(int? bpm) => _heartRate = bpm;
  void setCadence(int? rpm) => _cadence = rpm;

  PipelineResult process(LocationFix fix) {
    _startTime ??= fix.time;
    _accuracy = fix.accuracy;
    if (fix.heartRate != null) _heartRate = fix.heartRate;
    if (fix.cadence != null) _cadence = fix.cadence;

    final reject = _gate.check(fix);
    if (reject != null) {
      return _result(fix.time, null, reject, false);
    }
    _lastFixTime = fix.time;

    final (lat, lon) = _kalman.process(fix.lat, fix.lon, fix.accuracy, fix.time);
    final prevLat = _lat, prevLon = _lon, prevTime = _lastTime;
    _lat = lat;
    _lon = lon;
    _lastTime = fix.time;

    var step = 0.0;
    var dt = 0.0;
    if (prevLat != null && prevTime != null) {
      step = GeoMath.haversine(prevLat, prevLon!, lat, lon);
      dt = fix.time.difference(prevTime).inMilliseconds / 1000.0;
    }

    // Speed: device Doppler speed when available, else derived.
    final derived = dt > 0 ? step / dt : 0.0;
    final rawSpeed = fix.validSpeed ?? derived;
    _speedMps = _speedMps == 0 ? rawSpeed : 0.5 * _speedMps + 0.5 * rawSpeed;
    if (rawSpeed < 0.3) _speedMps = rawSpeed; // snap to stop quickly

    var autoChanged = false;
    if (!_manualPaused) {
      autoChanged = _autoPause.update(rawSpeed, fix.time);
    }
    final paused = _manualPaused || _autoPause.isPaused;

    if (!paused && dt > 0) {
      _distanceM += step;
      _movingS += math.min(dt, maxMovingGapS);
      if (rawSpeed <= profile.maxPlausibleSpeedMps) {
        _maxSpeedMps = math.max(_maxSpeedMps, rawSpeed);
      }
    }

    if (step > 1.5) {
      _bearing = GeoMath.bearing(prevLat!, prevLon!, lat, lon);
    } else if (fix.heading != null && rawSpeed > 1) {
      _bearing = fix.heading!;
    }

    final ele = _elevation.update(
      gnssAltitude: fix.altitude,
      pressureHPa: _pressureHPa,
      countTotals: !paused,
    );
    if (!paused && ele != null) _grade.add(_distanceM, ele);

    final sample = TrackSample(
      time: fix.time,
      lat: lat,
      lon: lon,
      ele: ele,
      speedMps: paused ? 0 : rawSpeed,
      accuracyM: fix.accuracy,
      heartRate: _heartRate,
      cadence: _cadence,
      surface: _surface,
      vibration: _vibration,
      paused: paused,
    );
    return _result(fix.time, sample, null, autoChanged);
  }

  /// Rebuilds totals from previously stored samples (crash-recovery resume).
  void replay(List<TrackSample> samples) {
    for (final s in samples) {
      setManualPause(s.paused);
      setSurface(s.surface, s.vibration);
      process(LocationFix(
        time: s.time,
        lat: s.lat,
        lon: s.lon,
        altitude: s.ele,
        accuracy: s.accuracyM ?? 5,
        speed: s.speedMps,
        heartRate: s.heartRate,
        cadence: s.cadence,
      ));
    }
    setManualPause(false);
  }

  LiveTelemetrySnapshot snapshotAt(DateTime time) => _snapshot(time);

  PipelineResult _result(
    DateTime time,
    TrackSample? sample,
    FixRejectReason? reject,
    bool autoChanged,
  ) =>
      PipelineResult(
        snapshot: _snapshot(time),
        sample: sample,
        rejected: reject,
        autoPauseChanged: autoChanged,
        bearingDeg: _bearing,
        gradePct: _grade.gradePct,
      );

  LiveTelemetrySnapshot _snapshot(DateTime time) {
    final paused = _manualPaused || _autoPause.isPaused;
    final elapsed =
        _startTime == null ? 0 : time.difference(_startTime!).inSeconds;
    return LiveTelemetrySnapshot(
      currentSpeedKmh: paused ? 0 : _speedMps * 3.6,
      averageSpeedKmh: avgSpeedMps * 3.6,
      totalDistanceMeters: _distanceM,
      movingTimeSeconds: _movingS.round(),
      elapsedTimeSeconds: math.max(0, elapsed),
      currentAltitudeMeters: _elevation.altitude ?? 0,
      totalElevationGainMeters: _elevation.gain,
      totalElevationLossMeters: _elevation.loss,
      currentGradePct: _grade.gradePct,
      currentSurface: _surface,
      latitude: _lat ?? 0,
      longitude: _lon ?? 0,
      accuracyMeters: _accuracy,
      bearingDegrees: _bearing,
      timestamp: time,
      isAutoPaused: _autoPause.isPaused,
      isManuallyPaused: _manualPaused,
      maxSpeedKmh: _maxSpeedMps * 3.6,
      heartRate: _heartRate,
      cadence: _cadence,
      vibrationRms: _vibration,
      hasFix: _lat != null,
    );
  }
}
