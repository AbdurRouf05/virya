import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Large button that only fires after being held for [holdDuration]
/// (prevents accidental stops; usable with gloves).
class HoldToConfirmButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onConfirmed;
  /// Accent color; defaults to [FN.signal].
  final Color? color;
  final Duration holdDuration;
  final double height;

  const HoldToConfirmButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onConfirmed,
    this.color,
    this.holdDuration = const Duration(milliseconds: 1200),
    this.height = 88,
  });

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.holdDuration)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) {
            HapticFeedback.heavyImpact();
            widget.onConfirmed();
            _c.value = 0;
          }
        });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down() {
    HapticFeedback.selectionClick();
    _c.forward();
  }

  void _up() {
    if (_c.status != AnimationStatus.completed) {
      _c.reverse();
      if (_c.value < 0.3) {
        ScaffoldMessenger.maybeOf(context)
          ?..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Tahan tombol untuk menyelesaikan'),
            duration: Duration(seconds: 1),
          ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? FN.signal;
    return Semantics(
      button: true,
      label: '${widget.label}, tahan untuk konfirmasi',
      child: Listener(
        onPointerDown: (_) => _down(),
        onPointerUp: (_) => _up(),
        onPointerCancel: (_) => _up(),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Container(
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              color: FN.night,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: _c.value,
                  child: ColoredBox(color: color),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon,
                        size: 30,
                        color: _c.value > 0.5 ? FN.onAccent : color),
                    const SizedBox(height: 4),
                    Text(widget.label,
                        style: FN.label(
                            size: 11,
                            color: _c.value > 0.5 ? FN.onAccent : color)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
