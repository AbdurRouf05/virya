import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Radar GPS Sweep & Satellite Pulse loading indicator designed for Virya's
/// "Field Notes" outdoor cartography visual identity.
///
/// Features:
/// - 360° phosphor glow radar sweep with trailing decay fan
/// - Concentric range rings (500m / 1000m / 2000m) & azimuth markings
/// - 3 satellite blips that flash and emit expanding pulse rings when swept
/// - Telemetry HUD below radar displaying coordinates and satellite lock status
/// - 60fps performance using optimized [CustomPainter] and [AnimationController]
class RadarLoadingIndicator extends StatefulWidget {
  const RadarLoadingIndicator({
    super.key,
    this.size = 180,
    this.label,
    this.accentColor,
    this.showCoordinates = true,
    this.showTelemetry = true,
    this.lat = "-06° 54' 32.1\" S",
    this.lon = "107° 36' 18.4\" E",
    this.satsText = 'SATS: 9/12 • AKURASI ±3M',
    this.period = const Duration(milliseconds: 2400),
    this.backgroundColor,
  });

  /// Diameter of the radar scope.
  final double size;

  /// Custom label text under the radar scope.
  /// Defaults to 'MENCARI KOORDINAT GPS... [SATELLITE LOCKING]'.
  final String? label;

  /// Primary radar sweep and pulse accent color. Defaults to [FN.acid].
  final Color? accentColor;

  /// Whether to render the telemetry coordinate block below the radar.
  final bool showCoordinates;

  /// Whether to render the satellite count & accuracy line.
  final bool showTelemetry;

  /// Latitude string.
  final String lat;

  /// Longitude string.
  final String lon;

  /// Satellite constellation info string.
  final String satsText;

  /// Duration for one complete 360° sweep revolution.
  final Duration period;

  /// Radar scope background color. Defaults to [FN.night].
  final Color? backgroundColor;

  @override
  State<RadarLoadingIndicator> createState() => _RadarLoadingIndicatorState();
}

