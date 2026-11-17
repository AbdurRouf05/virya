import 'package:flutter/widgets.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Virya brand mark: five square "streak" cells forming a V, the last one lit.
///
/// Same geometry as `assets/branding/virya_mark.svg` (cells 40, gap 4 on a
/// 44-unit pitch; mark 216 x 128 units), drawn tight to its own bounds.
/// [size] is the mark width; the height is `size * 128 / 216`.
class ViryaMark extends StatelessWidget {
  const ViryaMark({super.key, this.size = 48, Color? ink, Color? accent})
      : _ink = ink,
        _accent = accent;

  final double size;
  final Color? _ink;
  final Color? _accent;

  Color get ink => _ink ?? FN.ink;
  Color get accent => _accent ?? FN.signal;

  static const double _cell = 40;
  static const double _pitch = 44;
  static const double _width = 216;
  static const double _height = 128;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Virya',
      image: true,
      child: SizedBox(
        width: size,
        height: size * _height / _width,
        child: CustomPaint(painter: _ViryaMarkPainter(ink, accent)),
      ),
    );
  }
}

class _ViryaMarkPainter extends CustomPainter {
  _ViryaMarkPainter(this.ink, this.accent);

  final Color ink;
  final Color accent;

  /// (column, row) of the ink cells; the accent cell sits at (4, 0).
  static const _inkCells = [(0, 0), (1, 1), (2, 2), (3, 1)];

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / ViryaMark._width;
    final cell = ViryaMark._cell * k;
    final pitch = ViryaMark._pitch * k;
    Rect at(int c, int r) => Rect.fromLTWH(c * pitch, r * pitch, cell, cell);

    final inkPaint = Paint()..color = ink;
    for (final (c, r) in _inkCells) {
      canvas.drawRect(at(c, r), inkPaint);
    }
    canvas.drawRect(at(4, 0), Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_ViryaMarkPainter old) =>
      old.ink != ink || old.accent != accent;
}
