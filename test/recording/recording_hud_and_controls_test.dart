import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/location/models/telemetry_snapshot.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/recording_format.dart';
import 'package:virya/features/recording/presentation/widgets/amoled_hud_panel.dart';
import 'package:virya/features/recording/presentation/widgets/hold_to_confirm_button.dart';
import 'package:virya/features/recording/presentation/widgets/recording_controls.dart';
import 'package:virya/features/recording/presentation/widgets/recording_dialogs.dart';
import 'package:virya/features/recording/presentation/widgets/recording_hud.dart';

LiveTelemetrySnapshot _makeSnap({
  double speed = 0,
  double avgSpeed = 0,
  double distM = 0,
  int movingS = 0,
  int elapsedS = 0,
  double elevGain = 0,
  double grade = 0,
  int? heartRate,
}) =>
    LiveTelemetrySnapshot(
      currentSpeedKmh: speed,
      averageSpeedKmh: avgSpeed,
      totalDistanceMeters: distM,
      movingTimeSeconds: movingS,
      elapsedTimeSeconds: elapsedS,
      currentAltitudeMeters: 50,
      totalElevationGainMeters: elevGain,
      currentGradePct: grade,
      currentSurface: SurfaceType.asphalt,
      latitude: -6.9,
      longitude: 107.6,
      accuracyMeters: 4,
      bearingDegrees: 180,
      timestamp: DateTime(2026, 11, 17),
      isAutoPaused: false,
      heartRate: heartRate,
    );

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: FN.night,
      body: child,
    ),
  );
}

