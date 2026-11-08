import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide Split;
import 'package:stravo/app/format.dart';
import 'package:stravo/app/sport_ui.dart';
import 'package:stravo/core/analytics/analysis_models.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/widgets/field_kit.dart';

/// Ledger-style table header cell text.
TextStyle _th() => FN.label(size: 9.5);
TextStyle _td({bool bold = false, Color color = FN.ink}) =>
    FN.label(size: 12, color: color).copyWith(
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        fontFeatures: FN.tabular);

/// Per-km splits with a proportional tempo bar.
class SplitsTable extends StatelessWidget {
  final List<Split> splits;
  final SportType sport;
  final Fmt fmt;
  const SplitsTable(
      {super.key, required this.splits, required this.sport, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final showGap = sport.isRunning && splits.any((s) => s.gapMps != null);
    final showHr = splits.any((s) => s.avgHeartRate != null);
    final speeds = splits.map((s) => s.speedMps).toList();
    final maxS = speeds.fold<double>(0, (a, b) => math.max(a, b));
    final minS = speeds.fold<double>(double.infinity, (a, b) => math.min(a, b));
    final fastest = speeds.indexOf(maxS);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(width: 34, child: Text(fmt.distUnit, style: _th())),
          SizedBox(
              width: 56,
              child: Text(sport.isCycling ? fmt.speedUnit : 'TEMPO',
                  style: _th())),
          const Expanded(child: SizedBox()),
          SizedBox(
              width: 50,
              child: Text('ELEV', style: _th(), textAlign: TextAlign.right)),
          if (showHr)
            SizedBox(
                width: 40,
                child: Text('HR', style: _th(), textAlign: TextAlign.right)),
          if (showGap)
            SizedBox(
                width: 48,
                child: Text('GAP', style: _th(), textAlign: TextAlign.right)),
        ]),
      ),
      const InkRule(),
      for (var i = 0; i < splits.length; i++) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            SizedBox(
                width: 34,
                child: Text('${splits[i].index}',
                    style: _td(color: FN.inkMuted))),
            SizedBox(
              width: 56,
              child: Text(fmt.speedOrPace(splits[i].speedMps, sport).$1,
                  style: _td(
                      bold: i == fastest,
                      color: i == fastest ? FN.signal : FN.ink)),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, c) {
                final range = math.max(maxS - minS, 0.01);
                final f = 0.25 + 0.75 * ((splits[i].speedMps - minS) / range);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 10,
                    width: c.maxWidth * f.clamp(0.05, 1.0),
                    color: i == fastest ? FN.signal : FN.ink,
                  ),
                );
              }),
            ),
            SizedBox(
              width: 50,
              child: Text(
                  '${splits[i].elevationDeltaM >= 0 ? '+' : ''}${fmt.elevation(splits[i].elevationDeltaM)}',
                  textAlign: TextAlign.right,
                  style: _td()),
            ),
            if (showHr)
              SizedBox(
                width: 40,
                child: Text(splits[i].avgHeartRate?.toString() ?? '–',
                    textAlign: TextAlign.right, style: _td()),
              ),
            if (showGap)
              SizedBox(
                width: 48,
                child: Text(
                    splits[i].gapMps == null
                        ? '–'
                        : fmt.pace(splits[i].gapMps!),
                    textAlign: TextAlign.right,
                    style: _td()),
              ),
          ]),
        ),
        if (i < splits.length - 1)
          const InkRule(dashed: true, color: FN.paperLine),
      ],
    ]);
  }
}

