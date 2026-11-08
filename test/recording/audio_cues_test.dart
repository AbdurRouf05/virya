import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/location/models/telemetry_snapshot.dart';
import 'package:virya/services/audio_cues/audio_cue_service.dart';
import 'package:virya/services/audio_cues/cue_formatter.dart';

class FakeTts implements TtsEngine {
  final CueLanguage lang;
  final spoken = <String>[];
  FakeTts([this.lang = CueLanguage.indonesian]);

  @override
  Future<CueLanguage> init() async => lang;
  @override
  Future<void> speak(String text) async => spoken.add(text);
  @override
  Future<void> stop() async {}
}

LiveTelemetrySnapshot snap(double distM, int movingS, {double gain = 0}) =>
    LiveTelemetrySnapshot(
      currentSpeedKmh: 20,
      averageSpeedKmh: 20,
      totalDistanceMeters: distM,
      movingTimeSeconds: movingS,
      elapsedTimeSeconds: movingS,
      currentAltitudeMeters: 0,
      totalElevationGainMeters: gain,
      currentGradePct: 0,
      currentSurface: SurfaceType.unknown,
      latitude: 0,
      longitude: 0,
      accuracyMeters: 4,
      bearingDegrees: 0,
      timestamp: DateTime(2026),
      isAutoPaused: false,
    );

void main() {
  group('SplitTracker', () {
    test('fires once per km with split deltas', () {
      final t = SplitTracker(1000);
      expect(t.update(snap(500, 90)), isNull);
      final s1 = t.update(snap(1003, 180, gain: 12))!;
      expect(s1.index, 1);
      expect(s1.splitMovingS, 180);
      expect(s1.splitGainM, 12);
      expect(t.update(snap(1500, 270)), isNull);
      final s2 = t.update(snap(2001, 360, gain: 20))!;
      expect(s2.index, 2);
      expect(s2.splitMovingS, 180);
      expect(s2.splitGainM, 8);
    });

    test('seed skips already-announced splits', () {
      final t = SplitTracker(1000)..seed(snap(3500, 900));
      expect(t.update(snap(3900, 1000)), isNull);
      expect(t.update(snap(4001, 1030))!.index, 4);
    });
  });

  group('CueFormatter', () {
    const split = SplitInfo(
      index: 5,
      unitM: 1000,
      splitMovingS: 150,
      splitDistanceM: 1000,
      splitGainM: 35.4,
      totalMovingS: 754,
    );

    test('Indonesian cycling: split time, avg speed, elevation', () {
      final s = const CueFormatter().split(split, SportType.gravelCycling);
      expect(s, contains('Kilometer 5.'));
      expect(s, contains('Waktu split 2 menit 30 detik'));
      expect(s, contains('kecepatan rata-rata 24 kilometer per jam'));
      expect(s, contains('Total waktu 12 menit 34 detik.'));
      expect(s, contains('Naik 35 meter.'));
    });

    test('Indonesian running: pace per km', () {
      const run = SplitInfo(
        index: 2,
        unitM: 1000,
        splitMovingS: 332,
        splitDistanceM: 1000,
        splitGainM: 0,
        totalMovingS: 650,
      );
      final s = const CueFormatter().split(run, SportType.roadRunning);
      expect(s, contains('Pace 5 menit 32 detik per kilometer.'));
      expect(s, isNot(contains('Naik')));
    });

    test('decimal speed uses "koma"; English fallback', () {
      const sp = SplitInfo(
        index: 1,
        unitM: 1000,
        splitMovingS: 147,
        splitDistanceM: 1000,
        splitGainM: 0,
        totalMovingS: 147,
      );
      expect(const CueFormatter().split(sp, SportType.roadCycling),
          contains('24 koma 5 kilometer per jam'));
      final en = const CueFormatter(lang: CueLanguage.english)
          .split(sp, SportType.roadCycling);
      expect(en, contains('Kilometer 1.'));
      expect(en, contains('24.5 kilometers per hour'));
    });

    test('imperial uses miles', () {
      const sp = SplitInfo(
        index: 1,
        unitM: 1609.344,
        splitMovingS: 240,
        splitDistanceM: 1609.344,
        splitGainM: 10,
        totalMovingS: 240,
      );
      final s = const CueFormatter(imperial: true)
          .split(sp, SportType.gravelCycling);
      expect(s, contains('Mil 1.'));
      expect(s, contains('15 mil per jam'));
      expect(s, contains('Naik 33 kaki.'));
    });
  });

  group('AudioCueService', () {
    test('speaks splits and pause events; silent when disabled', () async {
      final tts = FakeTts();
      final svc = AudioCueService(tts);
      await svc.configure(
          enabled: true, imperial: false, splitUnits: 1, sport: SportType.gravelCycling);
      svc.onSnapshot(snap(999, 100));
      svc.onSnapshot(snap(1001, 101));
      svc.onAutoPause(true);
      svc.onAutoPause(false);
      expect(tts.spoken, hasLength(3));
      expect(tts.spoken[1], 'Jeda otomatis.');
      expect(tts.spoken[2], 'Melanjutkan.');

      await svc.configure(
          enabled: false, imperial: false, splitUnits: 1, sport: SportType.gravelCycling);
      svc.onSnapshot(snap(5000, 900));
      svc.onAutoPause(true);
      expect(tts.spoken, hasLength(3));
    });

    test('custom split distance (2 km)', () async {
      final tts = FakeTts();
      final svc = AudioCueService(tts);
      await svc.configure(
          enabled: true, imperial: false, splitUnits: 2, sport: SportType.roadCycling);
      svc.onSnapshot(snap(1500, 300));
      expect(tts.spoken, isEmpty);
      svc.onSnapshot(snap(2010, 400));
      expect(tts.spoken.single, startsWith('Kilometer 2.'));
    });
  });
}
