import 'package:flutter/material.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/domain/share_options.dart';
import 'package:virya/features/share/templates/share_card.dart';

/// One template preview page; [repaintKey] wraps the card for PNG capture.
class StudioPreview extends StatelessWidget {
  final ShareData data;
  final CardTemplate template;
  final ShareOptions options;
  final GlobalKey repaintKey;
  const StudioPreview({
    super.key,
    required this.data,
    required this.template,
    required this.options,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    final size = options.format.logicalSize;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(color: Color(0x88000000), blurRadius: 18),
            ]),
            child: Stack(children: [
              if (template.isTransparent)
                CustomPaint(size: size, painter: const _CheckerPainter()),
              RepaintBoundary(
                key: repaintKey,
                child: ShareCard(data: data, template: template, options: options),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  const _CheckerPainter();
  @override
  void paint(Canvas canvas, Size size) {
    const s = 12.0;
    final a = Paint()..color = const Color(0xFF4A4A44);
    final b = Paint()..color = const Color(0xFF6A6A62);
    for (var y = 0.0; y < size.height; y += s) {
      for (var x = 0.0; x < size.width; x += s) {
        final even = ((x / s).floor() + (y / s).floor()).isEven;
        canvas.drawRect(Rect.fromLTWH(x, y, s, s), even ? a : b);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter old) => false;
}

