import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Catatan lurus dengan garis aksen di kiri. [color] defaults to `FN.signal`.
class CardNote extends StatelessWidget {
  final List<String> lines;
  final Color? color;
  final double size;
  const CardNote({super.key, required this.lines, this.color, this.size = 9});

  @override
  Widget build(BuildContext context) {
    final c = color ?? FN.signal;
    return Container(
      padding: EdgeInsets.only(left: size * 0.7),
      decoration: BoxDecoration(
          border: Border(left: BorderSide(color: c, width: size * 0.25))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines.length; i++)
            Text(lines[i],
                maxLines: 1,
                style: TextStyle(
                  fontFamily: FN.mono,
                  fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                  fontSize: i == 0 ? size : size * 0.82,
                  letterSpacing: 1.4,
                  color: c,
                  height: 1.25,
                )),
        ],
      ),
    );
  }
}
