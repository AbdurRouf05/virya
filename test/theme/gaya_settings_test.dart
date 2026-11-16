import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/app/virya_app.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/settings/presentation/widgets/style_picker.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}

void main() {
  tearDown(() => FN.use(fieldNotesStyle));

  test('nilai awal gaya dibaca dari InitialLook', () {
    final db = AppDatabase.memory();
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        initialLookProvider.overrideWithValue(
          const InitialLook(gaya: 'bersih', bersihMode: 'gelap'),
        ),
      ],
    );
    expect(c.read(uiGayaProvider), UiGaya.bersih);
    expect(c.read(bersihModeProvider), BersihMode.gelap);
    c.dispose();
    db.close();
  });

  testWidgets('Pengaturan: pilih Bersih, Terapkan, tersimpan', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    final db = AppDatabase.memory();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ViryaApp(
          home: Scaffold(body: SingleChildScrollView(child: StylePicker())),
        ),
      ),
    );
    await settle(tester);
    expect(FN.isClean, isFalse);
    expect(find.text('TEGAS'), findsOneWidget);

    await tester.tap(find.text('BERSIH'));
    await tester.pump();
    expect(find.text('TERANG'), findsOneWidget);
    await tester.tap(find.text('GELAP'));
    await tester.pump();
    await tester.tap(find.text('TERAPKAN'));
    await settle(tester);

    expect(container.read(uiGayaProvider), UiGaya.bersih);
    expect(container.read(bersihModeProvider), BersihMode.gelap);
    expect(FN.isClean, isTrue);
    expect(FN.isDark, isTrue);
    // Bersih: label kapital kalimat.
    expect(find.text('Gelap'), findsOneWidget);
    final stored = await tester.runAsync(
      () async => (
        await db.getSetting(SettingKeys.uiGaya),
        await db.getSetting(SettingKeys.bersihMode),
      ),
    );
    expect(stored, ('bersih', 'gelap'));

    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.runAsync(db.close);
  });
}
