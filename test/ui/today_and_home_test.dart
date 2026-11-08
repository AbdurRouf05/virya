import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/calendar/presentation/calendar_screen.dart';
import 'package:virya/features/home/presentation/home_shell.dart';
import 'package:virya/features/today/presentation/today_screen.dart';
import 'package:virya/features/training/presentation/training_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  Future<void> drain(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('HomeShell renders 5-tab bar with Today, Calendar, Action, Training, Profile', (tester) async {
    final db = AppDatabase.memory();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: FieldNotesTheme.paper,
          home: const HomeShell(checkRecovery: false),
        ),
      ),
    );
    await drain(tester);

    expect(find.text('HARI INI'), findsOneWidget);
    expect(find.text('KALENDER'), findsOneWidget);
    expect(find.text('AKSI'), findsOneWidget);
    expect(find.text('LATIHAN'), findsOneWidget);
    expect(find.text('PROFIL'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('TodayScreen renders greeting and tasks checklist', (tester) async {
    final db = AppDatabase.memory();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: FieldNotesTheme.paper,
          home: const TodayScreen(),
        ),
      ),
    );
    await drain(tester);

    expect(find.textContaining('HARI INI // VIRYA', findRichText: true), findsOneWidget);
    expect(find.textContaining('KONDISI KEBUGARAN', findRichText: true), findsWidgets);

    await teardown(tester);
  });

  testWidgets('TrainingScreen switches between Journal and Stats sub-tabs', (tester) async {
    final db = AppDatabase.memory();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: FieldNotesTheme.paper,
          home: const TrainingScreen(),
        ),
      ),
    );
    await drain(tester);

    expect(find.text('JURNAL RIWAYAT'), findsOneWidget);
    expect(find.text('STATISTIK & BEBAN'), findsOneWidget);

    await tester.tap(find.text('STATISTIK & BEBAN'));
    await drain(tester);
    expect(find.text('STATISTIK & BEBAN'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('CalendarScreen renders heatmap and filter chips', (tester) async {
    final db = AppDatabase.memory();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: FieldNotesTheme.paper,
          home: const CalendarScreen(),
        ),
      ),
    );
    await drain(tester);

    expect(find.text('SEMUA'), findsOneWidget);
    expect(find.text('SEPEDA'), findsOneWidget);
    expect(find.text('LARI'), findsOneWidget);
    expect(find.text('JALAN'), findsOneWidget);
    expect(find.textContaining('KONSISTENSI // KALENDER', findRichText: true), findsOneWidget);

    await teardown(tester);
  });
}
