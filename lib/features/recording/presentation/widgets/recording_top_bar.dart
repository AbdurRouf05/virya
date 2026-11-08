import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/widgets/recording_sport_icon.dart';

/// Close button, current sport (tap to change while idle) and GPS chip.
class RecordingTopBar extends StatelessWidget {
  final RecordingState state;
  final VoidCallback onClose;
  final VoidCallback onSport;

  const RecordingTopBar({
    super.key,
    required this.state,
    required this.onClose,
    required this.onSport,
  });

  @override
  Widget build(BuildContext context) {
    final idle = state.phase == RecordingPhase.idle;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          if (idle)
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, color: FN.onNight),
              tooltip: 'Tutup',
            )
          else
            const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: idle ? onSport : null,
              child: Row(
                children: [
                  Icon(sportIcon(state.sport), color: FN.signal, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      state.sport.displayName.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: FN.display,
                          fontSize: 20,
                          color: FN.onNight,
                          letterSpacing: 0.5),
                    ),
                  ),
                  if (idle) Icon(Icons.expand_more, color: FN.onNightMuted),
                ],
              ),
            ),
          ),
          _GpsChip(status: state.gps, accuracy: state.snapshot.accuracyMeters),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _GpsChip extends StatelessWidget {
  final GpsStatus status;
  final double accuracy;
  const _GpsChip({required this.status, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      GpsStatus.good => ('GPS ±${accuracy.round()}M', FN.acid),
      GpsStatus.weak => ('GPS LEMAH', FN.caution),
      GpsStatus.searching => ('MENCARI GPS', FN.signal),
      GpsStatus.off => ('GPS MATI', FN.inkMuted),
      GpsStatus.simulated => ('SIMULASI', FN.acid),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(border: Border.all(color: color)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Blink(active: status == GpsStatus.searching, color: color),
          const SizedBox(width: 6),
          Text(label, style: FN.label(size: 10, color: color)),
        ],
      ),
    );
  }
}

class _Blink extends StatefulWidget {
  final bool active;
  final Color color;
  const _Blink({required this.active, required this.color});

  @override
  State<_Blink> createState() => _BlinkState();
}

class _BlinkState extends State<_Blink> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Blink old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.active && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.active) {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _c,
        child: Container(width: 8, height: 8, color: widget.color),
      );
}
