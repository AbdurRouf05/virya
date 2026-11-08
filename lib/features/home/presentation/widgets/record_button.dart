import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Round "record" button for the centre slot of the nav bar.
///
/// The circle sits at the top of the widget (the nav bar positions it so it
/// rises above the bar edge); the small "REKAM" label sits underneath.
class RecordButton extends StatefulWidget {
  final VoidCallback onTap;
  final double diameter;

  const RecordButton({super.key, required this.onTap, this.diameter = 58});

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Rekam aktivitas',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Circle(diameter: widget.diameter),
              const SizedBox(height: 4),
              Text(
                'REKAM',
                style: FN
                    .label(size: 9.5, color: FN.ink)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double diameter;
  const _Circle({required this.diameter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: FN.signal,
        shape: BoxShape.circle,
        border: Border.all(color: FN.ink, width: 2),
      ),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(color: FN.paper, shape: BoxShape.circle),
      ),
    );
  }
}