void main() {
  group('AMOLED HUD Panel & Recording HUD', () {
    testWidgets('Renders without clipping on 3-digit speed and multi-hour duration',
        (tester) async {
      // 3-digit speed (108.4 km/h) and long duration (12:34:56 = 45296s)
      final snap = _makeSnap(
        speed: 108.4,
        avgSpeed: 42.8,
        distM: 145800,
        movingS: 45296,
        elapsedS: 46000,
        elevGain: 2450,
        grade: 7.5,
        heartRate: 165,
      );

      final state = RecordingState.initial(sport: SportType.roadCycling).copyWith(
        phase: RecordingPhase.recording,
        snapshot: snap,
      );
      const fmt = RecFormat(imperial: false);

      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(RecordingHud(state: state, fmt: fmt)));
      await tester.pump();

      expect(tester.takeException(), isNull);

      // Verify primary metric speed readout
      expect(find.text('108.4'), findsOneWidget);
      expect(find.text('KECEPATAN · KM/J'), findsOneWidget);

      // Verify secondary grid metric readouts
      expect(find.text('145.8'), findsOneWidget); // distance
      expect(find.text('12:34:56'), findsOneWidget); // moving time
      expect(find.text('2450'), findsOneWidget); // elevation
      expect(find.text('+7.5'), findsOneWidget); // grade
      expect(find.text('42.8'), findsOneWidget); // avg speed
      expect(find.text('165'), findsOneWidget); // heart rate
      expect(find.text('BPM'), findsOneWidget);

      // Verify AmoledHudPanel directly works too
      await tester.pumpWidget(_wrap(AmoledHudPanel(state: state, fmt: fmt)));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Shows paused ribbon with correct colors and typography',
        (tester) async {
      final snap = _makeSnap(speed: 0);

      final state = RecordingState.initial(sport: SportType.roadRunning).copyWith(
        phase: RecordingPhase.paused,
        snapshot: snap,
      );
      const fmt = RecFormat(imperial: false);

      await tester.pumpWidget(_wrap(RecordingHud(state: state, fmt: fmt)));
      await tester.pump();

      expect(find.text('DIJEDA'), findsOneWidget);
      expect(find.text('PACE · /KM'), findsOneWidget);
    });
  });

  group('Recording Controls & Touch Targets', () {
    testWidgets('Idle controls render large start button and sim toggle',
        (tester) async {
      var started = false;
      var simToggled = false;

      final state = RecordingState.initial();

      await tester.pumpWidget(_wrap(
        RecordingControls(
          state: state,
          busy: false,
          onStart: () => started = true,
          onPause: () {},
          onResume: () {},
          onStop: () {},
          onDiscard: () {},
          onPhoto: () {},
          onToggleSim: (_) => simToggled = true,
        ),
      ));

      expect(find.text('MULAI'), findsOneWidget);
      expect(find.text('GPS SIMULASI (DEV)'), findsOneWidget);

      // Verify button tap
      await tester.tap(find.text('MULAI'));
      expect(started, isTrue);

      // Verify switch toggle
      await tester.tap(find.byType(Switch));
      expect(simToggled, isTrue);
    });

    testWidgets('Recording controls render JEDA and SELESAI with min touch target',
        (tester) async {
      var paused = false;

      final state = RecordingState.initial().copyWith(
        phase: RecordingPhase.recording,
      );

      await tester.pumpWidget(_wrap(
        RecordingControls(
          state: state,
          busy: false,
          onStart: () {},
          onPause: () => paused = true,
          onResume: () {},
          onStop: () {},
          onDiscard: () {},
          onPhoto: () {},
          onToggleSim: (_) {},
        ),
      ));

      expect(find.text('JEDA'), findsOneWidget);
      expect(find.text('SELESAI'), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera), findsOneWidget);

      // Verify pause tap
      await tester.tap(find.text('JEDA'));
      expect(paused, isTrue);
    });

    testWidgets('Paused controls render LANJUT, TAHAN · SELESAI, and BUANG AKTIVITAS',
        (tester) async {
      var resumed = false;
      var discarded = false;

      final state = RecordingState.initial().copyWith(
        phase: RecordingPhase.paused,
      );

      await tester.pumpWidget(_wrap(
        RecordingControls(
          state: state,
          busy: false,
          onStart: () {},
          onPause: () {},
          onResume: () => resumed = true,
          onStop: () {},
          onDiscard: () => discarded = true,
          onPhoto: () {},
          onToggleSim: (_) {},
        ),
      ));

      expect(find.text('LANJUT'), findsOneWidget);
      expect(find.text('TAHAN · SELESAI'), findsOneWidget);
      expect(find.text('BUANG AKTIVITAS'), findsOneWidget);

      await tester.tap(find.text('LANJUT'));
      expect(resumed, isTrue);

      await tester.tap(find.text('BUANG AKTIVITAS'));
      expect(discarded, isTrue);
    });
  });

  group('HoldToConfirmButton', () {
    testWidgets('Fires only on complete hold duration', (tester) async {
      var confirmed = false;

      await tester.pumpWidget(_wrap(
        HoldToConfirmButton(
          label: 'SELESAI',
          icon: Icons.stop,
          holdDuration: const Duration(milliseconds: 300),
          onConfirmed: () => confirmed = true,
        ),
      ));

      // Quick tap should not confirm
      await tester.tap(find.byType(HoldToConfirmButton));
      await tester.pump(const Duration(milliseconds: 100));
      expect(confirmed, isFalse);

      // Long press (hold) through full duration
      final gesture = await tester.startGesture(tester.getCenter(find.byType(HoldToConfirmButton)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pump();

      expect(confirmed, isTrue);
    });
  });

  group('Recording Dialogs', () {
    testWidgets('Discard dialog shows clean Field Notes typography and actions',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showDiscardRecordingDialog(ctx),
              child: const Text('OPEN'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      expect(find.text('BUANG AKTIVITAS?'), findsOneWidget);
      expect(
        find.text('Seluruh rute, data, dan foto sesi ini akan dihapus permanen.'),
        findsOneWidget,
      );
      expect(find.text('BATAL'), findsOneWidget);
      expect(find.text('BUANG'), findsOneWidget);

      await tester.tap(find.text('BATAL'));
      await tester.pumpAndSettle();

      expect(find.text('BUANG AKTIVITAS?'), findsNothing);
    });
  });
}
