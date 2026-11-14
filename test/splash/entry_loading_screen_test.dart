import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/app/theme/styles/blueprint_style.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/app/theme/styles/forest_style.dart';
import 'package:virya/app/theme/styles/night_style.dart';
import 'package:virya/core/widgets/virya_mark.dart';
import 'package:virya/features/splash/presentation/entry_loading_screen.dart';

void main() {
  group('EntryLoadingScreen Dynamic Theme & Style Tests', () {
    testWidgets('adapts colors to current active style palette', (tester) async {
      // 1. Test with default Field Notes Style
      FN.use(fieldNotesStyle);
      await tester.pumpWidget(
        const MaterialApp(
          home: EntryLoadingScreen(
            totalDuration: Duration(milliseconds: 2000),
          ),
        ),
      );

      final scaffold1 = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold1.backgroundColor, fieldNotesStyle.night);

      final viryaMark1 = tester.widget<ViryaMark>(find.byType(ViryaMark));
      expect(viryaMark1.ink, fieldNotesStyle.onNight);
      expect(viryaMark1.accent, fieldNotesStyle.signal);

      // 2. Switch to Blueprint Style (Cetak Biru)
      FN.use(blueprintStyle);
      await tester.pumpWidget(
        const MaterialApp(
          home: EntryLoadingScreen(
            totalDuration: Duration(milliseconds: 2000),
          ),
        ),
      );

      final scaffold2 = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold2.backgroundColor, blueprintStyle.night);

      final viryaMark2 = tester.widget<ViryaMark>(find.byType(ViryaMark));
      expect(viryaMark2.ink, blueprintStyle.onNight);
      expect(viryaMark2.accent, blueprintStyle.signal);

      // 3. Switch to Forest Style (Hutan)
      FN.use(forestStyle);
      await tester.pumpWidget(
        const MaterialApp(
          home: EntryLoadingScreen(
            totalDuration: Duration(milliseconds: 2000),
          ),
        ),
      );

      final scaffold3 = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold3.backgroundColor, forestStyle.night);

      // 4. Switch to Night Style (Malam)
      FN.use(nightStyle);
      await tester.pumpWidget(
        const MaterialApp(
          home: EntryLoadingScreen(
            totalDuration: Duration(milliseconds: 2000),
          ),
        ),
      );

      final scaffold4 = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold4.backgroundColor, nightStyle.night);

      // Reset back to field notes
      FN.use(fieldNotesStyle);
    });

    testWidgets('tap to skip works across styles', (tester) async {
      var skipped = false;
      FN.use(fieldNotesStyle);

      await tester.pumpWidget(
        MaterialApp(
          home: EntryLoadingScreen(
            target: Scaffold(
              body: TextButton(
                onPressed: () => skipped = true,
                child: const Text('HOMEPAGE'),
              ),
            ),
            totalDuration: const Duration(milliseconds: 2000),
          ),
        ),
      );

      await tester.tap(find.byType(EntryLoadingScreen));
      await tester.pumpAndSettle();

      expect(find.text('HOMEPAGE'), findsOneWidget);
    });
  });
}
