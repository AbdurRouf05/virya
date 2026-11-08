import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/activity_history/presentation/journal_screen.dart';

void main() {
  testWidgets('Jurnal shows empty state with demo & import actions', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: FieldNotesTheme.paper,
          home: const JournalScreen(),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    expect(find.text('MUAT RUTE DEMO'), findsOneWidget);
    expect(find.text('IMPOR RIWAYAT'), findsOneWidget);
    expect(find.textContaining('KOSONG', findRichText: true), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
