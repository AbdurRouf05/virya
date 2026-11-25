import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/social/data/social_providers.dart';
import 'package:virya/features/social/data/social_repository.dart';
import 'package:virya/features/social/presentation/social_screen.dart';

void main() {
  testWidgets(
    'circle screen explains local-only boundary and creates identity',
    (tester) async {
      final db = AppDatabase.memory();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          socialRepositoryProvider.overrideWithValue(
            SocialRepository(db.socialDao, keyStore: MemorySocialKeyStore()),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SocialScreen()),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('belum terenkripsi'), findsOneWidget);
      expect(find.textContaining('Belum ada transfer'), findsOneWidget);
      await tester.tap(find.text('BUAT IDENTITAS'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Kiki');
      await tester.tap(find.text('Simpan'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Kiki'), findsOneWidget);
      expect(find.text('BUAT CIRCLE'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
