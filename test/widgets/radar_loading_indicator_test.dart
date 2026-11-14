import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/core/widgets/radar_loading_indicator.dart';

void main() {
  setUp(() {
    FN.use(fieldNotesStyle);
  });

  testWidgets('RadarLoadingIndicator renders default state with radar & telemetry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RadarLoadingIndicator(),
          ),
        ),
      ),
    );

    // Initial render
    expect(find.byType(RadarLoadingIndicator), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(
      find.text('MENCARI KOORDINAT GPS... [SATELLITE LOCKING]'),
      findsOneWidget,
    );
    expect(find.textContaining('LAT: -06° 54\' 32.1" S'), findsOneWidget);
    expect(find.text('SATS: 9/12 • AKURASI ±3M'), findsOneWidget);

    // Pump a few frames of animation
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));

    // Verify clean disposal
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('RadarLoadingIndicator respects custom size, label, and hidden coordinates', (
    WidgetTester tester,
  ) async {
    const customLabel = 'MENYELARASKAN TELEMETRI GNSS...';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RadarLoadingIndicator(
              size: 240,
              label: customLabel,
              accentColor: FN.signal,
              showCoordinates: false,
              showTelemetry: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text(customLabel), findsOneWidget);
    expect(find.textContaining('LAT:'), findsNothing);
    expect(find.textContaining('SATS:'), findsNothing);

    // Verify radar canvas size
    final sizedBox = tester.widget<SizedBox>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.width == 240 && widget.height == 240,
      ),
    );
    expect(sizedBox.width, 240);
    expect(sizedBox.height, 240);

    // Clean disposal
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('RadarLoadingIndicator updates duration when period changes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RadarLoadingIndicator(
              period: Duration(milliseconds: 3000),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Update with new period
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RadarLoadingIndicator(
              period: Duration(milliseconds: 1500),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Clean disposal
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
