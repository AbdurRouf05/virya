import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/domain/share_options.dart';
import 'package:virya/features/share/render/topo_ink_renderer.dart';
import 'package:virya/features/share/templates/card_parts.dart';

/// NIGHT INK — night ground, ghost contours, Topo-Ink 2.5D route in acid,
/// bold paper numerals.
class NightInkCard extends StatelessWidget {
  final ShareData data;
  final ShareOptions options;
  const NightInkCard({super.key, required this.data, required this.options});

  @override
  Widget build(BuildContext context) {
    final f = options.format;
    final accent = options.accent == AccentChoice.signal
        ? FN
              .acid // night default
        : options.accent.resolve(dark: true);
    final compact = f == CardFormat.square;
    final big = switch (f) {
      CardFormat.story => 120.0,
      CardFormat.feed => 92.0,
      CardFormat.square => 70.0,
    };
    const muted = Color(0xFF8C887D);

    return Container(
      color: FN.night,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TopoPainter(
                data: data,
                accent: accent,
                compact: compact,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: GrainPainter(
                seed: data.seed,
                density: 0.07,
                dark: const Color(0x40000000),
                light: const Color(0x14FFFFFF),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              compact ? 14 : 22,
              20,
              compact ? 14 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MonoLabel(
                        'NIGHT INK · ${SF.entryNo(data)}',
                        color: FN.paper,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    MonoLabel(SF.date(data.start), color: muted),
                  ],
                ),
                const SizedBox(height: 5),
                HairRule(color: FN.nightLine, thickness: 1),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FN.sans,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          letterSpacing: 0.6,
                          color: FN.paper,
                        ),
                      ),
                    ),
                    MonoLabel(
                      SF.sport(data.sport),
                      color: accent,
                      weight: FontWeight.w700,
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: PosterNumber(
                        SF.km(data.distanceM),
                        size: big,
                        color: FN.paper,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: EdgeInsets.only(bottom: big * 0.1),
                      child: Text(
                        'KM',
                        style: FN.bigNumber(big * 0.22, color: accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                HairRule(color: FN.nightLine),
                const SizedBox(height: 7),
                StatStrip(
                  stats: statValues(data, options.stats),
                  ink: FN.paper,
                  muted: muted,
                  rule: FN.nightLine,
                  valueSize: compact ? 18 : 22,
                ),
                const SizedBox(height: 7),
                HairRule(color: FN.nightLine),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: MonoLabel(
                        SF.coord(data.startLat, data.startLon),
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    MonoLabel('${SF.meters(data.maxEleM)} MDPL', color: muted),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopoPainter extends CustomPainter {
  final ShareData data;
  final Color accent;
  final bool compact;
  _TopoPainter({
    required this.data,
    required this.accent,
    required this.compact,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = TopoInkRenderer(
      lat: data.lat,
      lon: data.lon,
      ele: data.ele,
      dist: data.dist,
      seed: data.seed,
      markerFracs: [
        for (final p in data.photos)
          if (data.distanceM > 0) p.distanceM / data.distanceM,
      ],
    );
    final top = compact ? 0.12 : 0.1;
    final bottom = compact ? 0.48 : 0.42;
    final vp = Rect.fromLTRB(
      0,
      size.height * top,
      size.width,
      size.height * (1 - bottom),
    );
    r.paint(
      canvas,
      size,
      t: 1,
      yaw: -0.45,
      tilt: 1.0,
      viewport: vp,
      style: TopoInkStyle.night(accent: accent, background: false),
      zoom: compact ? 1.0 : 1.08,
    );
  }

  @override
  bool shouldRepaint(_TopoPainter old) =>
      old.data != data || old.accent != accent;
}
