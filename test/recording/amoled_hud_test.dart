import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/location/models/telemetry_snapshot.dart';
import 'package:virya/features/recording/domain/recording_settings.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/recording_format.dart';
import 'package:virya/features/recording/presentation/widgets/amoled_hud_panel.dart';

void main() {
  group('AmoledHudPanel Widget Test', () {
    testWidgets('renders pitch-black HUD and triggers onPeek when tapped',
        (tester) async {
      var peekTriggered = false;

      final state = RecordingState(
        phase: RecordingPhase.recording,
        sport: SportType.gravelCycling,
        snapshot: LiveTelemetrySnapshot(
          currentSpeedKmh: 28.4,
          averageSpeedKmh: 25.1,
          totalDistanceMeters: 14500,
          movingTimeSeconds: 2400,
          elapsedTimeSeconds: 2500,
          currentAltitudeMeters: 120,
          totalElevationGainMeters: 310,
          currentGradePct: 2.1,
          currentSurface: SurfaceType.asphalt,
          latitude: -6.9,
          longitude: 107.6,
          accuracyMeters: 4.0,
          bearingDegrees: 180,
          timestamp: DateTime.now(),
          isAutoPaused: false,
          heartRate: 142,
        ),
      );

      final fmt = RecFormat(imperial: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmoledHudPanel(
              state: state,
              fmt: fmt,
              onPeek: () {
                peekTriggered = true;
              },
            ),
          ),
        ),
      );

      // Verify essential labels and metrics are present
      expect(find.text('AMOLED PITCH-BLACK HUD'), findsOneWidget);
      expect(find.text('PETA DIJEDA (HEMAT DAYA)'), findsOneWidget);
      expect(find.text('KETUK UNTUK INTIP PETA (15s)'), findsOneWidget);
      expect(find.text('28.4'), findsOneWidget);
      expect(find.text('JARAK'), findsOneWidget);
      expect(find.text('WAKTU GERAK'), findsOneWidget);
      expect(find.text('DETAK JANTUNG'), findsOneWidget);
      expect(find.text('142'), findsOneWidget);
      expect(find.text('BPM'), findsOneWidget);

      // Tap to peek
      await tester.tap(find.byType(AmoledHudPanel));
      await tester.pump();

      expect(peekTriggered, isTrue);
    });

    test('RecordingSettings defaults amoledHud to false', () {
      const settings = RecordingSettings();
      expect(settings.amoledHud, isFalse);
      expect(RecordingSettings.keyAmoledHud, 'amoled_hud');
    });
  });
}
