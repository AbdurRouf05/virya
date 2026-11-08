import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/data/demo_data.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/domain/share_options.dart';
import 'package:virya/features/share/templates/share_card.dart';

import 'share_fixture.dart';

Future<ui.Image> _render(
  WidgetTester tester,
  ShareData data,
  CardTemplate t,
  ShareOptions opts,
) async {
  final key = GlobalKey();
  await tester.pumpWidget(MaterialApp(
    home: UnconstrainedBox(
      child: RepaintBoundary(
        key: key,
        child: ShareCard(data: data, template: t, options: opts),
      ),
    ),
  ));
  await tester.pump();
  expect(tester.takeException(), isNull, reason: '${t.name} ${opts.format.name}');
  final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await tester.runAsync(() => b.toImage(pixelRatio: opts.format.pixelRatio)))!;
}

void main() {
  final data = fakeShareData();

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(1400, 2400);
    binding.platformDispatcher.views.first.devicePixelRatio = 1;
  });
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  for (final t in CardTemplate.values) {
    for (final f in CardFormat.values) {
      testWidgets('${t.label} renders ${f.pixelWidth}x${f.pixelHeight}', (tester) async {
        ui.Image? photo;
        if (t == CardTemplate.foto) {
          photo = await tester.runAsync(() {
            final rec = ui.PictureRecorder();
            Canvas(rec).drawRect(const Rect.fromLTWH(0, 0, 64, 48),
                Paint()..color = const Color(0xFF557799));
            return rec.endRecording().toImage(64, 48);
          });
        }
        final img = await _render(tester, data, t, ShareOptions(format: f, photo: photo));
        expect(img.width, f.pixelWidth);
        expect(img.height, f.pixelHeight);
        img.dispose();
      });
    }
  }

  testWidgets('STICKER keeps a transparent background', (tester) async {
    final img = await _render(tester, data, CardTemplate.sticker,
        const ShareOptions(format: CardFormat.square));
    final bytes = (await tester.runAsync(
        () => img.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
    expect(bytes.getUint8(3), 0, reason: 'top-left pixel alpha');
  });

  testWidgets('cards survive empty analysis + no sectors (sample fallback)', (tester) async {
    final samples = demoGravelRide(seconds: 900);
    final d = ShareData.fromParts(
      id: 'x',
      title: 'Lari pagi',
      sport: SportType.roadRunning,
      start: DateTime(2026, 1, 1),
      samples: samples,
      analysis: const ActivityAnalysis(
        sport: SportType.roadRunning,
        distanceM: 0,
        movingTimeS: 0,
        elapsedTimeS: 0,
        elevationGainM: 0,
        elevationLossM: 0,
        maxEleM: 0,
        minEleM: 0,
        avgSpeedMps: 0,
        maxSpeedMps: 0,
        series: ActivitySeries.empty,
        minLat: 0,
        minLon: 0,
        maxLat: 0,
        maxLon: 0,
      ),
    );
    expect(d.distanceM, greaterThan(1000));
    expect(d.lat.length, greaterThan(10));
    for (final t in CardTemplate.values) {
      final img = await _render(tester, d, t, const ShareOptions(format: CardFormat.feed));
      expect(img.width, 1080);
      img.dispose();
    }
  });
}
