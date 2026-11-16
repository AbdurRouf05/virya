import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/app/virya_app.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/splash/presentation/look_gate.dart';
import 'package:virya/features/splash/presentation/style_picker_screen.dart';

const _home = Scaffold(body: Text('HOMEPAGE'));

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Future<(ProviderContainer, AppDatabase)> _pump(
  WidgetTester tester, {
  InitialLook look = const InitialLook(),
  Map<String, String> stored = const {},
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  addTearDown(tester.view.resetPhysicalSize);
  final db = AppDatabase.memory();
  for (final e in stored.entries) {
    await tester.runAsync(() => db.setSetting(e.key, e.value));
  }
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      initialLookProvider.overrideWithValue(look),
      initialStyleIdProvider.overrideWithValue(look.styleId),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const ViryaApp(home: LookGate(home: _home)),
    ),
  );
  await settle(tester);
  return (container, db);
}

Future<void> _dispose(
  WidgetTester tester,
  (ProviderContainer, AppDatabase) r,
) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  r.$1.dispose();
  await tester.runAsync(r.$2.close);
}

void main() {
  tearDown(() => FN.use(fieldNotesStyle));

  testWidgets('pemasangan baru: layar pilih gaya muncul', (tester) async {
    final r = await _pump(tester);
    expect(find.byType(StylePickerScreen), findsOneWidget);
    expect(find.text('HOMEPAGE'), findsNothing);
    expect(find.text('Pilih gaya'), findsOneWidget);

    // Sentuh Bersih: gaya langsung berganti, layar tetap di pilih gaya.
    await tester.tap(find.text('BERSIH'));
    await settle(tester);
    expect(FN.isClean, isTrue);
    expect(r.$1.read(skipEntryProvider), isTrue);
    expect(find.byType(StylePickerScreen), findsOneWidget);
    expect(find.text('Terang'), findsOneWidget);
    expect(r.$1.read(needsLookChoiceProvider), isTrue);
    await _dispose(tester, r);
  });

  testWidgets('Lanjut menyimpan pilihan dan masuk Beranda', (tester) async {
    final r = await _pump(tester);
    await tester.tap(find.text('LANJUT'));
    await settle(tester);
    expect(find.text('HOMEPAGE'), findsOneWidget);
    expect(find.byType(StylePickerScreen), findsNothing);
    expect(r.$1.read(needsLookChoiceProvider), isFalse);
    expect(r.$1.read(uiGayaProvider), UiGaya.tegas);
    final saved = await tester.runAsync(
      () => r.$2.getSetting(SettingKeys.lookChosen),
    );
    expect(saved, 'true');
    await _dispose(tester, r);
  });

  testWidgets('sudah memilih: langsung Beranda', (tester) async {
    final r = await _pump(
      tester,
      look: const InitialLook(gaya: 'bersih', lookChosen: 'true'),
      stored: {SettingKeys.uiGaya: 'bersih', SettingKeys.lookChosen: 'true'},
    );
    expect(find.text('HOMEPAGE'), findsOneWidget);
    expect(find.byType(StylePickerScreen), findsNothing);
    expect(FN.isClean, isTrue);
    await _dispose(tester, r);
  });

  testWidgets('pengguna lama dengan style tersimpan melewati layar ini', (
    tester,
  ) async {
    final r = await _pump(
      tester,
      look: const InitialLook(styleId: 'night'),
      stored: {SettingKeys.styleId: 'night'},
    );
    expect(find.text('HOMEPAGE'), findsOneWidget);
    expect(find.byType(StylePickerScreen), findsNothing);
    expect(FN.isClean, isFalse);
    expect(FN.palette.id, 'night');
    await _dispose(tester, r);
  });
}
