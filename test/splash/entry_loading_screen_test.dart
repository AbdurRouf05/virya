import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/app/theme/styles/blueprint_style.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/app/theme/styles/forest_style.dart';
import 'package:virya/app/theme/styles/night_style.dart';
import 'package:virya/core/widgets/virya_mark.dart';
import 'package:virya/features/splash/presentation/entry_loading_screen.dart';

const _home = Scaffold(body: Text('HOMEPAGE'));

Widget _app({Duration hold = const Duration(milliseconds: 700)}) =>
    MaterialApp(home: EntryLoadingScreen(target: _home, hold: hold));

void main() {
  tearDown(() => FN.use(fieldNotesStyle));

  testWidgets('hanya menampilkan logo, tanpa teks atau loading', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.byType(ViryaMark), findsOneWidget);
    expect(find.byType(Text), findsNothing);
    expect(find.byType(ProgressIndicator), findsNothing);
    final mark = tester.widget<ViryaMark>(find.byType(ViryaMark));
    expect(mark.size, EntryLoadingScreen.markSize);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('warna mengikuti gaya yang aktif', (tester) async {
    for (final style in [fieldNotesStyle, blueprintStyle, forestStyle, nightStyle]) {
      FN.use(style);
      await tester.pumpWidget(_app(hold: const Duration(days: 1)));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, style.paper);
      final mark = tester.widget<ViryaMark>(find.byType(ViryaMark));
      expect(mark.ink, style.ink);
      expect(mark.accent, style.signal);
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('pindah ke Beranda setelah jeda', (tester) async {
    await tester.pumpWidget(_app());

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('HOMEPAGE'), findsNothing);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.text('HOMEPAGE'), findsOneWidget);
    expect(find.byType(EntryLoadingScreen), findsNothing);
  });

  testWidgets('sentuh untuk langsung lanjut', (tester) async {
    await tester.pumpWidget(_app(hold: const Duration(days: 1)));

    await tester.tap(find.byType(EntryLoadingScreen));
    await tester.pumpAndSettle();
    expect(find.text('HOMEPAGE'), findsOneWidget);
  });
}
