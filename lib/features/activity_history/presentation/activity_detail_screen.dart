import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/app/format.dart';
import 'package:stravo/app/integrations.dart';
import 'package:stravo/app/settings.dart';
import 'package:stravo/app/sport_ui.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/data/activity_repository.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/widgets/field_kit.dart';
import 'package:stravo/features/activity_history/presentation/detail_sections.dart';
import 'package:stravo/features/activity_history/presentation/edit_activity_sheet.dart';
import 'package:stravo/features/profile/data/gear_providers.dart';
import 'package:stravo/features/settings/data/data_actions.dart';

enum MapColorMode {
  speed('KECEPATAN'),
  grade('TANJAKAN'),
  surface('PERMUKAAN');

  final String label;
  const MapColorMode(this.label);
}

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

  void _push(Widget w) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => w));

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
          body: '"${b.activity.title}" beserta titik GPS & fotonya akan '
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
          loading: () => const _Loading(),
          error: (e, _) => _Message('Gagal membaca catatan', '$e'),
          data: (b) => b == null
              ? const _Message('Tidak ditemukan', 'Aktivitas sudah dihapus.')
              : _body(b),
        ),
      ),
    );
  }

  Widget _body(ActivityBundle b) {
    final fmt = ref.watch(fmtProvider);
    final integ = ref.watch(integrationsProvider);
    final a = b.analysis;
    final act = b.activity;
    final sport = b.sport;
    final s = a.series;
    final sec = SectionCounter();
    final gear = (ref.watch(allGearsProvider).valueOrNull ?? const <Gear>[])
        .where((g) => g.id == act.gearId)
        .firstOrNull;

    // Map points: prefer analysis series (down-sampled), else raw samples.
    final List<(double, double)> pts;
    final List<double>? values;
    if (s.length >= 2) {
      pts = [for (var i = 0; i < s.length; i++) (s.lat[i], s.lon[i])];
      values = switch (_mode) {
        MapColorMode.speed => s.speedMps,
        MapColorMode.grade => s.gradePct,
        MapColorMode.surface => [for (final x in s.surface) x.index.toDouble()],
      };
    } else {
      pts = downsample([for (final x in b.samples) (x.lat, x.lon)], 600);
      values = null;
    }

    double xKm(double m) => fmt.distanceValue(m);
    String fx(double m) {
      final v = xKm(m);
      return v == v.roundToDouble()
          ? v.toStringAsFixed(0)
          : v.toStringAsFixed(1);
    }

    final hasHr = s.heartRate.any((h) => h != null);
    final (avgV, avgU) = fmt.speedOrPace(a.avgSpeedMps, sport);

    return CustomScrollView(slivers: [
      SliverAppBar(
        pinned: true,
        backgroundColor: FN.paper,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(Fmt.dateStamp(act.startTime)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) => _menu(v, b),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('UBAH CATATAN')),
              PopupMenuItem(value: 'gpx', child: Text('EKSPOR GPX')),
              PopupMenuItem(value: 'tcx', child: Text('EKSPOR TCX')),
              PopupMenuItem(
                  value: 'delete',
                  child: Text('HAPUS', style: TextStyle(color: FN.warn))),
            ],
          ),
        ],
      ),

      // Header
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(spacing: 8, runSpacing: 6, children: [
                StampChip(text: sport.label, icon: sport.icon, selected: true),
                if (gear != null) StampChip(text: gear.name),
                if (act.source == 'imported') const StampChip(text: 'IMPOR'),
              ]),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => showEditActivitySheet(context, act),
                child: Text(act.title.toUpperCase(),
                    style: const TextStyle(
                        fontFamily: FN.display,
                        fontSize: 38,
                        height: 1.0,
                        color: FN.ink)),
              ),
              if ((act.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(act.description!,
                    style: const TextStyle(
                        fontFamily: FN.sans,
                        fontSize: 14.5,
                        height: 1.45,
                        color: FN.inkSoft)),
              ],
            ],
          ),
        ),
      ),

      // Map
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                  border: Border.all(color: FN.ink, width: 1.5)),
              child: ClipRect(
                child: integ.routeMap(
                    points: pts,
                    values: values,
                    colorMode: values == null ? 'plain' : _mode.name),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              for (final m in MapColorMode.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: StampChip(
                    text: m.label,
                    fontSize: 10,
                    selected: _mode == m,
                    onTap: () => setState(() => _mode = m),
                  ),
                ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: InkButton(
                  label: 'Bagikan',
                  icon: Icons.ios_share,
                  style: InkButtonStyle.primary,
                  expand: true,
                  onPressed: () => _push(integ.shareStudio(_id)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkButton(
                  label: 'Flyover 3D',
                  icon: Icons.threed_rotation,
                  expand: true,
                  onPressed: () => _push(integ.flyover(_id)),
                ),
              ),
            ]),
          ]),
        ),
      ),

      // 01 Summary
      SliverToBoxAdapter(
        child: SectionHeader(
          number: sec.next(),
          title: 'Ringkasan',
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StatGrid(children: [
            StatBlock(
                label: 'Jarak',
                value: fmt.distance(a.distanceM),
                unit: fmt.distUnit,
                size: 46),
            StatBlock(
                label: 'Waktu bergerak',
                value: Fmt.duration(a.movingTimeS),
                size: 46),
            StatBlock(
                label: 'Tanjakan',
                value: fmt.elevation(a.elevationGainM),
                unit: fmt.eleUnit,
                size: 34),
            StatBlock(
                label: sport.isCycling ? 'Kec. rata-rata' : 'Tempo rata-rata',
                value: avgV,
                unit: avgU,
                size: 34),
            StatBlock(
                label: 'Waktu total',
                value: Fmt.duration(a.elapsedTimeS),
                size: 24),
            StatBlock(
                label: sport.isCycling ? 'Kec. maks' : 'Tempo terbaik',
                value: fmt.speedOrPace(a.maxSpeedMps, sport).$1,
                unit: fmt.speedOrPace(a.maxSpeedMps, sport).$2,
                size: 24),
            if (a.avgGapMps != null)
              StatBlock(
                  label: 'GAP',
                  value: fmt.pace(a.avgGapMps!),
                  unit: fmt.paceUnit,
                  size: 24),
            StatBlock(
                label: 'Elev maks',
                value: fmt.elevation(a.maxEleM),
                unit: fmt.eleUnit,
                size: 24),
            if (a.avgHeartRate != null)
              StatBlock(
                  label: 'HR rata / maks',
                  value: '${a.avgHeartRate}/${a.maxHeartRate ?? '–'}',
                  unit: 'bpm',
                  size: 24),
            if (a.avgCadence != null)
              StatBlock(
                  label: 'Kadens',
                  value: '${a.avgCadence}',
                  unit: sport.isCycling ? 'rpm' : 'spm',
                  size: 24),
            StatBlock(
                label: 'Upaya relatif',
                value: a.relativeEffort.round().toString(),
                size: 24),
            if (a.gritScore > 0)
              StatBlock(
                  label: 'Grit',
                  value: a.gritScore.round().toString(),
                  unit: '/100',
                  size: 24),
          ]),
        ),
      ),

      // Elevation
      if (s.length >= 2) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            number: sec.next(),
            title: 'Profil elevasi',
            trailing: Text(
                '▲${fmt.elevation(a.elevationGainM)} ▼${fmt.elevation(a.elevationLossM)} ${fmt.eleUnit}',
                style: FN.label(size: 10, color: FN.ink)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              ElevationProfile(
                distanceM: s.distanceM,
                ele: s.ele,
                gradePct: s.gradePct,
                marks: [
                  for (final c in a.climbs)
                    if (c.category != ClimbCategory.flat)
                      ChartMark(c.startDistanceM, c.endDistanceM,
                          climbCategoryShort(c.category) == 'HC'
                              ? 'HC'
                              : 'KAT ${climbCategoryShort(c.category)}',
                          color: FN.grade(c.avgGradePct)),
                ],
                formatX: fx,
                formatY: (m) => fmt.elevation(m),
              ),
              const SizedBox(height: 10),
              const GradeLegend(),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionHeader(
            number: sec.next(),
            title: sport.isCycling ? 'Kecepatan' : 'Tempo',
            trailing: Text('$avgV ${avgU.toLowerCase()}',
                style: FN.label(size: 10, color: FN.ink)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: sport.isCycling
                ? InkLineChart(
                    x: s.distanceM,
                    y: [for (final v in s.speedMps) fmt.speedValue(v)],
                    average: fmt.speedValue(a.avgSpeedMps),
                    formatY: (v) => v.toStringAsFixed(0),
                    formatX: fx,
                    color: FN.ink,
                  )
                : InkLineChart(
                    x: s.distanceM,
                    y: [for (final v in s.speedMps) v < 0.5 ? null : v],
                    average: a.avgSpeedMps,
                    formatY: fmt.pace,
                    formatX: fx,
                    clampMin: 1.2,
                  ),
          ),
        ),
        if (hasHr) ...[
          SliverToBoxAdapter(
            child: SectionHeader(
              number: sec.next(),
              title: 'Detak jantung',
              trailing: Text('${a.avgHeartRate ?? '–'} bpm',
                  style: FN.label(size: 10, color: FN.ink)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkLineChart(
                x: s.distanceM,
                y: [for (final h in s.heartRate) h?.toDouble()],
                color: FN.signal,
                average: a.avgHeartRate?.toDouble(),
                formatY: (v) => v.round().toString(),
                formatX: fx,
                height: 120,
              ),
            ),
          ),
        ],
      ],

      // Splits
      if (a.splits.isNotEmpty) ...[
        SliverToBoxAdapter(
            child: SectionHeader(
                number: sec.next(), title: 'Split per ${fmt.distUnit}')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SplitsTable(splits: a.splits, sport: sport, fmt: fmt),
          ),
        ),
      ],

      // Climbs
      if (a.climbs.any((c) => c.category != ClimbCategory.flat)) ...[
        SliverToBoxAdapter(
            child: SectionHeader(number: sec.next(), title: 'Tanjakan')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.list(children: [
            for (final (i, c) in a.climbs
                .where((c) => c.category != ClimbCategory.flat)
                .indexed)
              ClimbCard(climb: c, index: i, fmt: fmt),
          ]),
        ),
      ],

      // Gravel sectors
      if (a.gravelSectors.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            number: sec.next(),
            title: 'Sektor gravel',
            trailing: Text('${a.gravelSectors.length} SEKTOR',
                style: FN.label(size: 10, color: FN.ink)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.list(children: [
            for (final g in a.gravelSectors)
              GravelSectorCard(sector: g, fmt: fmt),
          ]),
        ),
      ],

      // Surface
      if (a.surfaceDistanceM.values.any((v) => v > 0)) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            number: sec.next(),
            title: 'Permukaan',
            trailing: Text('GRAVEL ${a.gravelPct.round()}%',
                style: FN.label(size: 10, color: FN.ink)
                    .copyWith(fontWeight: FontWeight.w700)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SurfaceBar(
                  distanceM: a.surfaceDistanceM,
                  legend: true,
                  formatDistance: (m) =>
                      '${fmt.distance(m, decimals: 1)} ${fmt.distUnit.toLowerCase()}',
                ),
                const SizedBox(height: 14),
                _GritPanel(score: a.gritScore),
              ],
            ),
          ),
        ),
      ],

      // Best efforts
      if (a.bestEfforts.isNotEmpty) ...[
        SliverToBoxAdapter(
            child: SectionHeader(number: sec.next(), title: 'Upaya terbaik')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BestEffortsTable(
                efforts: a.bestEfforts, sport: sport, fmt: fmt),
          ),
        ),
      ],

      // HR zones
      if (a.hrZoneSeconds.values.any((v) => v > 0)) ...[
        SliverToBoxAdapter(
            child:
                SectionHeader(number: sec.next(), title: 'Zona detak jantung')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HrZoneBar(
                zoneSeconds: a.hrZoneSeconds, formatTime: Fmt.duration),
          ),
        ),
      ],

      // Power
      if (sport.isCycling && (a.avgPowerW != null || a.energyKj != null)) ...[
        SliverToBoxAdapter(
            child: SectionHeader(number: sec.next(), title: 'Daya & energi')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StatGrid(columns: 3, children: [
              StatBlock(
                  label: 'Daya rata²',
                  value: a.avgPowerW?.round().toString() ?? '–',
                  unit: 'W',
                  size: 28),
              StatBlock(
                  label: 'Energi',
                  value: a.energyKj == null ? '–' : Fmt.number(a.energyKj!),
                  unit: 'kJ',
                  size: 28),
              StatBlock(
                  label: 'Kalori ≈',
                  value: a.energyKj == null
                      ? '–'
                      // ~24% gross efficiency: kJ mech ≈ kcal burned
                      : Fmt.number(a.energyKj! / 4.184 / 0.24),
                  unit: 'kcal',
                  size: 28),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(
                'Estimasi dari model fisika (berat, kemiringan, hambatan '
                'udara & permukaan) — tanpa power meter.',
                style: FN.label(size: 9.5)),
          ),
        ),
      ],

      // Photos
      if (b.photos.isNotEmpty) ...[
        SliverToBoxAdapter(
            child: SectionHeader(
                number: sec.next(), title: 'Foto (${b.photos.length})')),
        SliverToBoxAdapter(child: PhotoStrip(photos: b.photos, fmt: fmt)),
      ],

      // Footer
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const InkRule(),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: InkButton(
                    label: 'Ekspor GPX',
                    icon: Icons.download,
                    expand: true,
                    onPressed: () => _menu('gpx', b),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkButton(
                    label: 'Ekspor TCX',
                    icon: Icons.download,
                    expand: true,
                    onPressed: () => _menu('tcx', b),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              InkButton(
                label: 'Hapus aktivitas',
                icon: Icons.delete_outline,
                style: InkButtonStyle.danger,
                expand: true,
                onPressed: () => _menu('delete', b),
              ),
              const SizedBox(height: 16),
              Text(
                'ID ${act.id.substring(0, 8)} · ${b.samples.length} TITIK · ${act.source.toUpperCase()}',
                textAlign: TextAlign.center,
                style: FN.label(size: 9),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

class _GritPanel extends StatelessWidget {
  final double score;
  const _GritPanel({required this.score});

  @override
  Widget build(BuildContext context) {
    final s = score.clamp(0, 100).toDouble();
    final word = s >= 75
        ? 'BRUTAL'
        : s >= 50
            ? 'KERAS'
            : s >= 25
                ? 'SEDANG'
                : 'RINGAN';
    return InkBox(
      color: FN.paperDeep,
      child: Row(children: [
        Text(s.round().toString(), style: FN.bigNumber(48, color: FN.signal)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GRIT SCORE · $word',
                  style: FN.label(size: 11, color: FN.ink)
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Gabungan porsi gravel, kekasaran getaran, dan tanjakan di '
                'permukaan lepas. 0 = aspal mulus, 100 = neraka makadam.',
                style: FN.label(size: 9.5),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (_, c) => Stack(children: [
                  Container(height: 6, color: FN.paperLine),
                  Container(
                      height: 6, width: c.maxWidth * s / 100, color: FN.ink),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('MEMBACA CATATAN…', style: FN.label(size: 12, color: FN.ink)),
            const SizedBox(height: 12),
            const SizedBox(width: 160, child: LinearProgressIndicator()),
            const SizedBox(height: 8),
            Text('menganalisis tanjakan, sektor & split',
                style: FN.label(size: 9.5)),
          ]),
        ),
      );
}

class _Message extends StatelessWidget {
  final String title;
  final String body;
  const _Message(this.title, this.body);
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 24),
              Text(title.toUpperCase(),
                  style: const TextStyle(
                      fontFamily: FN.display, fontSize: 40, color: FN.ink)),
              const SizedBox(height: 8),
              Text(body),
            ],
          ),
        ),
      );
}
