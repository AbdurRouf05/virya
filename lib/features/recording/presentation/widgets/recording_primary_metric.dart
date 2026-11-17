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
