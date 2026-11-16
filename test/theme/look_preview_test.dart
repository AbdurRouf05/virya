import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/styles/styles.dart';
import 'package:virya/core/widgets/look_preview.dart';

void main() {
  Future<void> pump(WidgetTester tester, UiGaya gaya) => tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: SizedBox(
          width: 140,
          child: LookPreview(
            palette: resolveStyle(styleId: null, gaya: gaya),
          ),
        ),
      ),
    ),
  );

  testWidgets('Tegas: label kapital', (tester) async {
    await pump(tester, UiGaya.tegas);
    expect(find.text('HARI INI'), findsOneWidget);
    expect(find.text('MULAI REKAM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bersih: kapital kalimat', (tester) async {
    await pump(tester, UiGaya.bersih);
    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.text('Mulai rekam'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rasio layar 9:16', (tester) async {
    await pump(tester, UiGaya.bersih);
    final size = tester.getSize(find.byType(LookPreview));
    expect(size.width / size.height, closeTo(180 / 320, 0.01));
  });
}
