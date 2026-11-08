import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/location/location_fix.dart';
import 'package:virya/core/models/track_sample.dart';
import 'package:virya/core/sensors/heart_rate_source.dart';
import 'package:virya/features/recording/application/recording_platform.dart';
import 'package:virya/features/recording/application/recording_session.dart';
import 'package:virya/features/recording/application/recording_sources.dart';
import 'package:virya/features/recording/application/recording_store.dart';
import 'package:virya/features/recording/domain/recording_settings.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/segments/data/live_segment_feed.dart';
import 'package:virya/services/audio_cues/audio_cue_service.dart';

/// Live recording session: idle → recording ⇄ paused → saving → idle.
///
/// Kept alive (not autoDispose) so a recording survives leaving the screen.
class RecordingController extends Notifier<RecordingState> {
  RecordingSettings _settings = const RecordingSettings();
  late final RecordingSources _sources = RecordingSources(
    () => ref.read(recordingPlatformProvider),
    heartRate: () => ref.read(heartRateSourceProvider),
  );
  RecordingSession? _session;

  AppDatabase get _db => ref.read(databaseProvider);
  RecordingStore get _store => RecordingStore(_db);
  RecordingPlatform get _platform => ref.read(recordingPlatformProvider);
  AudioCueService get _cues => ref.read(audioCueServiceProvider);
  LiveSegmentFeed get _feed => ref.read(liveSegmentFeedProvider.notifier);

  @override
  RecordingState build() {
    ref.onDispose(_sources.teardown);
    return RecordingState.initial();
  }

