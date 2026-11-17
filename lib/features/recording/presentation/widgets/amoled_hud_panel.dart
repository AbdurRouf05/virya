import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/location/models/telemetry_snapshot.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/recording_format.dart';

/// Ultra-high contrast AMOLED HUD panel for live recording.
///
/// Designed for outdoor readability in bright sun and dark night:
/// - Pure dark AMOLED surfaces ([FN.night], [FN.nightSurface])
/// - Strict Field Notes typography hierarchy:
///   - [FN.display] for big poster numbers with tabular figures
///   - [FN.mono] for technical labels, units, and telemetry readouts
///   - [FN.sans] for status text and notifications
/// - Anti-collision vertical spacing between labels and numerals
/// - Zero-clipping layout handling 3-digit speed (e.g. 100+ km/h) and
///   multi-hour duration formats (`hh:mm:ss`) without overflow.
class AmoledHudPanel extends StatelessWidget {
  final RecordingState state;
  final RecFormat fmt;

  const AmoledHudPanel({
    super.key,
    required this.state,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AmoledPrimaryMetric(state: state, fmt: fmt),
        const SizedBox(height: 4),
        _AmoledMetricGrid(state: state, fmt: fmt),
      ],
    );
  }
}

class _AmoledPrimaryMetric extends StatelessWidget {
  final RecordingState state;
  final RecFormat fmt;

  const _AmoledPrimaryMetric({required this.state, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final snap = state.snapshot;
    final cycling = state.sport.isCycling;
    final value = cycling
        ? fmt.speed(snap.currentSpeedKmh)
        : fmt.pace(snap.currentSpeedKmh);
    final label =
        cycling ? 'KECEPATAN · ${fmt.speedUnit}' : 'PACE · ${fmt.paceUnit}';
    final size = (MediaQuery.sizeOf(context).width * 0.28).clamp(68.0, 128.0);

    String? ribbon;
    Color ribbonBg = FN.acid;
    Color ribbonFg = FN.ink;
    if (state.phase == RecordingPhase.paused) {
      ribbon = 'DIJEDA';
      ribbonBg = FN.signal;
      ribbonFg = FN.paper;
    } else if (snap.isAutoPaused) {
      ribbon = 'AUTO-PAUSE';
      ribbonBg = FN.acid;
      ribbonFg = FN.ink;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: FN.mono,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: FN.paperLine,
                ),
              ),
              if (ribbon != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ribbonBg,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    ribbon,
                    style: TextStyle(
                      fontFamily: FN.sans,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: ribbonFg,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Large poster numeral readout with FittedBox to prevent clipping
          SizedBox(
            height: size * 0.98,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                value,
                style: FN.bigNumber(
                  size,
                  color: state.isActive && !snap.isPaused
                      ? FN.paper
                      : FN.paper.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmoledMetricGrid extends StatelessWidget {
  final RecordingState state;
  final RecFormat fmt;

  const _AmoledMetricGrid({required this.state, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final LiveTelemetrySnapshot s = state.snapshot;
    final cycling = state.sport.isCycling;
    final tiles = <_AmoledTile>[
      _AmoledTile(
        'JARAK',
        fmt.distance(s.totalDistanceMeters),
        fmt.distanceUnit,
      ),
      _AmoledTile(
        'WAKTU GERAK',
        RecFormat.duration(s.movingTimeSeconds),
        '',
      ),
      _AmoledTile(
        'ELEV NAIK',
        fmt.elevation(s.totalElevationGainMeters),
        fmt.elevationUnit,
      ),
      _AmoledTile(
        'TANJAKAN',
        RecFormat.grade(s.currentGradePct),
        '%',
        accent: s.currentGradePct >= 3 ? FN.grade(s.currentGradePct) : null,
      ),
      cycling
          ? _AmoledTile('RATA-RATA', fmt.speed(s.averageSpeedKmh), fmt.speedUnit)
          : _AmoledTile('PACE RATA²', fmt.pace(s.averageSpeedKmh), fmt.paceUnit),
      s.heartRate != null
          ? _AmoledTile(
              'DETAK JANTUNG',
              '${s.heartRate}',
              'BPM',
              accent: FN.signal,
            )
          : _AmoledTile(
              'TOTAL WAKTU',
              RecFormat.duration(s.elapsedTimeSeconds),
              '',
            ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < 2; r++)
            Row(
              children: [
                for (var c = 0; c < 3; c++)
                  Expanded(
                    child: _AmoledTileView(tile: tiles[r * 3 + c]),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AmoledTile {
  final String label;
  final String value;
  final String unit;
  final Color? accent;

  const _AmoledTile(this.label, this.value, this.unit, {this.accent});
}

class _AmoledTileView extends StatelessWidget {
  final _AmoledTile tile;

  const _AmoledTileView({required this.tile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2.5),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: FN.nightSurface,
        border: Border(
          left: BorderSide(
            color: tile.accent ?? FN.nightLine,
            width: 3,
          ),
          top: BorderSide(color: FN.nightLine.withValues(alpha: 0.4), width: 1),
          right: BorderSide(color: FN.nightLine.withValues(alpha: 0.4), width: 1),
          bottom: BorderSide(color: FN.nightLine.withValues(alpha: 0.4), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tile.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FN.mono,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: FN.paperLine,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  tile.value,
                  style: FN.bigNumber(26, color: FN.paper),
                ),
                if (tile.unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    tile.unit,
                    style: TextStyle(
                      fontFamily: FN.mono,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: FN.paperLine,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
