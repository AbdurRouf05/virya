import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/app/theme/field_notes.dart';
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

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  tearDown(() => FN.use(fieldNotesStyle));

  testWidgets('TERAPKAN muncul setelah memilih dan menyimpan pilihan', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    final db = AppDatabase.memory();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: FieldNotesTheme.paper,
          home: const Scaffold(body: StylePicker()),
        ),
      ),
    );
    await settle(tester);
    expect(find.text('FIELD NOTES'), findsOneWidget);
    expect(find.text('TERAPKAN'), findsNothing);

    await tester.tap(find.text('MALAM'));
    await tester.pump();
    expect(find.text('TERAPKAN'), findsOneWidget);
    expect(container.read(styleIdProvider), isNull);

    await tester.tap(find.text('TERAPKAN'));
    await settle(tester);
    expect(container.read(styleIdProvider), 'night');
    expect(find.text('TERAPKAN'), findsNothing);

    await unmount(tester);
    container.dispose();
    await tester.runAsync(db.close);
  });

  testWidgets('aplikasi dibangun ulang dengan style baru', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    final db = AppDatabase.memory();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ViryaApp(home: Scaffold()),
      ),
    );
    await settle(tester);
    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().theme!.brightness, Brightness.light);
    final firstKey = app().key;

    // Tanpa await, seperti saat tombol ditekan: database dibuat di zona tes.
    container
        .read(settingsProvider.notifier)
        .set(SettingKeys.styleId, 'night');
    await settle(tester);
    expect(app().theme!.brightness, Brightness.dark);
    expect(app().key, isNot(firstKey));
    expect(FN.palette.id, 'night');
    expect(app().theme!.scaffoldBackgroundColor, FN.paper);

    await unmount(tester);
    container.dispose();
    await tester.runAsync(db.close);
  });
}
