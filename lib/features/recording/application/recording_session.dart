import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/location/geo_math.dart';
import 'package:virya/core/location/location_fix.dart';
import 'package:virya/core/location/models/telemetry_snapshot.dart';
import 'package:virya/core/location/telemetry_pipeline.dart';
import 'package:virya/core/models/track_sample.dart';
import 'package:virya/core/sensors/surface_classifier.dart';
import 'package:virya/features/recording/data/incremental_flush_engine.dart';
import 'package:virya/features/recording/domain/recording_settings.dart';

/// Per-recording working state: telemetry pipeline, surface classifier,
/// incremental DB flush and the thinned live route.
class RecordingSession {
  static const _routeStepM = 5.0;

  final String activityId;
  final TelemetryPipeline pipeline;
  final SurfaceClassifier _surface;
  IncrementalFlushEngine? _flush;
  int _seq;
  DateTime? _lastSampleTime;
  double? _lastAltitude;
  double _lastDistance = 0;
  final Map<SurfaceType, double> _surfaceDist = {};
  final List<(double, double)> _route = [];
  List<(double, double)>? _cachedRoute;

  RecordingSession({
    required AppDatabase db,
    required this.activityId,
    required DateTime startTime,
    required SportType sport,
    required RecordingSettings settings,
    required List<TrackSample> history,
    int nextSeq = 0,
  })  : pipeline = TelemetryPipeline(
          sport: sport,
          autoPauseEnabled: settings.autoPause,
          startTime: startTime,
        ),
        _surface = SurfaceClassifier(
          mount: settings.mount,
          calibration: settings.vibrationCalibration,
          enabled: sport.isCycling,
        ),
        _seq = nextSeq {
    if (history.isNotEmpty) {
      pipeline.replay(history);
      for (final s in history) {
        _appendRoute(s.lat, s.lon);
      }
      _lastAltitude = pipeline.altitude;
      _lastSampleTime = history.last.time;
    }
    _lastDistance = pipeline.distanceM;
    _flush = IncrementalFlushEngine(
      trackPointsDao: db.trackPointsDao,
      activitiesDao: db.activitiesDao,
      activityId: activityId,
    );
  }

  /// Time of the last accepted sample (null when nothing recorded yet).
  DateTime? get lastSampleTime => _lastSampleTime;

  /// Immutable copy of the thinned route, cached until points are added.
  List<(double, double)> get route => _cachedRoute ??= List.unmodifiable(_route);

  /// Snapshot "now". Simulated time runs faster than the wall clock, so
  /// simulated sessions use the last fix time.
  LiveTelemetrySnapshot snapshotNow({required bool simulated}) =>
      pipeline.snapshotAt(simulated ? pipeline.lastFixTime : DateTime.now());

  /// Feeds a GPS fix: updates surface distances, persists and extends the
  /// route unless manually paused.
  PipelineResult process(LocationFix fix) {
    final r = pipeline.process(fix);
    final sample = r.sample;
    if (sample != null) {
      _lastSampleTime = sample.time;
      if (sample.ele != null) _lastAltitude = sample.ele;
      final step = pipeline.distanceM - _lastDistance;
      _lastDistance = pipeline.distanceM;
      if (step > 0) {
        _surfaceDist[sample.surface] =
            (_surfaceDist[sample.surface] ?? 0) + step;
      }
      if (!pipeline.isManuallyPaused) {
        _persist(sample, r.bearingDeg, r.gradePct, r.snapshot);
        _appendRoute(sample.lat, sample.lon);
      }
    }
    return r;
  }

  void onVibration(double rms) {
    final speed = pipeline.snapshotAt(pipeline.lastFixTime).currentSpeedKmh / 3.6;
    pipeline.setSurface(_surface.update(rms, speed), rms);
  }

  /// Writes buffered points now (errors ignored).
  void flushNow() => _flush?.flush().catchError((Object _) {});

  /// Detaches the flush engine and writes the remaining buffer.
  Future<void> closeFlush() async {
    final flush = _flush;
    _flush = null;
    await flush?.dispose();
  }

  void _persist(
    TrackSample s,
    double bearing,
    double grade,
    LiveTelemetrySnapshot snap,
  ) {
    final flush = _flush;
    if (flush == null) return;
    final unpaved = (_surfaceDist[SurfaceType.smoothGravel] ?? 0) +
        (_surfaceDist[SurfaceType.roughGravel] ?? 0) +
        (_surfaceDist[SurfaceType.dirt] ?? 0);
    final asphalt = _surfaceDist[SurfaceType.asphalt] ?? 0;
    final total = snap.totalDistanceMeters;
    flush
        .recordPoint(
          TrackPointsCompanion.insert(
            activityId: activityId,
            sequenceIdx: _seq++,
            timestamp: s.time,
            latitude: s.lat,
            longitude: s.lon,
            altitudeMeters: s.ele ?? _lastAltitude ?? 0,
            accuracyMeters: s.accuracyM ?? 0,
            speedMps: s.speedMps ?? 0,
            bearingDegrees: Value(bearing),
            gradePct: Value(grade),
            surfaceType: Value(s.surface.name),
            vibrationRaw: Value(s.vibration),
            heartRate: Value(s.heartRate),
            cadence: Value(s.cadence),
            isPaused: Value(s.paused),
          ),
          totalDistanceMeters: total,
          movingTimeSeconds: snap.movingTimeSeconds,
          elapsedTimeSeconds: snap.elapsedTimeSeconds,
          elevationGainMeters: snap.totalElevationGainMeters,
          avgSpeedMps: snap.averageSpeedKmh / 3.6,
          maxSpeedMps: snap.maxSpeedKmh / 3.6,
          gravelPercentage: total > 0 ? unpaved / total * 100 : 0,
          asphaltPercentage: total > 0 ? asphalt / total * 100 : 0,
        )
        .catchError((Object e) => debugPrint('Flush error: $e'));
  }

  void _appendRoute(double lat, double lon) {
    if (_route.isNotEmpty) {
      final (plat, plon) = _route.last;
      if (GeoMath.haversine(plat, plon, lat, lon) < _routeStepM) return;
    }
    _route.add((lat, lon));
    _cachedRoute = null;
  }
}
