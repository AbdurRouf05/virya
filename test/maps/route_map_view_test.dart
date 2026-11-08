import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/data/demo_data.dart';
import 'package:virya/core/offline_maps/local_tile_server.dart';
import 'package:virya/core/offline_maps/map_pack_repository.dart';
import 'package:virya/features/maps/presentation/map_packs_screen.dart';
import 'package:virya/features/maps/widgets/route_map_view.dart';
import 'package:virya/features/maps/widgets/route_preview.dart';

void main() {
  final ride = demoGravelRide(seconds: 1200);
  final pts = [for (final s in ride) (s.lat, s.lon)];

  testWidgets('RouteMapView falls back to painter without WebView',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 300,
        height: 200,
        child: RouteMapView(
          points: pts,
          values: [for (final s in ride) s.surface.index.toDouble()],
          colorMode: RouteColorMode.surface,
          currentPosition: pts.last,
          bearing: 45,
        ),
      ),
    ));
    expect(find.byType(RoutePreview), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Live updates and empty input don't throw.
    await tester.pumpWidget(MaterialApp(
      home: RouteMapView(points: pts.sublist(0, 10), live: true),
    ));
    await tester.pumpWidget(const MaterialApp(home: RouteMapView(points: [])));
    expect(tester.takeException(), isNull);
  });

  test('routeColors per mode', () {
    expect(routeColors(null, RouteColorMode.speed), isNull);
    expect(routeColors([1, 2], RouteColorMode.plain), isNull);
    final surf = routeColors(
        [SurfaceType.dirt.index.toDouble(), double.nan], RouteColorMode.surface)!;
    expect(surf.length, 2);
    expect(routeColors([0, 4, 9, 20], RouteColorMode.grade)!.length, 4);
    final sp = routeColors([for (var i = 0; i < 50; i++) i.toDouble()], RouteColorMode.speed)!;
    expect(sp.first, isNot(sp.last));
  });

  testWidgets('MapPacksScreen renders empty state + instructions',
      (tester) async {
    final tmp = Directory.systemTemp.createTempSync('virya_ui_');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final settings = <String, String>{};
    final repo = MapPackRepository(
      getSetting: (k) async => settings[k],
      setSetting: (k, v) async => settings[k] = v,
      mapsDir: () async => tmp,
      server: LocalTileServer(packsDir: () async => tmp),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [mapPackRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: MapPacksScreen()),
    ));
    for (var i = 0; i < 10 && find.byType(CircularProgressIndicator).evaluate().isNotEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
    }
    expect(find.text('PETA OFFLINE'), findsOneWidget);
    expect(find.textContaining('Belum ada paket'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('IMPOR FILE .PMTILES'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.scrollUntilVisible(find.text('CARA MENDAPATKAN PAKET'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('pmtiles extract'), findsOneWidget);
  });
}
