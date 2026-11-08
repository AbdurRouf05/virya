import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/data/activity_repository.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/activity_history/application/activity_map_data.dart';
import 'package:virya/features/activity_history/presentation/detail_sections.dart';
import 'package:virya/features/activity_history/presentation/edit_activity_sheet.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_charts.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_footer.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_grit_panel.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_header.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_map.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_menu.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_power.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_status.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_strength.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_summary.dart';
import 'package:virya/features/profile/data/gear_providers.dart';
import 'package:virya/features/settings/data/data_actions.dart';

export 'package:virya/features/activity_history/application/activity_map_data.dart'
    show MapColorMode;

/// Full activity "notebook spread".
class ActivityDetailScreen extends ConsumerStatefulWidget {
  final String activityId;
  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  ConsumerState<ActivityDetailScreen> createState() =>
      _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  MapColorMode _mode = MapColorMode.speed;

  String get _id => widget.activityId;

  void _push(Widget w) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));

  Future<void> _menu(String action, ActivityBundle b) async {
    switch (action) {
      case 'edit':
        await showEditActivitySheet(context, b.activity);
      case 'gpx':
        await DataActions.exportActivity(context, ref, _id, tcx: false);
      case 'tcx':
        await DataActions.exportActivity(context, ref, _id, tcx: true);
      case 'delete':
        final ok = await DataActions.confirm(
          context,
          title: 'Hapus aktivitas?',
          body: b.sport.isGps
              ? '"${b.activity.title}" beserta titik GPS & fotonya akan '
                    'dihapus permanen.'
              : '"${b.activity.title}" beserta semua set latihannya akan '
                    'dihapus permanen.',
          action: 'HAPUS',
          danger: true,
        );
        if (!ok || !mounted) return;
        await ref.read(databaseProvider).activitiesDao.deleteActivity(_id);
        ref.invalidate(activityBundleProvider(_id));
        if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(activityBundleProvider(_id));
    return Scaffold(
      body: PaperBackground(
        child: async.when(
          loading: () => const ActivityDetailStatus.loading(),
          error: (e, _) =>
              ActivityDetailStatus.message('Gagal membaca catatan', '$e'),
          data: (b) => b == null
              ? const ActivityDetailStatus.message(
                  'Tidak ditemukan',
                  'Aktivitas sudah dihapus.',
                )
              : _body(b),
        ),
      ),
    );
  }

  /// Numbered section header + horizontally padded content, as two slivers.
  List<Widget> _section(
    String number,
    String title,
    Widget child, {
    Widget? trailing,
    bool pad = true,
  }) => [
    SliverToBoxAdapter(
      child: SectionHeader(number: number, title: title, trailing: trailing),
    ),
    SliverToBoxAdapter(
      child: pad
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: child,
            )
          : child,
    ),
  ];

  Widget _body(ActivityBundle b) {
    final fmt = ref.watch(fmtProvider);
    final integ = ref.watch(integrationsProvider);
    final a = b.analysis;
    final act = b.activity;
    final sport = b.sport;
    final sec = SectionCounter();
    final gear = (ref.watch(allGearsProvider).valueOrNull ?? const <Gear>[])
        .where((g) => g.id == act.gearId)
        .firstOrNull;
    if (!sport.isGps) {
      return ActivityDetailStrength(
        activity: act,
        sport: sport,
        gear: gear,
        content: integ.gymSessionDetail(_id),
        onEdit: () => showEditActivitySheet(context, act),
        onMenu: (v) => _menu(v, b),
      );
    }
    final map = activityMapData(b, _mode);
    final hasHr = a.series.heartRate.any((h) => h != null);
    final climbs = a.climbs
        .where((c) => c.category != ClimbCategory.flat)
        .toList();
    final trailStyle = FN.label(size: 10, color: FN.ink);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: FN.paper,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(Fmt.dateStamp(act.startTime)),
          actions: [ActivityDetailMenu(onSelected: (v) => _menu(v, b))],
        ),
        SliverToBoxAdapter(
          child: ActivityDetailHeader(
            activity: act,
            sport: sport,
            gear: gear,
            onEdit: () => showEditActivitySheet(context, act),
          ),
        ),
        SliverToBoxAdapter(
          child: ActivityDetailMap(
            map: integ.routeMap(
              points: map.points,
              values: map.values,
              colorMode: map.values == null ? 'plain' : _mode.name,
            ),
            mode: _mode,
            onModeChanged: (m) => setState(() => _mode = m),
            onShare: () => _push(integ.shareStudio(_id)),
            onFlyover: () => _push(integ.flyover(_id)),
          ),
        ),
        ..._section(
          sec.next(),
          'Ringkasan',
          ActivityDetailSummary(analysis: a, sport: sport, fmt: fmt),
          pad: false,
        ),
        if (a.series.length >= 2)
          SliverToBoxAdapter(
            child: ActivityDetailCharts(
              analysis: a,
              sport: sport,
              fmt: fmt,
              elevationNumber: sec.next(),
              speedNumber: sec.next(),
              hrNumber: hasHr ? sec.next() : null,
            ),
          ),
        if (a.splits.isNotEmpty)
          ..._section(
            sec.next(),
            'Split per ${fmt.distUnit}',
            SplitsTable(splits: a.splits, sport: sport, fmt: fmt),
          ),
        if (climbs.isNotEmpty)
          ..._section(
            sec.next(),
            'Tanjakan',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, c) in climbs.indexed)
                  ClimbCard(climb: c, index: i, fmt: fmt),
              ],
            ),
          ),
        if (a.gravelSectors.isNotEmpty)
          ..._section(
            sec.next(),
            'Sektor gravel',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final g in a.gravelSectors)
                  GravelSectorCard(sector: g, fmt: fmt),
              ],
            ),
            trailing: Text(
              '${a.gravelSectors.length} SEKTOR',
              style: trailStyle,
            ),
          ),
        if (a.surfaceDistanceM.values.any((v) => v > 0))
          ..._section(
            sec.next(),
            'Permukaan',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SurfaceBar(
                  distanceM: a.surfaceDistanceM,
                  legend: true,
                  formatDistance: (m) =>
                      '${fmt.distance(m, decimals: 1)} ${fmt.distUnit.toLowerCase()}',
                ),
                const SizedBox(height: 14),
                ActivityDetailGritPanel(score: a.gritScore),
              ],
            ),
            trailing: Text(
              'GRAVEL ${a.gravelPct.round()}%',
              style: trailStyle.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        if (a.bestEfforts.isNotEmpty)
          ..._section(
            sec.next(),
            'Upaya terbaik',
            BestEffortsTable(efforts: a.bestEfforts, sport: sport, fmt: fmt),
          ),
        if (b.samples.length >= 2)
          ..._section(sec.next(), 'Segmen', integ.activitySegments(_id)),
        if (a.hrZoneSeconds.values.any((v) => v > 0))
          ..._section(
            sec.next(),
            'Zona detak jantung',
            HrZoneBar(zoneSeconds: a.hrZoneSeconds, formatTime: Fmt.duration),
          ),
        if (sport.isCycling && (a.avgPowerW != null || a.energyKj != null))
          ..._section(
            sec.next(),
            'Daya & energi',
            ActivityDetailPower(analysis: a),
            pad: false,
          ),
        if (b.photos.isNotEmpty)
          ..._section(
            sec.next(),
            'Foto (${b.photos.length})',
            PhotoStrip(photos: b.photos, fmt: fmt),
            pad: false,
          ),
        SliverToBoxAdapter(
          child: ActivityDetailFooter(
            onExportGpx: () => _menu('gpx', b),
            onExportTcx: () => _menu('tcx', b),
            onDelete: () => _menu('delete', b),
            caption:
                'ID ${act.id.substring(0, 8)} · ${b.samples.length} TITIK · ${act.source.toUpperCase()}',
          ),
        ),
      ],
    );
  }
}
