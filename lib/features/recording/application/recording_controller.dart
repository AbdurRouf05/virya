import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show BooleanExpressionOperators, Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/data/activity_finalizer.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/location/geo_math.dart';
import 'package:stravo/core/location/location_fix.dart';
import 'package:stravo/core/location/location_source.dart';
import 'package:stravo/core/location/models/telemetry_snapshot.dart';
import 'package:stravo/core/location/telemetry_pipeline.dart';
import 'package:stravo/core/models/track_sample.dart';
import 'package:stravo/core/sensors/sensor_sources.dart';
import 'package:stravo/core/sensors/surface_classifier.dart';
import 'package:stravo/features/recording/application/recording_platform.dart';
import 'package:stravo/features/recording/data/incremental_flush_engine.dart';
import 'package:stravo/features/recording/domain/recording_settings.dart';
import 'package:stravo/features/recording/domain/recording_state.dart';
import 'package:stravo/services/audio_cues/audio_cue_service.dart';
import 'package:uuid/uuid.dart';

/// Live recording session: idle → recording ⇄ paused → saving → idle.
///
/// Kept alive (not autoDispose) so a recording survives leaving the screen.
class RecordingController extends Notifier<RecordingState> {
  static const _routeStepM = 5.0;
  static const _gpsTimeout = Duration(seconds: 5);

  RecordingSettings _settings = const RecordingSettings();
  LocationSource? _location;
  VibrationSource? _vibration;
  PressureSource? _pressure;
  StreamSubscription<LocationFix>? _fixSub;
  StreamSubscription<double>? _vibSub;
  StreamSubscription<double>? _pressSub;
  Timer? _watchdog;

  TelemetryPipeline? _pipeline;
  SurfaceClassifier? _surface;
  IncrementalFlushEngine? _flush;
  int _seq = 0;
  DateTime? _lastFixWall;
  DateTime? _lastSampleTime;
  double? _lastAltitude;
  double _lastDistance = 0;
  final Map<SurfaceType, double> _surfaceDist = {};
  List<(double, double)> _route = [];

  AppDatabase get _db => ref.read(databaseProvider);
  RecordingPlatform get _platform => ref.read(recordingPlatformProvider);
  AudioCueService get _cues => ref.read(audioCueServiceProvider);

  @override
  RecordingState build() {
    ref.onDispose(_teardownSources);
    return RecordingState.initial();
  }

  RecordingSettings get settings => _settings;

  /// Loads settings (default sport, units, simulated GPS) while idle.
  Future<void> loadSettings() async {
    _settings = await RecordingSettings.load(_db);
    if (state.phase != RecordingPhase.idle) {
      state = state.copyWith(imperial: _settings.imperial);
      return;
    }
    state = RecordingState.initial(
      sport: _settings.defaultSport,
      simulated: _settings.simulated,
      imperial: _settings.imperial,
    );
  }

  void selectSport(SportType sport) {
    if (state.phase != RecordingPhase.idle) return;
    state = state.copyWith(sport: sport);
    unawaited(_db.setSetting(RecordingSettings.keyDefaultSport, sport.name));
  }

  /// Dev toggle: switch between real and simulated GPS (idle only).
  Future<void> setSimulated(bool on) async {
    if (state.phase != RecordingPhase.idle) return;
    await _db.setSetting(RecordingSettings.keyUseSimulatedGps, on.toString());
    await _teardownSources();
    await loadSettings();
  }

  /// Starts GNSS before recording so the user sees fix quality.
  /// Simulated sources start only with the recording.
  Future<void> warmUp() async {
    if (state.phase != RecordingPhase.idle || _settings.simulated) return;
    if (_location != null) return;
    _startLocation();
  }

  /// Stops idle warm-up (screen closed without recording).
  Future<void> coolDown() async {
    if (state.phase == RecordingPhase.idle) await _teardownSources();
  }

