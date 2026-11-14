import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/widgets/virya_mark.dart';
import 'package:virya/features/splash/presentation/entry_loading_screen.dart';

void main() {
  group('EntryLoadingScreen Widget Tests', () {
    testWidgets('renders brand elements, technical tags, and allows tap to skip',
        (tester) async {
      var arrivedAtHome = false;

      final targetWidget = Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => arrivedAtHome = true,
            child: const Text('MOCK_HOME'),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EntryLoadingScreen(
            target: targetWidget,
            totalDuration: const Duration(milliseconds: 2000),
          ),
        ),
      );

      // Verify branding and technical elements
      expect(find.byType(ViryaMark), findsOneWidget);
      expect(find.text('VIRYA'), findsOneWidget);
      expect(find.text('PERSONAL FIELD TRACKER'), findsOneWidget);
      expect(find.text('SYS//INIT 1.0.3'), findsOneWidget);
      expect(find.text('OFFLINE-FIRST'), findsOneWidget);
      expect(find.text('50Hz SENSORS'), findsOneWidget);
      expect(find.text('[ SENTUH UNTUK LEWATI ]'), findsOneWidget);

      // Tap to skip
      await tester.tap(find.byType(EntryLoadingScreen));
      await tester.pumpAndSettle();

      expect(find.text('MOCK_HOME'), findsOneWidget);
    });

    testWidgets('automatically transitions to target after duration expires',
        (tester) async {
      final targetWidget = const Scaffold(
        body: Center(child: Text('TARGET_ARRIVED')),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EntryLoadingScreen(
            target: targetWidget,
            totalDuration: const Duration(milliseconds: 800),
          ),
        ),
      );

      expect(find.text('TARGET_ARRIVED'), findsNothing);

      // Advance clock past the duration
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(find.text('TARGET_ARRIVED'), findsOneWidget);
    });
  });
}
