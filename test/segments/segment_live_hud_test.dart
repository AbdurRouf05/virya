import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/features/segments/data/live_segment_feed.dart';
import 'package:virya/features/segments/domain/live_segment_board.dart';
import 'package:virya/features/segments/domain/live_segment_tracker.dart';
import 'package:virya/features/segments/presentation/widgets/segment_live_hud.dart';

class _FixedFeed extends LiveSegmentFeed {
  final LiveSegmentView? fixed;
  _FixedFeed(this.fixed);

  @override
  LiveSegmentView? build() => fixed;
}

Future<void> _pump(WidgetTester tester, LiveSegmentView? view) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [
          liveSegmentFeedProvider.overrideWith(() => _FixedFeed(view)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: Column(children: [SegmentLiveHud()])),
        ),
      ),
    );

LiveSegmentView _view(LiveSegmentState s) =>
    LiveSegmentView(id: 'a', name: 'Bukit', state: s, at: DateTime.utc(2026));

void main() {
  testWidgets('kosong saat tidak ada segmen', (tester) async {
    await _pump(tester, null);
    expect(find.text('Bukit'), findsNothing);
    expect(tester.getSize(find.byType(SegmentLiveHud)).height, 0);
  });

  testWidgets('menampilkan jarak saat mendekat', (tester) async {
    await _pump(
      tester,
      _view(
        const LiveSegmentState(
          phase: LiveSegmentPhase.approaching,
          segmentLengthM: 1000,
          distanceToStartM: 212.4,
        ),
      ),
    );
    expect(find.text('SEGMEN MENDEKAT'), findsOneWidget);
    expect(find.text('Bukit'), findsOneWidget);
    expect(find.text('212 M'), findsOneWidget);
  });

  testWidgets('menampilkan selisih ghost saat aktif', (tester) async {
    await _pump(
      tester,
      _view(
        const LiveSegmentState(
          phase: LiveSegmentPhase.active,
          segmentLengthM: 1000,
          progressM: 400,
          elapsedS: 65,
          ghostDeltaS: -3,
        ),
      ),
    );
    expect(find.text('SEGMEN AKTIF'), findsOneWidget);
    expect(find.text('-0:03'), findsOneWidget);
    expect(find.text('GHOST · 1:05'), findsOneWidget);
  });

  testWidgets('upaya pertama menampilkan waktu tanpa ghost', (tester) async {
    await _pump(
      tester,
      _view(
        const LiveSegmentState(
          phase: LiveSegmentPhase.active,
          segmentLengthM: 1000,
          elapsedS: 65,
        ),
      ),
    );
    expect(find.text('1:05'), findsOneWidget);
    expect(find.text('UPAYA PERTAMA'), findsOneWidget);
  });

  testWidgets('menampilkan rekor baru saat selesai', (tester) async {
    await _pump(
      tester,
      _view(
        const LiveSegmentState(
          phase: LiveSegmentPhase.finished,
          segmentLengthM: 1000,
          progressM: 1000,
          elapsedS: 120,
          finalTimeS: 120,
          ghostDeltaS: -7,
          isNewPr: true,
        ),
      ),
    );
    expect(find.text('REKOR BARU'), findsOneWidget);
    expect(find.text('2:00'), findsOneWidget);
    expect(find.text('-0:07 DARI REKOR'), findsOneWidget);
  });
}
