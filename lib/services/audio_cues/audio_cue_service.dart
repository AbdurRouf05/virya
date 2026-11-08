import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/location/models/telemetry_snapshot.dart';
import 'package:virya/services/audio_cues/cue_formatter.dart';

/// Minimal speech interface so cue logic is testable without the plugin.
abstract class TtsEngine {
  /// Prepares the engine; returns the language actually available.
  Future<CueLanguage> init();
  Future<void> speak(String text);
  Future<void> stop();
}

class FlutterTtsEngine implements TtsEngine {
  final FlutterTts _tts = FlutterTts();

  @override
  Future<CueLanguage> init() async {
    try {
      await _tts.awaitSpeakCompletion(false);
      await _tts.setSpeechRate(0.5);
      final idOk = await _tts.isLanguageAvailable('id-ID');
      if (idOk == true || idOk == 1) {
        await _tts.setLanguage('id-ID');
        return CueLanguage.indonesian;
      }
      await _tts.setLanguage('en-US');
    } catch (e) {
      debugPrint('TTS init failed: $e');
    }
    return CueLanguage.english;
  }

  @override
  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

/// Announces splits and pause/resume during recording.
class AudioCueService {
  final TtsEngine engine;
  bool enabled = true;
  bool imperial = false;
  SportType sport = SportType.gravelCycling;

  CueFormatter _fmt = const CueFormatter();
  SplitTracker _splits = SplitTracker(1000);
  bool _ready = false;

  AudioCueService(this.engine);

  /// Configure for a new session. [splitUnits] is in km (or miles if imperial).
  Future<void> configure({
    required bool enabled,
    required bool imperial,
    required double splitUnits,
    required SportType sport,
  }) async {
    this.enabled = enabled;
    this.imperial = imperial;
    this.sport = sport;
    final unitM = imperial ? 1609.344 : 1000.0;
    _splits = SplitTracker((splitUnits <= 0 ? 1 : splitUnits) * unitM);
    if (enabled && !_ready) {
      final lang = await engine.init();
      _fmt = CueFormatter(lang: lang, imperial: imperial);
      _ready = true;
    } else {
      _fmt = CueFormatter(lang: _fmt.lang, imperial: imperial);
    }
  }

  void seed(LiveTelemetrySnapshot s) => _splits.seed(s);

  /// Returns the text spoken (for tests), or null.
  String? onSnapshot(LiveTelemetrySnapshot s) {
    final split = _splits.update(s);
    if (split == null || !enabled) return null;
    return _say(_fmt.split(split, sport));
  }

  String? onAutoPause(bool paused) =>
      enabled ? _say(paused ? _fmt.autoPaused() : _fmt.autoResumed()) : null;

  String? onManualPause(bool paused) =>
      enabled ? _say(paused ? _fmt.manualPaused() : _fmt.manualResumed()) : null;

  String? onStart() => enabled ? _say(_fmt.started()) : null;

  /// Membacakan teks dari modul lain; `null` berarti tidak ada yang dibacakan.
  String? announce(String? text) => enabled && text != null ? _say(text) : null;

  String _say(String text) {
    engine.speak(text);
    return text;
  }

  Future<void> stop() => engine.stop();
}

final ttsEngineProvider = Provider<TtsEngine>((ref) => FlutterTtsEngine());

final audioCueServiceProvider = Provider<AudioCueService>(
  (ref) => AudioCueService(ref.watch(ttsEngineProvider)),
);
