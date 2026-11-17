import 'package:flutter/material.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/recording_format.dart';
import 'package:virya/features/recording/presentation/widgets/recording_metric_grid.dart';
import 'package:virya/features/recording/presentation/widgets/recording_primary_metric.dart';

/// Primary HUD component for the live recording view.
///
/// Combines [RecordingPrimaryMetric] and [RecordingMetricGrid] to deliver
/// a high-contrast, glove-friendly, zero-clipping telemetry HUD in strict
/// compliance with the Field Notes design system.
class RecordingHud extends StatelessWidget {
  final RecordingState state;
  final RecFormat fmt;

  const RecordingHud({
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
        RecordingPrimaryMetric(state: state, fmt: fmt),
        const SizedBox(height: 4),
        RecordingMetricGrid(state: state, fmt: fmt),
      ],
    );
  }
}
