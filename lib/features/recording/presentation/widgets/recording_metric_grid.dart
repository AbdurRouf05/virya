import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/location/models/telemetry_snapshot.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/recording_format.dart';

/// 3×2 grid of secondary live metrics.
class RecordingMetricGrid extends StatelessWidget {
  final RecordingState state;
  final RecFormat fmt;
  const RecordingMetricGrid(
      {super.key, required this.state, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final LiveTelemetrySnapshot s = state.snapshot;
    final cycling = state.sport.isCycling;
    final tiles = <_Tile>[
      _Tile('JARAK', fmt.distance(s.totalDistanceMeters), fmt.distanceUnit),
      _Tile('WAKTU GERAK', RecFormat.duration(s.movingTimeSeconds), ''),
      _Tile('ELEV NAIK', fmt.elevation(s.totalElevationGainMeters),
          fmt.elevationUnit),
      _Tile('TANJAKAN', RecFormat.grade(s.currentGradePct), '%',
          accent: s.currentGradePct >= 3 ? FN.grade(s.currentGradePct) : null),
      cycling
          ? _Tile('RATA-RATA', fmt.speed(s.averageSpeedKmh), fmt.speedUnit)
          : _Tile('PACE RATA²', fmt.pace(s.averageSpeedKmh), fmt.paceUnit),
      s.heartRate != null
          ? _Tile('DETAK JANTUNG', '${s.heartRate}', 'BPM', accent: FN.signal)
          : _Tile('TOTAL WAKTU', RecFormat.duration(s.elapsedTimeSeconds), ''),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          for (var r = 0; r < 2; r++)
            Row(
              children: [
                for (var c = 0; c < 3; c++)
                  Expanded(child: _TileView(tile: tiles[r * 3 + c])),
              ],
            ),
        ],
      ),
    );
  }
}

class _Tile {
  final String label;
  final String value;
  final String unit;
  final Color? accent;
  const _Tile(this.label, this.value, this.unit, {this.accent});
}

class _TileView extends StatelessWidget {
  final _Tile tile;
  const _TileView({required this.tile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: FN.nightSurface,
        border: Border(
          left: BorderSide(color: tile.accent ?? FN.nightLine, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tile.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FN.label(size: 9, color: FN.paperLine)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(tile.value, style: FN.bigNumber(30, color: FN.paper)),
                if (tile.unit.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Text(tile.unit, style: FN.label(size: 9, color: FN.paperLine)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
