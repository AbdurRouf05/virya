import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/location/models/telemetry_snapshot.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/recording_format.dart';

/// Pitch-black (#000000) minimalist HUD designed for AMOLED screens.
/// Pauses vector map rendering to conserve battery on long rides and runs.
class AmoledHudPanel extends StatelessWidget {
  final RecordingState state;
  final RecFormat fmt;
  final VoidCallback onPeek;

  const AmoledHudPanel({
    super.key,
    required this.state,
    required this.fmt,
    required this.onPeek,
  });

  @override
  Widget build(BuildContext context) {
    final LiveTelemetrySnapshot s = state.snapshot;
    final cycling = state.sport.isCycling;

    final speedValue =
        cycling ? fmt.speed(s.currentSpeedKmh) : fmt.pace(s.currentSpeedKmh);
    final speedUnit = cycling ? fmt.speedUnit : fmt.paceUnit;
    final speedLabel = cycling ? 'KECEPATAN' : 'PACE';

    String? ribbon;
    Color ribbonColor = FN.acid;
    if (state.phase == RecordingPhase.paused) {
      ribbon = 'DIJEDA';
      ribbonColor = FN.signal;
    } else if (s.isAutoPaused) {
      ribbon = 'AUTO-PAUSE';
    }

    return Material(
      color: Colors.black,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPeek();
        },
        splashColor: FN.acid.withValues(alpha: 0.12),
        highlightColor: Colors.white10,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: const Color(0xFF222222), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tap to peek banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: FN.acid.withValues(alpha: 0.45)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app_outlined, size: 14, color: FN.acid),
                    const SizedBox(width: 8),
                    Text(
                      'KETUK UNTUK INTIP PETA (15s)',
                      style: FN.label(size: 10, color: FN.acid).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.map_outlined, size: 14, color: FN.acid),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Primary Speed / Pace display
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$speedLabel • $speedUnit',
                          style: FN.label(size: 11, color: Colors.white60),
                        ),
                        if (ribbon != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            color: ribbonColor,
                            child: Text(
                              ribbon,
                              style:
                                  FN.label(size: 9, color: FN.onAccent),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        speedValue,
                        style: TextStyle(
                          fontFamily: FN.display,
                          fontSize: 96,
                          height: 0.95,
                          fontWeight: FontWeight.w900,
                          color: state.isActive && !s.isPaused
                              ? Colors.white
                              : Colors.white38,
                          fontFeatures: FN.tabular,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // 2x2 Grid of secondary metrics
              Row(
                children: [
                  Expanded(
                    child: _AmoledTile(
                      label: 'JARAK',
                      value: fmt.distance(s.totalDistanceMeters),
                      unit: fmt.distanceUnit,
                      accent: FN.acid,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AmoledTile(
                      label: 'WAKTU GERAK',
                      value: RecFormat.duration(s.movingTimeSeconds),
                      unit: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: s.heartRate != null
                        ? _AmoledTile(
                            label: 'DETAK JANTUNG',
                            value: '${s.heartRate}',
                            unit: 'BPM',
                            accent: FN.signal,
                          )
                        : _AmoledTile(
                            label: 'ELEV NAIK',
                            value: fmt.elevation(s.totalElevationGainMeters),
                            unit: fmt.elevationUnit,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: cycling
                        ? _AmoledTile(
                            label: 'RATA-RATA',
                            value: fmt.speed(s.averageSpeedKmh),
                            unit: fmt.speedUnit,
                          )
                        : _AmoledTile(
                            label: 'PACE RATA²',
                            value: fmt.pace(s.averageSpeedKmh),
                            unit: fmt.paceUnit,
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Bottom status indication
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AMOLED PITCH-BLACK HUD',
                        style: FN.label(size: 9, color: Colors.white54),
                      ),
                    ],
                  ),
                  Text(
                    'PETA DIJEDA (HEMAT DAYA)',
                    style: FN.label(size: 9, color: FN.acid.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmoledTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? accent;

  const _AmoledTile({
    required this.label,
    required this.value,
    required this.unit,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        border: Border(
          left: BorderSide(color: accent ?? const Color(0xFF333333), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FN.label(size: 9, color: Colors.white60),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: FN.display,
                    fontSize: 32,
                    color: Colors.white,
                    fontFeatures: FN.tabular,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: FN.label(size: 9, color: Colors.white60),
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
