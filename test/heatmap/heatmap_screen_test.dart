import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/features/heatmap/application/heatmap_providers.dart';
import 'package:virya/features/heatmap/domain/heatmap_builder.dart';
import 'package:virya/features/heatmap/presentation/heatmap_screen.dart';

class _FakeMap extends PlaceholderIntegrations {
  const _FakeMap();

  @override
  Widget heatmapView({required List<(double, double, double)> points}) =>
      Text('TITIK ${points.length}');
}

const _empty = HeatmapResult(points: [], trackCount: 0, maxCount: 0);
const _one = HeatmapResult(
  points: [(-6.9, 107.6, 1.0), (-6.8, 107.6, 0.5)],
  trackCount: 12,
  maxCount: 7,
);

Future<void> pumpScreen(
  WidgetTester tester,
  Future<HeatmapResult> Function(HeatmapFilter) load,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        integrationsProvider.overrideWithValue(const _FakeMap()),
        heatmapProvider.overrideWith((ref, filter) => load(filter)),
      ],
      child: MaterialApp(
        theme: FieldNotesTheme.paper,
        home: const HeatmapScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('menampilkan titik dan ringkasan', (tester) async {
    await pumpScreen(tester, (_) async => _one);
    expect(find.text('TITIK 2'), findsOneWidget);
    expect(find.textContaining('12 AKTIVITAS'), findsOneWidget);
    expect(find.textContaining('7×'), findsOneWidget);
    expect(find.text('BELUM ADA JALUR'), findsNothing);
  });

  testWidgets('keadaan kosong saat belum ada jalur', (tester) async {
    await pumpScreen(tester, (_) async => _empty);
    expect(find.text('BELUM ADA JALUR'), findsOneWidget);
    expect(find.textContaining('aktivitas GPS'), findsOneWidget);
  });

  testWidgets('filter memuat kategori yang dipilih', (tester) async {
    final asked = <HeatmapFilter>[];
    await pumpScreen(tester, (f) async {
      asked.add(f);
      return f == HeatmapFilter.running ? _empty : _one;
    });
    expect(find.text('GYM'), findsNothing);

    await tester.tap(find.text('LARI'));
    await tester.pump();
    await tester.pump();
    expect(asked, [HeatmapFilter.all, HeatmapFilter.running]);
    expect(find.textContaining('Rekam aktivitas lari'), findsOneWidget);
    expect(find.text('TITIK 0'), findsOneWidget);
  });

  testWidgets('gagal menghitung menawarkan coba lagi', (tester) async {
    await pumpScreen(tester, (_) async => throw StateError('rusak'));
    expect(find.text('HEATMAP GAGAL DIHITUNG'), findsOneWidget);
    expect(find.text('COBA LAGI'), findsOneWidget);
  });
}
