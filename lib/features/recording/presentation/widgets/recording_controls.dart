import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/widgets/hold_to_confirm_button.dart';

/// Phase-dependent bottom controls (start / pause / resume / finish).
class RecordingControls extends StatelessWidget {
  final RecordingState state;
  final bool busy;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onDiscard;
  final VoidCallback onPhoto;
  final ValueChanged<bool> onToggleSim;

  const RecordingControls({
    super.key,
    required this.state,
    required this.busy,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onDiscard,
    required this.onPhoto,
    required this.onToggleSim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: switch (state.phase) {
        RecordingPhase.idle => _idle(),
        RecordingPhase.recording => _recording(),
        RecordingPhase.paused => _paused(),
        RecordingPhase.saving => const SizedBox(height: 88),
      },
    );
  }

  Widget _idle() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _BigButton(
        label: 'MULAI',
        icon: Icons.play_arrow,
        color: FN.signal,
        onTap: busy ? null : onStart,
      ),
      const SizedBox(height: 4),
      _SimToggle(value: state.simulated, onChanged: onToggleSim),
    ],
  );

  Widget _recording() => Row(
    children: [
      _SquareButton(icon: Icons.photo_camera, onTap: onPhoto),
      const SizedBox(width: 8),
      Expanded(
        child: _BigButton(
          label: 'JEDA',
          icon: Icons.pause,
          color: FN.onNight,
          onTap: onPause,
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 88,
        child: HoldToConfirmButton(
          label: 'SELESAI',
          icon: Icons.stop,
          onConfirmed: onStop,
        ),
      ),
    ],
  );

  Widget _paused() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Expanded(
            child: _BigButton(
              label: 'LANJUT',
              icon: Icons.play_arrow,
              color: FN.acid,
              onTap: onResume,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: HoldToConfirmButton(
              label: 'TAHAN · SELESAI',
              icon: Icons.stop,
              onConfirmed: onStop,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(140, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: onDiscard,
        child: Text(
          FN.caps('BUANG AKTIVITAS'),
          style: FN.label(size: 11, color: FN.warn),
        ),
      ),
    ],
  );
}

class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _BigButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? color.withValues(alpha: 0.4) : color,
      borderRadius: FN.boxRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onTap == null
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    onTap!();
                  },
        child: SizedBox(
          height: 88,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 34, color: FN.onAccent),
              const SizedBox(width: 10),
              Text(
                FN.caps(label),
                style: FN
                    .title(32, color: FN.onAccent)
                    .copyWith(letterSpacing: FN.track(1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FN.nightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: FN.cardRadius,
        side: BorderSide(color: FN.nightLine, width: FN.line(2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 72,
          height: 88,
          child: Icon(icon, color: FN.onNight, size: 28),
        ),
      ),
    );
  }
}

class _SimToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SimToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            FN.caps('GPS SIMULASI (DEV)'),
            style: FN.label(size: 10, color: FN.onNightMuted),
          ),
          const SizedBox(width: 6),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: FN.acid,
              inactiveThumbColor: FN.onNightMuted,
              inactiveTrackColor: FN.nightSurface,
            ),
          ),
        ],
      ),
    );
  }
}
