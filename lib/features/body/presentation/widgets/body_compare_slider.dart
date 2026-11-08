import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Dua foto 3:4 yang ditumpuk: geser pembatas untuk melihat sebelum dan sesudah.
class BodyCompareSlider extends StatefulWidget {
  final String beforePath;
  final String afterPath;
  final String beforeLabel;
  final String afterLabel;

  const BodyCompareSlider({
    super.key,
    required this.beforePath,
    required this.afterPath,
    required this.beforeLabel,
    required this.afterLabel,
  });

  @override
  State<BodyCompareSlider> createState() => _BodyCompareSliderState();
}

class _BodyCompareSliderState extends State<BodyCompareSlider> {
  static const _step = 0.1;
  double _split = 0.5;

  void _set(double value) => setState(() => _split = value.clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final pct = (_split * 100).round();
    final next = ((_split + _step).clamp(0.0, 1.0) * 100).round();
    final previous = ((_split - _step).clamp(0.0, 1.0) * 100).round();
    return Semantics(
      slider: true,
      label: 'Perbandingan foto sebelum dan sesudah',
      value: 'Foto sebelum terlihat $pct persen',
      increasedValue: 'Foto sebelum terlihat $next persen',
      decreasedValue: 'Foto sebelum terlihat $previous persen',
      onIncrease: () => _set(_split + _step),
      onDecrease: () => _set(_split - _step),
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: LayoutBuilder(
            builder: (context, box) => _frame(context, box.biggest),
          ),
        ),
      ),
    );
  }

  Widget _frame(BuildContext context, Size size) {
    final x = size.width * _split;
    final decodeWidth = (size.width * MediaQuery.devicePixelRatioOf(context))
        .round();
    void follow(double dx) => _set(dx / size.width);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (d) => follow(d.localPosition.dx),
      onHorizontalDragUpdate: (d) => follow(d.localPosition.dx),
      onTapUp: (d) => follow(d.localPosition.dx),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          _Layer(
            path: widget.beforePath,
            label: widget.beforeLabel,
            alignment: Alignment.topLeft,
            decodeWidth: decodeWidth,
          ),
          ClipRect(
            clipper: _RightOf(x),
            child: _Layer(
              path: widget.afterPath,
              label: widget.afterLabel,
              alignment: Alignment.topRight,
              decodeWidth: decodeWidth,
            ),
          ),
          Positioned(
            left: x - 0.75,
            top: 0,
            bottom: 0,
            width: 1.5,
            child: ColoredBox(color: FN.onNight),
          ),
          Positioned(
            left: x - 16,
            top: size.height / 2 - 16,
            width: 32,
            height: 32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: FN.onNight,
                border: Border.all(color: FN.onAccent, width: 1.5),
              ),
              child: Icon(Icons.swap_horiz, size: 20, color: FN.onAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _RightOf extends CustomClipper<Rect> {
  final double x;

  _RightOf(this.x);

  @override
  Rect getClip(Size size) => Rect.fromLTRB(x, 0, size.width, size.height);

  @override
  bool shouldReclip(_RightOf old) => old.x != x;
}

class _Layer extends StatelessWidget {
  final String path;
  final String label;
  final Alignment alignment;
  final int decodeWidth;

  const _Layer({
    required this.path,
    required this.label,
    required this.alignment,
    required this.decodeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(path),
          fit: BoxFit.cover,
          cacheWidth: decodeWidth,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => ColoredBox(
            color: FN.nightSurface,
            child: Center(
              child: Icon(Icons.broken_image_outlined, color: FN.onNight),
            ),
          ),
        ),
        Align(
          alignment: alignment,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: FN.night,
            child: Text(label, style: FN.label(size: 10, color: FN.onNight)),
          ),
        ),
      ],
    );
  }
}
