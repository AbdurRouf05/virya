import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/recording_format.dart';

/// Big speed (cycling) or pace (foot) readout with pause ribbon.
class RecordingPrimaryMetric extends StatelessWidget {
  final RecordingState state;
  final RecFormat fmt;
  const RecordingPrimaryMetric(
      {super.key, required this.state, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final snap = state.snapshot;
    final cycling = state.sport.isCycling;
    final value =
        cycling ? fmt.speed(snap.currentSpeedKmh) : fmt.pace(snap.currentSpeedKmh);
    final label = cycling ? 'KECEPATAN · ${fmt.speedUnit}' : 'PACE · ${fmt.paceUnit}';
    final size = (MediaQuery.sizeOf(context).width * 0.30).clamp(72.0, 132.0);

    String? ribbon;
    Color ribbonColor = FN.acid;
    if (state.phase == RecordingPhase.paused) {
      ribbon = 'DIJEDA';
      ribbonColor = FN.signal;
    } else if (snap.isAutoPaused) {
      ribbon = 'AUTO-PAUSE';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: FN.label(color: FN.paperLine)),
              if (ribbon != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: ribbonColor,
                  child: Text(ribbon, style: FN.label(size: 10, color: FN.ink)),
                ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
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
        ],
      ),
    );
  }
}