/// Climb card: grade-colored category block + figures.
class ClimbCard extends StatelessWidget {
  final Climb climb;
  final int index;
  final Fmt fmt;
  const ClimbCard(
      {super.key, required this.climb, required this.index, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final c = climb;
    final color = FN.grade(c.avgGradePct);
    final cat = climbCategoryShort(c.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(border: Border.all(color: FN.ink, width: 1)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 64,
              color: color,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('KAT', style: FN.label(size: 8.5, color: FN.paper)),
                  Text(cat, style: FN.bigNumber(34, color: FN.paper)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TANJAKAN ${index + 1} · ${fmt.distUnit} ${fmt.distance(c.startDistanceM, decimals: 1)} → ${fmt.distance(c.endDistanceM, decimals: 1)}',
                      style: FN.label(size: 9.5),
                    ),
                    const SizedBox(height: 6),
                    Wrap(spacing: 16, runSpacing: 8, children: [
                      StatBlock(
                          label: 'Panjang',
                          value: fmt.distance(c.lengthM),
                          unit: fmt.distUnit,
                          size: 22),
                      StatBlock(
                          label: 'Naik',
                          value: fmt.elevation(c.gainM),
                          unit: fmt.eleUnit,
                          size: 22),
                      StatBlock(
                          label: 'Rata / maks',
                          value:
                              '${c.avgGradePct.toStringAsFixed(1)}/${c.maxGradePct.toStringAsFixed(0)}',
                          unit: '%',
                          size: 22),
                      StatBlock(
                          label: 'VAM',
                          value: Fmt.number(c.vam),
                          unit: 'm/j',
                          size: 22),
                      StatBlock(
                          label: 'Waktu',
                          value: Fmt.duration(c.durationS),
                          size: 22),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Classic-race style "Secteur" card for a gravel sector.
class GravelSectorCard extends StatelessWidget {
  final GravelSector sector;
  final Fmt fmt;
  const GravelSectorCard({super.key, required this.sector, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final s = sector;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: FN.paper,
        border: Border.fromBorderSide(BorderSide(color: FN.ink, width: 2)),
        boxShadow: [BoxShadow(color: FN.ink, offset: Offset(3, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: FN.ink,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(children: [
              Text('SEKTOR', style: FN.label(size: 10, color: FN.paper)),
              const SizedBox(width: 8),
              Text('${s.number}', style: FN.bigNumber(30, color: FN.paper)),
              const Spacer(),
              StarRating(stars: s.stars, size: 16, emptyColor: FN.inkMuted),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: const TextStyle(
                        fontFamily: FN.sans,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: FN.ink)),
                const SizedBox(height: 2),
                Text(
                  '${fmt.distUnit} ${fmt.distance(s.startDistanceM, decimals: 1)} → ${fmt.distance(s.endDistanceM, decimals: 1)}',
                  style: FN.label(size: 10),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: StatBlock(
                        label: 'Panjang',
                        value: fmt.distance(s.lengthM),
                        unit: fmt.distUnit,
                        size: 24),
                  ),
                  Expanded(
                    child: StatBlock(
                        label: 'Tanjakan',
                        value: s.avgGradePct.toStringAsFixed(1),
                        unit: '%',
                        size: 24),
                  ),
                  Expanded(
                    child: StatBlock(
                        label: 'Kekasaran',
                        value: s.roughness.toStringAsFixed(1),
                        unit: 'm/s²',
                        size: 24),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: FN.surface[s.dominantSurface],
                      border: Border.all(color: FN.ink, width: 0.8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(s.dominantSurface.label.toUpperCase(),
                      style: FN.label(size: 10, color: FN.ink)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Best efforts ledger.
class BestEffortsTable extends StatelessWidget {
  final List<BestEffort> efforts;
  final SportType sport;
  final Fmt fmt;
  const BestEffortsTable(
      {super.key,
      required this.efforts,
      required this.sport,
      required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (var i = 0; i < efforts.length; i++) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(children: [
            SizedBox(
                width: 72,
                child: Text(efforts[i].label.toUpperCase(),
                    style: _td(bold: true))),
            Expanded(
                child: Text(Fmt.duration(efforts[i].timeS),
                    style: FN.bigNumber(22))),
            Builder(builder: (_) {
              final e = efforts[i];
              final mps = e.timeS == 0 ? 0.0 : e.distanceM / e.timeS;
              final (v, u) = fmt.speedOrPace(mps, sport);
              return Text('$v ${u.toLowerCase()}', style: _td());
            }),
          ]),
        ),
        if (i < efforts.length - 1)
          const InkRule(dashed: true, color: FN.paperLine),
      ],
    ]);
  }
}

/// Horizontal photo strip with km captions.
class PhotoStrip extends StatelessWidget {
  final List<WaypointPhoto> photos;
  final Fmt fmt;
  const PhotoStrip({super.key, required this.photos, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final p = photos[i];
          return Container(
            width: 124,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: FN.paper,
              border: Border.all(color: FN.ink, width: 1),
            ),
            child: Column(children: [
              Expanded(
                child: Image.file(
                  File(p.filePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  cacheWidth: 300,
                  errorBuilder: (_, _, _) => Container(
                    color: FN.paperDeep,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${fmt.distUnit} ${fmt.distance(p.distanceFromStartMeters, decimals: 1)}',
                style: FN.label(size: 9.5, color: FN.ink),
              ),
            ]),
          );
        },
      ),
    );
  }
}