  void _startLocation() {
    final src = _platform.createLocationSource(
      simulated: _settings.simulated,
      speedUp: _settings.simSpeedUp,
      notificationLabel: state.sport.displayName,
    );
    _location = src;
    if (!src.isSimulated) {
      state = state.copyWith(gps: GpsStatus.searching);
    }
    _fixSub = src.start().listen(_onFix, onError: (Object e) {
      debugPrint('Location error: $e');
      state = state.copyWith(
          gps: GpsStatus.off, message: 'GPS error: lokasi tidak tersedia');
    });
    _watchdog?.cancel();
    _watchdog = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  // ---------------------------------------------------------------- session

  Future<String?> start() async {
    if (state.phase != RecordingPhase.idle) return state.activityId;
    final id = const Uuid().v4();
    final now = DateTime.now();
    await _db.activitiesDao.insertActivity(ActivitiesCompanion.insert(
      id: id,
      title: _defaultTitle(state.sport, now),
      sportType: state.sport.name,
      status: 'inProgress',
      startTime: now,
      gearId: Value(await _defaultGearId(state.sport)),
      updatedAt: now,
    ));
    await _beginSession(
      activityId: id,
      startTime: now,
      sport: state.sport,
      history: const [],
    );
    _cues.onStart();
    return id;
  }

  /// Continue an interrupted (crash) session with its stored points.
  Future<void> resumeRecovered(Activity activity) async {
    if (state.isActive) return;
    _settings = await RecordingSettings.load(_db);
    final sport = SportType.values.firstWhere(
      (s) => s.name == activity.sportType,
      orElse: () => SportType.gravelCycling,
    );
    final points =
        await _db.trackPointsDao.getPointsForActivity(activity.id);
    final photos =
        await _db.waypointPhotosDao.getPhotosForActivity(activity.id);
    state = state.copyWith(
      sport: sport,
      simulated: _settings.simulated,
      imperial: _settings.imperial,
      photoCount: photos.length,
    );
    await _beginSession(
      activityId: activity.id,
      startTime: activity.startTime,
      sport: sport,
      history: points.map(TrackSample.fromTrackPoint).toList(),
      nextSeq: points.isEmpty ? 0 : points.last.sequenceIdx + 1,
    );
  }

  Future<void> _beginSession({
    required String activityId,
    required DateTime startTime,
    required SportType sport,
    required List<TrackSample> history,
    int nextSeq = 0,
  }) async {
    final pipeline = TelemetryPipeline(
      sport: sport,
      autoPauseEnabled: _settings.autoPause,
      startTime: startTime,
    );
    _surfaceDist.clear();
    _route = [];
    if (history.isNotEmpty) {
      pipeline.replay(history);
      for (final s in history) {
        _appendRoute(s.lat, s.lon);
      }
      _lastAltitude = pipeline.altitude;
      _lastSampleTime = history.last.time;
    }
    _pipeline = pipeline;
    _lastDistance = pipeline.distanceM;
    _seq = nextSeq;
    _surface = SurfaceClassifier(
      mount: _settings.mount,
      calibration: _settings.vibrationCalibration,
      enabled: sport.isCycling,
    );
    _flush = IncrementalFlushEngine(
      trackPointsDao: _db.trackPointsDao,
      activitiesDao: _db.activitiesDao,
      activityId: activityId,
    );

    await _cues.configure(
      enabled: _settings.ttsEnabled,
      imperial: _settings.imperial,
      splitUnits: _settings.ttsSplit,
      sport: sport,
    );
    final snap = pipeline.snapshotAt(_lastSampleTime ?? startTime);
    if (history.isNotEmpty) _cues.seed(snap);

    state = state.copyWith(
      phase: RecordingPhase.recording,
      activityId: activityId,
      sport: sport,
      snapshot: snap,
      route: List.unmodifiable(_route),
      clearMessage: true,
    );

    if (_location == null) _startLocation();
    _vibration = _platform.createVibrationSource(_location!);
    _vibSub = _vibration!.start().listen(_onVibration);
    _pressure = _platform.createPressureSource(simulated: _settings.simulated);
    _pressSub = _pressure!.start().listen(_pipeline!.setPressure);
    if (_settings.keepScreenOn) await _platform.setKeepAwake(true);
  }

  void pause() {
    if (state.phase != RecordingPhase.recording) return;
    _pipeline?.setManualPause(true);
    state = state.copyWith(
      phase: RecordingPhase.paused,
      snapshot: _pipeline?.snapshotAt(_now()),
    );
    _flush?.flush().catchError((Object _) {});
    _cues.onManualPause(true);
  }

  void resume() {
    if (state.phase != RecordingPhase.paused) return;
    _pipeline?.setManualPause(false);
    state = state.copyWith(
      phase: RecordingPhase.recording,
      snapshot: _pipeline?.snapshotAt(_now()),
    );
    _cues.onManualPause(false);
  }

  /// Flushes, finalizes and returns the saved activity id. Returns null when
  /// nothing was recorded (the empty activity is deleted).
  Future<String?> stop() async {
    if (!state.isActive) return null;
    final id = state.activityId!;
    state = state.copyWith(phase: RecordingPhase.saving);
    await _teardownSources();
    final flush = _flush;
    _flush = null;
    try {
      await flush?.dispose();
    } catch (e) {
      debugPrint('Final flush failed: $e');
    }
    await _platform.setKeepAwake(false);
    await _cues.stop();

    final count = await _db.trackPointsDao.countPointsForActivity(id);
    if (count == 0) {
      await _deleteActivity(id);
      _reset(message: 'Tidak ada data GPS — aktivitas tidak disimpan.');
      return null;
    }
    final db = _db;
    if (_lastSampleTime != null) {
      await (db.update(db.activities)..where((t) => t.id.equals(id)))
          .write(ActivitiesCompanion(endTime: Value(_lastSampleTime)));
    }
    try {
      await ActivityFinalizer(db).finalize(id);
    } catch (e) {
      // Points are safe on disk; mark completed so it is not "recovered".
      debugPrint('Finalize failed: $e');
      await (db.update(db.activities)..where((t) => t.id.equals(id)))
          .write(const ActivitiesCompanion(status: Value('completed')));
    }
    _reset();
    return id;
  }

  /// Deletes the current session and all its points/photos.
  Future<void> discard() async {
    if (!state.isActive) return;
    final id = state.activityId!;
    state = state.copyWith(phase: RecordingPhase.saving);
    await _teardownSources();
    final flush = _flush;
    _flush = null;
    try {
      await flush?.dispose();
    } catch (_) {}
    await _platform.setKeepAwake(false);
    await _cues.stop();
    await _deleteActivity(id);
    _reset(message: 'Aktivitas dibuang.');
  }

  /// Copies a captured image into app storage and geotags it.
  Future<bool> addPhoto(String sourcePath) async {
    final id = state.activityId;
    final pipe = _pipeline;
    if (!state.isActive || id == null || pipe == null || !pipe.hasFix) {
      state = state.copyWith(message: 'Belum ada posisi GPS untuk foto.');
      return false;
    }
    final dir = await _platform.photosDirectory();
    final photoId = const Uuid().v4();
    final ext = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final dest = p.join(dir.path, '$photoId$ext');
    await File(sourcePath).copy(dest);
    await _db.waypointPhotosDao.insertPhoto(WaypointPhotosCompanion.insert(
      id: photoId,
      activityId: id,
      filePath: dest,
      latitude: pipe.latitude!,
      longitude: pipe.longitude!,
      altitudeMeters: pipe.altitude ?? 0,
      distanceFromStartMeters: pipe.distanceM,
      takenAt: DateTime.now(),
    ));
    final first = state.photoCount == 0;
    if (first) {
      final db = _db;
      await (db.update(db.activities)..where((t) => t.id.equals(id)))
          .write(ActivitiesCompanion(primaryPhotoPath: Value(dest)));
    }
    state = state.copyWith(photoCount: state.photoCount + 1);
    return true;
  }

  void clearMessage() => state = state.copyWith(clearMessage: true);

  // ---------------------------------------------------------------- streams

  void _onFix(LocationFix fix) {
    _lastFixWall = DateTime.now();
    final pipe = _pipeline;
    final active = state.isActive && pipe != null;
    if (!active) {
      if (state.phase == RecordingPhase.idle) {
        state = state.copyWith(
          gps: _location?.isSimulated == true
              ? GpsStatus.simulated
              : gpsStatusForAccuracy(fix.accuracy),
        );
      }
      return;
    }

    final r = pipe.process(fix);
    final snap = r.snapshot;
    final sample = r.sample;
    if (sample != null) {
      _lastSampleTime = sample.time;
      if (sample.ele != null) _lastAltitude = sample.ele;
      final step = pipe.distanceM - _lastDistance;
      _lastDistance = pipe.distanceM;
      if (step > 0) {
        _surfaceDist[sample.surface] = (_surfaceDist[sample.surface] ?? 0) + step;
      }
      if (!pipe.isManuallyPaused) {
        _persist(sample, r.bearingDeg, r.gradePct, snap);
        _appendRoute(sample.lat, sample.lon);
      }
    }
    if (r.autoPauseChanged) _cues.onAutoPause(pipe.isAutoPaused);
    _cues.onSnapshot(snap);

    state = state.copyWith(
      snapshot: snap,
      route: sample != null ? List.unmodifiable(_route) : null,
      gps: _location?.isSimulated == true
          ? GpsStatus.simulated
          : gpsStatusForAccuracy(fix.accuracy),
    );
  }

  void _onVibration(double rms) {
    final pipe = _pipeline;
    final cls = _surface;
    if (pipe == null || cls == null) return;
    final speed = pipe.snapshotAt(pipe.lastFixTime).currentSpeedKmh / 3.6;
    pipe.setSurface(cls.update(rms, speed), rms);
  }

  void _tick() {
    final last = _lastFixWall;
    if (_location?.isSimulated == true) return;
    final stale =
        last == null || DateTime.now().difference(last) > _gpsTimeout;
    if (stale && state.gps != GpsStatus.searching) {
      state = state.copyWith(gps: GpsStatus.searching);
    }
    // Keep elapsed time ticking through GPS gaps.
    final pipe = _pipeline;
    if (stale && pipe != null && state.isActive) {
      state = state.copyWith(snapshot: pipe.snapshotAt(DateTime.now()));
    }
  }

  void _persist(
    TrackSample s,
    double bearing,
    double grade,
    LiveTelemetrySnapshot snap,
  ) {
    final flush = _flush;
    final id = state.activityId;
    if (flush == null || id == null) return;
    final unpaved = (_surfaceDist[SurfaceType.smoothGravel] ?? 0) +
        (_surfaceDist[SurfaceType.roughGravel] ?? 0) +
        (_surfaceDist[SurfaceType.dirt] ?? 0);
    final asphalt = _surfaceDist[SurfaceType.asphalt] ?? 0;
    final total = snap.totalDistanceMeters;
    flush
        .recordPoint(
          TrackPointsCompanion.insert(
            activityId: id,
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
  }

  // ---------------------------------------------------------------- helpers

  /// Simulated time runs faster than the wall clock: use the last fix time.
  DateTime _now() => _location?.isSimulated == true && _pipeline != null
      ? _pipeline!.lastFixTime
      : DateTime.now();

  Future<void> _teardownSources() async {
    _watchdog?.cancel();
    _watchdog = null;
    await _fixSub?.cancel();
    await _vibSub?.cancel();
    await _pressSub?.cancel();
    _fixSub = _vibSub = null;
    _pressSub = null;
    await _location?.stop();
    await _vibration?.stop();
    await _pressure?.stop();
    _location = null;
    _vibration = null;
    _pressure = null;
  }

  Future<void> _deleteActivity(String id) async {
    try {
      final photos = await _db.waypointPhotosDao.getPhotosForActivity(id);
      for (final ph in photos) {
        final f = File(ph.filePath);
        if (await f.exists()) await f.delete();
      }
    } catch (_) {}
    await _db.activitiesDao.deleteActivity(id);
  }

  void _reset({String? message}) {
    _pipeline = null;
    _surface = null;
    _seq = 0;
    _lastSampleTime = null;
    _lastAltitude = null;
    _lastDistance = 0;
    _route = [];
    _surfaceDist.clear();
    state = RecordingState.initial(
      sport: state.sport,
      simulated: _settings.simulated,
      imperial: _settings.imperial,
    ).copyWith(message: message);
  }

  Future<String?> _defaultGearId(SportType sport) async {
    try {
      final db = _db;
      final gears = await (db.select(db.gears)
            ..where((g) => g.isDefault.equals(true) & g.isRetired.equals(false)))
          .get();
      final wantShoes = !sport.isCycling;
      for (final g in gears) {
        if ((g.gearType == 'runningShoes') == wantShoes) return g.id;
      }
    } catch (_) {}
    return null;
  }

  static String _defaultTitle(SportType sport, DateTime t) {
    final part = t.hour < 11
        ? 'Pagi'
        : t.hour < 15
            ? 'Siang'
            : t.hour < 18
                ? 'Sore'
                : 'Malam';
    final name = switch (sport) {
      SportType.gravelCycling => 'Gravel',
      SportType.roadCycling => 'Gowes',
      SportType.mountainBiking => 'MTB',
      SportType.roadRunning => 'Lari',
      SportType.trailRunning => 'Trail Run',
      SportType.hiking => 'Hiking',
      SportType.walking => 'Jalan',
    };
    return '$name $part';
  }
}

final recordingControllerProvider =
    NotifierProvider<RecordingController, RecordingState>(
  RecordingController.new,
);