  /// Loads settings (default sport, units, simulated GPS) while idle.
  Future<void> loadSettings() async {
    _settings = await RecordingSettings.load(_db);
    state = state.phase != RecordingPhase.idle
        ? state.copyWith(imperial: _settings.imperial)
        : RecordingState.initial(
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
    await _sources.teardown();
    await loadSettings();
  }

  /// Starts GNSS before recording so the user sees fix quality.
  /// Simulated sources start only with the recording.
  Future<void> warmUp() async {
    if (state.phase != RecordingPhase.idle || _settings.simulated) return;
    if (!_sources.hasLocation) _startLocation();
  }

  /// Stops idle warm-up (screen closed without recording).
  Future<void> coolDown() async {
    if (state.phase == RecordingPhase.idle) await _sources.teardown();
  }

  void _startLocation() {
    final src = _sources.createLocation(
      simulated: _settings.simulated,
      speedUp: _settings.simSpeedUp,
      notificationLabel: state.sport.displayName,
    );
    if (!src.isSimulated) {
      state = state.copyWith(gps: GpsStatus.searching);
    }
    _sources.listenLocation(
        onFix: _onFix, onError: _onLocationError, onTick: _tick);
  }

  void _onLocationError(Object e) {
    debugPrint('Location error: $e');
    state = state.copyWith(
        gps: GpsStatus.off, message: 'GPS error: lokasi tidak tersedia');
  }

  Future<String?> start() async {
    if (state.phase != RecordingPhase.idle) return state.activityId;
    final (id, now) = await _store.createActivity(state.sport);
    await _beginSession(id, now, state.sport, const []);
    _cues.onStart();
    return id;
  }

  /// Continue an interrupted (crash) session with its stored points.
  Future<void> resumeRecovered(Activity activity) async {
    if (state.isActive) return;
    _settings = await RecordingSettings.load(_db);
    final sport = sportFromName(activity.sportType);
    final (history, nextSeq, photoCount) =
        await _store.loadRecovered(activity.id);
    state = state.copyWith(
      sport: sport,
      simulated: _settings.simulated,
      imperial: _settings.imperial,
      photoCount: photoCount,
    );
    await _beginSession(
        activity.id, activity.startTime, sport, history, nextSeq);
  }

  Future<void> _beginSession(String activityId, DateTime startTime,
      SportType sport, List<TrackSample> history,
      [int nextSeq = 0]) async {
    final session = RecordingSession(
      db: _db,
      activityId: activityId,
      startTime: startTime,
      sport: sport,
      settings: _settings,
      history: history,
      nextSeq: nextSeq,
    );
    _session = session;

    await _cues.configure(
      enabled: _settings.ttsEnabled,
      imperial: _settings.imperial,
      splitUnits: _settings.ttsSplit,
      sport: sport,
    );
    await _feed.begin(sport);
    final snap =
        session.pipeline.snapshotAt(session.lastSampleTime ?? startTime);
    if (history.isNotEmpty) _cues.seed(snap);

    state = state.copyWith(
      phase: RecordingPhase.recording,
      activityId: activityId,
      sport: sport,
      snapshot: snap,
      route: session.route,
      clearMessage: true,
    );

    if (!_sources.hasLocation) _startLocation();
    _sources.startSensors(session, simulated: _settings.simulated);
    if (_settings.keepScreenOn) await _platform.setKeepAwake(true);
  }

  void pause() {
    if (state.phase != RecordingPhase.recording) return;
    _session?.pipeline.setManualPause(true);
    state = state.copyWith(
      phase: RecordingPhase.paused,
      snapshot: _session?.snapshotNow(simulated: _sources.isSimulated),
    );
    _session?.flushNow();
    _cues.onManualPause(true);
  }

  void resume() {
    if (state.phase != RecordingPhase.paused) return;
    _session?.pipeline.setManualPause(false);
    state = state.copyWith(
      phase: RecordingPhase.recording,
      snapshot: _session?.snapshotNow(simulated: _sources.isSimulated),
    );
    _cues.onManualPause(false);
  }

  /// Flushes, finalizes and returns the saved activity id. Returns null when
  /// nothing was recorded (the empty activity is deleted).
  Future<String?> stop() async {
    if (!state.isActive) return null;
    final id = state.activityId!;
    await _closeSession();
    if (await _store.countPoints(id) == 0) {
      await _store.deleteActivity(id);
      _reset(message: 'Tidak ada data GPS — aktivitas tidak disimpan.');
      return null;
    }
    await _store.finish(id, _session?.lastSampleTime);
    _reset();
    return id;
  }

  /// Deletes the current session and all its points/photos.
  Future<void> discard() async {
    if (!state.isActive) return;
    final id = state.activityId!;
    await _closeSession(logFlushError: false);
    await _store.deleteActivity(id);
    _reset(message: 'Aktivitas dibuang.');
  }

  /// Copies a captured image into app storage and geotags it.
  Future<bool> addPhoto(String sourcePath) async {
    final id = state.activityId;
    final pipe = _session?.pipeline;
    if (!state.isActive || id == null || pipe == null || !pipe.hasFix) {
      state = state.copyWith(message: 'Belum ada posisi GPS untuk foto.');
      return false;
    }
    await _store.savePhoto(
      activityId: id,
      sourcePath: sourcePath,
      dir: await _platform.photosDirectory(),
      pipe: pipe,
      isFirst: state.photoCount == 0,
    );
    state = state.copyWith(photoCount: state.photoCount + 1);
    return true;
  }

  void clearMessage() => state = state.copyWith(clearMessage: true);

  void _onFix(LocationFix fix) {
    final session = _session;
    final gps = _sources.isSimulated
        ? GpsStatus.simulated
        : gpsStatusForAccuracy(fix.accuracy);
    if (!state.isActive || session == null) {
      if (state.phase == RecordingPhase.idle) {
        state = state.copyWith(gps: gps);
      }
      return;
    }

    final r = session.process(fix);
    final snap = r.snapshot;
    if (r.autoPauseChanged) _cues.onAutoPause(session.pipeline.isAutoPaused);
    _cues.onSnapshot(snap);
    final p = r.sample;
    if (p != null && !session.pipeline.isManuallyPaused) {
      _cues.announce(_feed.onFix(p.lat, p.lon, p.time));
    }

    state = state.copyWith(
      snapshot: snap,
      route: r.sample != null ? session.route : null,
      gps: gps,
    );
  }

  void _tick() {
    if (_sources.isSimulated) return;
    final stale = _sources.isStale;
    if (stale && state.gps != GpsStatus.searching) {
      state = state.copyWith(gps: GpsStatus.searching);
    }
    // Keep elapsed time ticking through GPS gaps.
    final pipe = _session?.pipeline;
    if (stale && pipe != null && state.isActive) {
      state = state.copyWith(snapshot: pipe.snapshotAt(DateTime.now()));
    }
  }

  /// Enters the saving phase, stops sources, writes remaining points,
  /// releases the wakelock and stops audio cues.
  Future<void> _closeSession({bool logFlushError = true}) async {
    state = state.copyWith(phase: RecordingPhase.saving);
    _feed.end();
    await _sources.teardown();
    try {
      await _session?.closeFlush();
    } catch (e) {
      if (logFlushError) debugPrint('Final flush failed: $e');
    }
    await _platform.setKeepAwake(false);
    await _cues.stop();
  }

  void _reset({String? message}) {
    _session = null;
    state = RecordingState.initial(
      sport: state.sport,
      simulated: _settings.simulated,
      imperial: _settings.imperial,
    ).copyWith(message: message);
  }
}

final recordingControllerProvider =
    NotifierProvider<RecordingController, RecordingState>(
  RecordingController.new,
);
