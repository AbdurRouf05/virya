import 'package:flutter/material.dart';
import 'package:virya/app/theme/caps.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/palette.dart';

/// Aturan bentuk & huruf untuk satu gaya, versi mini dari token `FN`,
/// dipakai [LookPreview] (`look_preview.dart`).
class MiniLook {
  final Palette p;
  MiniLook(this.p);

  bool get clean => p.gaya == UiGaya.bersih;
  Color get cardFill => p.card ?? p.paper;

  String caps(String s) => clean ? sentenceCase(s) : s.toUpperCase();

  BoxDecoration card({Color? fill}) => BoxDecoration(
    color: fill ?? cardFill,
    border: Border.all(
      color: clean ? p.paperLine : p.ink,
      width: clean ? 0.8 : 1.5,
    ),
    borderRadius: clean ? BorderRadius.circular(10) : null,
    boxShadow:
        clean
            ? null
            : [BoxShadow(color: p.ink, offset: const Offset(2.5, 2.5))],
  );

  TextStyle label({Color? color}) =>
      clean
          ? TextStyle(
            fontFamily: p.sans,
            fontSize: 8,
            color: color ?? p.inkMuted,
          )
          : TextStyle(
            fontFamily: p.mono,
            fontSize: 6.5,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
            color: color ?? p.inkMuted,
          );

  TextStyle title(double size) =>
      clean
          ? TextStyle(
            fontFamily: p.sans,
            fontSize: size * 0.66,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.1,
            color: p.ink,
          )
          : TextStyle(
            fontFamily: p.display,
            fontSize: size,
            height: 1.0,
            color: p.ink,
          );

  TextStyle body({Color? color, bool strike = false}) => TextStyle(
    fontFamily: p.sans,
    fontSize: 8.5,
    color: color ?? p.ink,
    decoration: strike ? TextDecoration.lineThrough : null,
    decorationColor: p.inkMuted,
  );
}

/// Kisi kertas latar gaya Tegas.
class MiniGrid extends CustomPainter {
  final Color color;
  MiniGrid(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 0.5;
    for (var x = 0.0; x < size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(MiniGrid old) => old.color != color;
}
