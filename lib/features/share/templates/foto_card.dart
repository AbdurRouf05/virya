import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/features/share/domain/share_data.dart';
import 'package:stravo/features/share/domain/share_format.dart';
import 'package:stravo/features/share/domain/share_options.dart';
import 'package:stravo/features/share/templates/card_parts.dart';

/// FOTO — user's photo as a film frame (faded, grain, edge print) with a
/// Field Notes stats strip.
class FotoCard extends StatelessWidget {
  final ShareData data;
  final ShareOptions options;
  const FotoCard({super.key, required this.data, required this.options});

  @override
  Widget build(BuildContext context) {
    final f = options.format;
    final accent = options.accent.resolve(dark: false);
    final compact = f == CardFormat.square;
    final photo = options.photo;
    final big = switch (f) {
      CardFormat.story => 64.0,
      CardFormat.feed => 54.0,
      CardFormat.square => 46.0,
    };

    return Container(
      color: FN.night,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EdgePrint(data: data, top: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (photo != null)
                      CustomPaint(painter: _PhotoPainter(photo))
                    else ...[
                      CustomPaint(painter: PaperPainter(seed: data.seed + 21)),
                      const Center(
                        child: MonoLabel(
                          '[ PILIH FOTO ]',
                          size: 11,
                          color: FN.inkSoft,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                    CustomPaint(
                      painter: GrainPainter(
                        seed: data.seed + 9,
                        density: 0.16,
                        dark: const Color(0x38000000),
                        light: const Color(0x26FFF3D6),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: CardNote(
                        lines: [SF.coord(data.startLat, data.startLon)],
                        color: photo != null ? FN.paper : FN.ink,
                        size: 7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            padding: EdgeInsets.fromLTRB(
              12,
              compact ? 8 : 12,
              12,
              compact ? 8 : 12,
            ),
            color: FN.paper,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: PosterNumber(SF.km(data.distanceM), size: big),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: EdgeInsets.only(bottom: big * 0.1),
                      child: Text(
                        'KM',
                        style: FN.bigNumber(big * 0.28, color: accent),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: big * 0.95,
                      height: big * 0.95,
                      child: CustomPaint(
                        painter: RouteMapPainter(
                          data: data,
                          accent: accent,
                          width: 1.6,
                          bleed: false,
                          padding: 4,
                          markFill: FN.paper,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const HairRule(),
                const SizedBox(height: 6),
                StatStrip(
                  stats: statValues(data, options.stats).take(4).toList(),
                  valueSize: compact ? 15 : 18,
                ),
              ],
            ),
          ),
          _EdgePrint(data: data, top: false),
        ],
      ),
    );
  }
}

/// Film-edge print strip.
class _EdgePrint extends StatelessWidget {
  final ShareData data;
  final bool top;
  const _EdgePrint({required this.data, required this.top});

  @override
  Widget build(BuildContext context) {
    final frame = data.seed % 30 + 4;
    final text = top
        ? 'STRAVO 400  ▸ ${frame}A          ▸ ${frame + 1}          ${SF.sport(data.sport)}'
        : '${SF.date(data.start)}  ·  ${SF.entryNo(data)}  ·  DICATAT OFFLINE';
    return SizedBox(
      height: 22,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: MonoLabel(
            text,
            size: 7,
            color: const Color(0xFFE88A2E),
            weight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PhotoPainter extends CustomPainter {
  final ui.Image image;
  _PhotoPainter(this.image);

  // Faded film: lower saturation, lifted blacks, warm cast.
  static const _film = ColorFilter.matrix([
    0.86, 0.12, 0.02, 0, 14, //
    0.06, 0.88, 0.06, 0, 10, //
    0.04, 0.12, 0.74, 0, 8, //
    0, 0, 0, 1, 0,
  ]);

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: image,
      fit: BoxFit.cover,
      colorFilter: _film,
      filterQuality: FilterQuality.medium,
    );
    // Vignette.
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          r.center,
          size.longestSide * 0.7,
          [const Color(0x00000000), const Color(0x66000000)],
          [0.55, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_PhotoPainter old) => old.image != image;
}
