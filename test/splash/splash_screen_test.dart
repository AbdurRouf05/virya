import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders brandmark, subtitle, and progress stages',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(
          autoNavigate: false,
          duration: Duration(milliseconds: 2000),
        ),
      ),
    );

    // Initial render
    expect(find.text('VIRYA'), findsOneWidget);
    expect(find.text('OFFLINE EXPEDITION & TELEMETRY'), findsOneWidget);
    expect(find.text('VIRYA · FIELD NOTES EDITION'), findsOneWidget);
    expect(find.text('STATION ID: 08-YGY'), findsOneWidget);
    expect(find.text('INIT SENSOR FUSION ENGINE...'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    // Advance 50%
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('CALIBRATING BAROMETRIC ALTIMETER...'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);

    // Advance 100%
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('ACQUIRING 3D GPS LOCK · TOPO READY'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('SplashScreen navigates to nextScreen on completion',
      (tester) async {
    const dummyNext = Scaffold(body: Text('NEXT_SCREEN_LOADED'));

    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(
          autoNavigate: true,
          duration: Duration(milliseconds: 500),
          nextScreen: dummyNext,
        ),
      ),
    );

    expect(find.text('VIRYA'), findsOneWidget);

    // Let animation complete and navigation transition settle
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('NEXT_SCREEN_LOADED'), findsOneWidget);
  });

  testWidgets('SplashScreen tap allows skipping directly to nextScreen',
      (tester) async {
    const dummyNext = Scaffold(body: Text('SKIPPED_TO_HOME'));

    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(
          autoNavigate: false,
          duration: Duration(seconds: 10),
          nextScreen: dummyNext,
        ),
      ),
    );

    expect(find.text('VIRYA'), findsOneWidget);

    // Tap anywhere on screen
    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(find.text('SKIPPED_TO_HOME'), findsOneWidget);
  });
}
