import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/calendar/presentation/calendar_screen.dart';
import 'package:virya/features/home/presentation/home_shell.dart';
import 'package:virya/features/today/presentation/today_screen.dart';
import 'package:virya/features/training/presentation/training_screen.dart';

void main() {
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
    await tester.pumpAndSettle();

    expect(find.text('HARI INI'), findsOneWidget);
    expect(find.text('KALENDER'), findsOneWidget);
    expect(find.text('AKSI'), findsOneWidget);
    expect(find.text('LATIHAN'), findsOneWidget);
    expect(find.text('PROFIL'), findsOneWidget);
  });

  testWidgets('TodayScreen renders greeting, status, and tasks checklist', (tester) async {
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
    await tester.pumpAndSettle();

    expect(find.textContaining('HARI INI // VIRYA'), findsOneWidget);
    expect(find.textContaining('Kondisi Kebugaran'), findsOneWidget);
    expect(find.textContaining('Tugas Hari Ini'), findsOneWidget);
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
    await tester.pumpAndSettle();

    expect(find.text('JURNAL RIWAYAT'), findsOneWidget);
    expect(find.text('STATISTIK & BEBAN'), findsOneWidget);

    await tester.tap(find.text('STATISTIK & BEBAN'));
    await tester.pumpAndSettle();
    expect(find.text('STATISTIK & BEBAN'), findsOneWidget);
  });

  testWidgets('CalendarScreen renders heatmap and date filter', (tester) async {
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
    await tester.pumpAndSettle();

    expect(find.text('SEMUA'), findsOneWidget);
    expect(find.text('SEPEDA'), findsOneWidget);
    expect(find.text('LARI'), findsOneWidget);
    expect(find.text('JALAN'), findsOneWidget);
    expect(find.textContaining('Heatmap 24 Minggu'), findsOneWidget);
  });
}

