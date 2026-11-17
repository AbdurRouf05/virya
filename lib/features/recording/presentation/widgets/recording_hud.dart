import 'package:flutter/material.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/recording_format.dart';
import 'package:virya/features/recording/presentation/widgets/amoled_hud_panel.dart';

/// Primary HUD component for the live recording view.
///
/// Integrates [AmoledHudPanel] to deliver a high-contrast, glove-friendly,
/// zero-clipping telemetry HUD in strict compliance with the Field Notes
/// design system.
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
    return AmoledHudPanel(state: state, fmt: fmt);
  }
}
