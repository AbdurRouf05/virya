import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/core/analytics/activity_analyzer.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/data/demo_data.dart';
import 'package:virya/core/offline_maps/map_pack.dart';
import 'package:virya/core/offline_maps/map_pack_repository.dart';
import 'package:virya/features/activity_history/presentation/activity_detail_screen.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_best_efforts.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_climb_card.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_gravel_sector_card.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_grit_panel.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_map.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_power.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_splits_table.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_summary.dart';
import 'package:virya/features/maps/domain/flyover_plan.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_controls.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_hud.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_top_bar.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_active_card.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_pack_tile.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_section_title.dart';
import 'package:virya/features/share/domain/share_options.dart';

Widget _host(Widget child, {double width = 360, double height = 800}) => MaterialApp(
      theme: FieldNotesTheme.paper,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );

void main() {
  const fmt = Fmt(Units.metric);
  final analysis = const ActivityAnalyzer().analyze(
    demoGravelRide(seconds: 1200),
    SportType.gravelCycling,
  );

  group('Activity History UI/UX Audit Tests', () {
    testWidgets('ActivityDetailSummary renders stat grid cleanly on narrow 320px screen',
        (tester) async {
      await tester.pumpWidget(_host(
        ActivityDetailSummary(
          analysis: analysis,
          sport: SportType.gravelCycling,
          fmt: fmt,
        ),
        width: 320,
      ));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('JARAK'), findsOneWidget);
      expect(find.textContaining('WAKTU BERGERAK'), findsOneWidget);
    });

    testWidgets('ActivityDetailGritPanel renders score and prose without overflow',
        (tester) async {
      await tester.pumpWidget(_host(
        const ActivityDetailGritPanel(score: 88),
        width: 320,
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('88'), findsOneWidget);
      expect(find.textContaining('GRIT SCORE · BRUTAL'), findsOneWidget);
    });

    testWidgets('ActivityDetailPower renders 3-column stats on narrow 320px constraint',
        (tester) async {
      await tester.pumpWidget(_host(
        ActivityDetailPower(analysis: analysis),
        width: 320,
      ));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('DAYA RATA'), findsOneWidget);
      expect(find.textContaining('ENERGI'), findsOneWidget);
    });

    testWidgets('ClimbCard renders with category badge spacing and long distance range',
        (tester) async {
      const climb = Climb(
        startDistanceM: 12345.6,
        endDistanceM: 18765.4,
        gainM: 450,
        avgGradePct: 7.2,
        maxGradePct: 14.5,
        category: ClimbCategory.cat2,
        durationS: 1800,
        vam: 900,
      );
      await tester.pumpWidget(_host(
        const ClimbCard(climb: climb, index: 0, fmt: fmt),
        width: 320,
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('KAT'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.textContaining('TANJAKAN 1'), findsOneWidget);
    });

    testWidgets('GravelSectorCard renders long sector name and distance cleanly',
        (tester) async {
      const sector = GravelSector(
        number: 1,
        name: 'Sektor Makadam Sangat Panjang Berbatu Kasar Tanjakan Terjal Sekali',
        startDistanceM: 5200,
        endDistanceM: 12800,
        roughness: 4.8,
        avgGradePct: 6.5,
        dominantSurface: SurfaceType.roughGravel,
        stars: 4,
      );
      await tester.pumpWidget(_host(
        const GravelSectorCard(sector: sector, fmt: fmt),
        width: 320,
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('SEKTOR'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(
        find.text('Sektor Makadam Sangat Panjang Berbatu Kasar Tanjakan Terjal Sekali'),
        findsOneWidget,
      );
    });

    testWidgets('ActivityDetailMap wraps color mode chips on narrow 320px screen',
        (tester) async {
      await tester.pumpWidget(_host(
        ActivityDetailMap(
          map: Container(color: Colors.grey),
          mode: MapColorMode.speed,
          onModeChanged: (_) {},
          onShare: () {},
          onFlyover: () {},
        ),
        width: 320,
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('KECEPATAN'), findsOneWidget);
      expect(find.text('TANJAKAN'), findsOneWidget);
      expect(find.text('PERMUKAAN'), findsOneWidget);
    });

    testWidgets('BestEffortsTable and SplitsTable render on narrow screens',
        (tester) async {
      if (analysis.bestEfforts.isNotEmpty) {
        await tester.pumpWidget(_host(
          BestEffortsTable(
            efforts: analysis.bestEfforts,
            sport: SportType.gravelCycling,
            fmt: fmt,
          ),
          width: 320,
        ));
        expect(tester.takeException(), isNull);
      }

      if (analysis.splits.isNotEmpty) {
        await tester.pumpWidget(_host(
          SplitsTable(
            splits: analysis.splits,
            sport: SportType.gravelCycling,
            fmt: fmt,
          ),
          width: 320,
        ));
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Maps Flyover UI/UX Audit Tests', () {
    testWidgets('FlyoverHud renders keyframe metrics on narrow 320px screen',
        (tester) async {
      const k = FlyKeyframe(
        u: 0.5,
        lat: -6.9,
        lon: 107.6,
        bearing: 45,
        pitch: 60,
        zoom: 15,
        overview: 0,
        progress: 0.5,
        distM: 25430.0,
        eleM: 1245.8,
        speedKmh: 34.6,
        gradePct: 8.4,
        elapsedS: 3672.0,
      );

      await tester.pumpWidget(_host(
        Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16),
          child: const FlyoverHud(k: k, pace: false),
        ),
        width: 320,
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('JARAK'), findsOneWidget);
      expect(find.text('ELEVASI'), findsOneWidget);
      expect(find.text('KECEPATAN'), findsOneWidget);
      expect(find.text('TANJAKAN'), findsOneWidget);
    });

    testWidgets('FlyoverTopBar handles extremely long activity title without overflow',
        (tester) async {
      await tester.pumpWidget(_host(
        FlyoverTopBar(
          title: 'Gravel Epic Trans-Java Challenge Solo Unsupported 2026 Edition Final Stretch',
          is3d: true,
          busy: false,
          onToggle3d: () {},
        ),
        width: 320,
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('VIRYA // FLYOVER'), findsOneWidget);
      expect(find.text('3D'), findsOneWidget);
    });

    testWidgets('FlyoverControls renders on narrow 320px phone without overflow',
        (tester) async {
      await tester.pumpWidget(_host(
        FlyoverControls(
          u: 0.4,
          playing: false,
          speed: 2.0,
          speeds: const [1.0, 2.0, 4.0, 8.0],
          exportLength: RecapLength.auto,
          exportHd: false,
          videoW: 720,
          videoH: 1280,
          disabled: false,
          onSeek: (_) {},
          onTogglePlay: () {},
          onSpeed: (_) {},
          onLength: (_) {},
          onHd: (_) {},
          onExport: () {},
        ),
        width: 320,
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('EKSPOR 720×1280'), findsOneWidget);
      expect(find.text('2×'), findsOneWidget);
    });

    testWidgets('MapPacksActiveCard, Tile, and SectionTitle render cleanly',
        (tester) async {
      const state = MapPacksState(
        packs: [
          MapPack(
            fileName: 'jawa_barat_osm_2026_vector_extract.pmtiles',
            type: MapPackType.basemap,
            sizeBytes: 157286400,
            path: '/fake/path.pmtiles',
          ),
        ],
        activeBasemap: 'jawa_barat_osm_2026_vector_extract.pmtiles',
        activeDem: null,
        onlineFallback: true,
      );

      await tester.pumpWidget(_host(
        Column(
          children: [
            const MapPacksActiveCard(state: state),
            const SizedBox(height: 12),
            const MapPacksSectionTitle(
              'PAKET PETA OFFLINE TERPASANG WILAYAH JAWA',
              trailing: '1',
            ),
            MapPacksPackTile(
              pack: state.packs.first,
              active: true,
              onActivate: () {},
              onDelete: () {},
            ),
          ],
        ),
        width: 320,
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('BASEMAP'), findsWidgets);
      expect(find.text('AKTIF ✓'), findsOneWidget);
    });
  });
}
