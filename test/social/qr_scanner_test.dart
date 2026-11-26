import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/social/data/social_providers.dart';
import 'package:virya/features/social/data/social_repository.dart';
import 'package:virya/features/social/presentation/social_screen.dart';
import 'package:virya/features/social/presentation/widgets/circle_actions.dart';

void main() {
  testWidgets('showCode menampilkan QrImageView dan opsi salin/bagikan', (
    tester,
  ) async {
    const sampleCode = 'virya-circle:invite:v1:testpayload';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed:
                      () => showCode(context, 'Undangan Siap', sampleCode),
                  child: const Text('Buka'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();

    expect(find.text('Undangan Siap'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('Salin'), findsOneWidget);
    expect(find.text('Bagikan'), findsOneWidget);

    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsNothing);
  });

  testWidgets('SocialScreen menampilkan icon scanner QR di masthead', (
    tester,
  ) async {
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
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    container.dispose();
  });
}