class _RadarLoadingIndicatorState extends State<RadarLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat();
  }

  @override
  void didUpdateWidget(RadarLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _controller.duration = widget.period;
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? FN.acid;
    final bg = widget.backgroundColor ?? FN.night;
    final statusLabel =
        widget.label ?? 'MENCARI KOORDINAT GPS... [SATELLITE LOCKING]';

    return Semantics(
      label: statusLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Radar scope canvas
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _RadarScopePainter(
                animation: _controller,
                accent: accent,
                background: bg,
                lineColor: FN.nightLine,
                textColor: FN.onNight,
                mutedTextColor: FN.onNightMuted,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Status readout
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PulsingBeaconDot(accent: accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  statusLabel,
                  textAlign: TextAlign.center,
                  style: FN.monoStyle(
                    size: 11,
                    color: accent,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Optional Coordinates Readout
          if (widget.showCoordinates) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bg.withValues(alpha: 0.75),
                border: Border.all(color: FN.nightLine, width: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                'LAT: ${widget.lat}   LON: ${widget.lon}',
                style: FN.monoStyle(
                  size: 10.5,
                  color: FN.onNight,
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ],

          // Optional Satellite Constellation Telemetry
          if (widget.showTelemetry) ...[
            const SizedBox(height: 6),
            Text(
              widget.satsText,
              style: FN.monoStyle(
                size: 9.5,
                color: FN.onNightMuted,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Blinking/pulsing status dot beside the terminal label.
class _PulsingBeaconDot extends StatefulWidget {
  const _PulsingBeaconDot({required this.accent});

  final Color accent;

  @override
  State<_PulsingBeaconDot> createState() => _PulsingBeaconDotState();
}

class _PulsingBeaconDotState extends State<_PulsingBeaconDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        final scale = 0.8 + (_dotController.value * 0.4);
        final alpha = 0.5 + (_dotController.value * 0.5);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.accent.withValues(alpha: alpha),
              boxShadow: [
                BoxShadow(
                  color: widget.accent.withValues(alpha: alpha * 0.7),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CustomPainter that renders high-precision cartographic radar graphics.
class _RadarScopePainter extends CustomPainter {
  _RadarScopePainter({
    required this.animation,
    required this.accent,
    required this.background,
    required this.lineColor,
    required this.textColor,
    required this.mutedTextColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color accent;
  final Color background;
  final Color lineColor;
  final Color textColor;
  final Color mutedTextColor;

  // Fixed satellite constellation polar coordinates: (angleDeg, distanceRatio, label)
  static const _satellites = [
    (angleDeg: 42.0, distRatio: 0.45, label: 'S08'),
    (angleDeg: 198.0, distRatio: 0.72, label: 'S14'),
    (angleDeg: 308.0, distRatio: 0.60, label: 'S27'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    // Padding for azimuth labels/ticks
    final radarRadius = (math.min(size.width, size.height) / 2) - 10.0;
    if (radarRadius <= 0) return;

    // 1. Scope Disc Background
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          background.withValues(alpha: 0.95),
          background,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.4), background),
        ],
        stops: const [0.0, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radarRadius));
    canvas.drawCircle(center, radarRadius, bgPaint);

    // 2. Concentric Range Rings (500m, 1000m, 2000m)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = lineColor.withValues(alpha: 0.55);

    const ringFractions = [0.33, 0.66, 1.0];
    for (var i = 0; i < ringFractions.length; i++) {
      final r = radarRadius * ringFractions[i];
      if (i == ringFractions.length - 1) {
        ringPaint.strokeWidth = 1.2;
        ringPaint.color = lineColor.withValues(alpha: 0.9);
      }
      canvas.drawCircle(center, r, ringPaint);
    }

    // 3. Technical Crosshairs with Center Aperture
    final crossPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = lineColor.withValues(alpha: 0.7);

    const aperture = 8.0;
    // Horizontal
    canvas.drawLine(
      Offset(cx - radarRadius, cy),
      Offset(cx - aperture, cy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(cx + aperture, cy),
      Offset(cx + radarRadius, cy),
      crossPaint,
    );
    // Vertical
    canvas.drawLine(
      Offset(cx, cy - radarRadius),
      Offset(cx, cy - aperture),
      crossPaint,
    );
    canvas.drawLine(
      Offset(cx, cy + aperture),
      Offset(cx, cy + radarRadius),
      crossPaint,
    );

    // Azimuth ticks (every 30 degrees)
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = lineColor.withValues(alpha: 0.8);

    for (var deg = 0; deg < 360; deg += 30) {
      final rad = (deg * math.pi) / 180.0;
      final cosVal = math.cos(rad);
      final sinVal = math.sin(rad);
      final isCardinal = deg % 90 == 0;
      final tickLength = isCardinal ? 6.0 : 3.5;

      tickPaint.strokeWidth = isCardinal ? 1.2 : 0.8;
      canvas.drawLine(
        Offset(
          cx + cosVal * (radarRadius - tickLength),
          cy + sinVal * (radarRadius - tickLength),
        ),
        Offset(cx + cosVal * radarRadius, cy + sinVal * radarRadius),
        tickPaint,
      );
    }

    // 4. Sweep Angle (Clockwise from North)
    // 0 deg = North (top), so offset by -pi/2
    final sweepAngleRad = (animation.value * 2 * math.pi) - (math.pi / 2);
    final currentSweepDeg = (animation.value * 360.0) % 360.0;

    // 5. Phosphor Glow Tail (decaying sector behind the sweep needle)
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radarRadius)),
    );

    const tailAngleRad = math.pi * 0.30; // ~54 degree tail
    const segments = 16;
    final fanPaint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < segments; i++) {
      final t1 = i / segments;
      final t2 = (i + 1) / segments;
      final a1 = sweepAngleRad - (tailAngleRad * (1 - t1));
      final a2 = sweepAngleRad - (tailAngleRad * (1 - t2));
      final alpha = math.pow(t2, 2.2) * 0.18;

      fanPaint.color = accent.withValues(alpha: alpha);
      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radarRadius),
          a1,
          a2 - a1,
          false,
        )
        ..close();
      canvas.drawPath(path, fanPaint);
    }

    // 6. Sweep Needle (Crisp leading line)
    final needleEnd = Offset(
      cx + math.cos(sweepAngleRad) * radarRadius,
      cy + math.sin(sweepAngleRad) * radarRadius,
    );

    final needleGlowPaint = Paint()
      ..color = accent.withValues(alpha: 0.35)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(center, needleEnd, needleGlowPaint);

    final needlePaint = Paint()
      ..color = accent
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(center, needleEnd, needlePaint);

    canvas.restore();

    // 7. Satellites & Pulse Waves
    final blipPaint = Paint()..style = PaintingStyle.fill;
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final sat in _satellites) {
      // Sat angle from North (0° top)
      final satRad = ((sat.angleDeg - 90.0) * math.pi) / 180.0;
      final dist = radarRadius * sat.distRatio;
      final sx = cx + math.cos(satRad) * dist;
      final sy = cy + math.sin(satRad) * dist;
      final satPos = Offset(sx, sy);

      // Angle swept calculation: degrees since needle swept this satellite
      final degDiff = (currentSweepDeg - sat.angleDeg + 360.0) % 360.0;
      // Active hit window is ~75 degrees behind the sweep
      final isHit = degDiff >= 0 && degDiff < 75.0;
      final decay = isHit ? (1.0 - (degDiff / 75.0)) : 0.0;

      // Expanding pulse wave ring
      if (decay > 0) {
        final waveRadius = (1.0 - decay) * (radarRadius * 0.22);
        wavePaint.color = accent.withValues(alpha: decay * 0.65);
        canvas.drawCircle(satPos, waveRadius, wavePaint);

        // Blip glow halo
        blipPaint.color = accent.withValues(alpha: decay * 0.4);
        canvas.drawCircle(satPos, 5.0 + (decay * 3.0), blipPaint);
      }

      // Satellite diamond marker
      final blipColor =
          decay > 0 ? accent : mutedTextColor.withValues(alpha: 0.65);
      blipPaint.color = blipColor;

      const dSize = 2.5;
      final diamondPath = Path()
        ..moveTo(sx, sy - dSize)
        ..lineTo(sx + dSize, sy)
        ..lineTo(sx, sy + dSize)
        ..lineTo(sx - dSize, sy)
        ..close();
      canvas.drawPath(diamondPath, blipPaint);

      // Satellite label tag if size is large enough
      if (size.width >= 150) {
        final textSpan = TextSpan(
          text: sat.label,
          style: TextStyle(
            fontFamily: FN.mono,
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            color: decay > 0 ? accent : mutedTextColor.withValues(alpha: 0.5),
          ),
        );
        final tp = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(sx + 5, sy - 4));
      }
    }

    // 8. Center Fix Point (User GPS Origin)
    final centerGlow = Paint()
      ..color = accent.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.5, centerGlow);

    final centerDot = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5, centerDot);

    final centerRing = Paint()
      ..color = accent.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, 7.0, centerRing);
  }

  @override
  bool shouldRepaint(_RadarScopePainter oldDelegate) => true;
}
