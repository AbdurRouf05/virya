import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/home/presentation/home_shell.dart';

/// Field Notes Expedition Splash Screen.
/// Displays cartographic grid, rotating telemetry compass, brandmark, and
/// system calibration status before transitioning to [HomeShell].
class SplashScreen extends StatefulWidget {
  final Widget? nextScreen;
  final Duration duration;
  final bool autoNavigate;

  const SplashScreen({
    super.key,
    this.nextScreen,
    this.duration = const Duration(milliseconds: 2200),
    this.autoNavigate = true,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotationAnimation;

  final List<String> _stages = const [
    'INIT SENSOR FUSION ENGINE...',
    'CALIBRATING BAROMETRIC ALTIMETER...',
    'ACQUIRING 3D GPS LOCK · TOPO READY',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    _rotationAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.85, curve: Curves.easeInOutCubic),
    );

    _controller.forward();

    if (widget.autoNavigate) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _navigateToNext();
        }
      });
    }
  }

  void _navigateToNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, secAnim) =>
            widget.nextScreen ?? const HomeShell(),
        transitionsBuilder: (ctx, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FN.paper,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToNext,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;
            final stageIndex = (progress * _stages.length).floor().clamp(
              0,
              _stages.length - 1,
            );
            final currentStage = _stages[stageIndex];

            return Stack(
              children: [
                // Cartographic expedition grid background
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CartographicGridPainter(
                      lineColor: FN.paperLine,
                      textColor: FN.inkMuted,
                    ),
                  ),
                ),

                // Top Header Info
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'VIRYA · FIELD NOTES EDITION',
                          style: FN.monoStyle(
                            size: 10,
                            color: FN.ink,
                            weight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'STATION ID: 08-YGY',
                          style: FN.monoStyle(
                            size: 10,
                            color: FN.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Brandmark and Compass Reticle
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Reticle Compass
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CustomPaint(
                            painter: _CompassReticlePainter(
                              progress: progress,
                              rotation: _rotationAnimation.value,
                              ringColor: FN.ink,
                              accentColor: FN.signal,
                              gridColor: FN.paperLine,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Brand Title
                        Text(
                          'VIRYA',
                          style: TextStyle(
                            fontFamily: FN.display,
                            fontSize: 48,
                            letterSpacing: 3.0,
                            color: FN.ink,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          'OFFLINE EXPEDITION & TELEMETRY',
                          style: FN.monoStyle(
                            size: 11,
                            color: FN.inkSoft,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Calibration Progress & Coordinates
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 32,
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Progress Percentage & Active Stage
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentStage,
                              style: FN.monoStyle(
                                size: 10,
                                color: FN.ink,
                                weight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: FN.monoStyle(
                                size: 10,
                                color: FN.signal,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Segmented / Continuous progress indicator
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: FN.paperLine,
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress.clamp(0.02, 1.0),
                            child: Container(
                              color: FN.ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Geographic Coordinate Stamp
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '7°47\'29.0"S 110°22\'18.0"E',
                              style: FN.monoStyle(
                                size: 9.5,
                                color: FN.inkMuted,
                              ),
                            ),
                            Text(
                              'TAP UNTUK LEWATI →',
                              style: FN.monoStyle(
                                size: 9,
                                color: FN.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for Field Notes cartographic coordinate grid.
class _CartographicGridPainter extends CustomPainter {
  final Color lineColor;
  final Color textColor;

  const _CartographicGridPainter({
    required this.lineColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.6)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const step = 48.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Corner tick crosshairs
    final crossPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5;

    void drawCross(double cx, double cy) {
      canvas.drawLine(Offset(cx - 8, cy), Offset(cx + 8, cy), crossPaint);
      canvas.drawLine(Offset(cx, cy - 8), Offset(cx, cy + 8), crossPaint);
    }

    drawCross(24, 24);
    drawCross(size.width - 24, 24);
    drawCross(24, size.height - 24);
    drawCross(size.width - 24, size.height - 24);
  }

  @override
  bool shouldRepaint(covariant _CartographicGridPainter oldDelegate) => false;
}

/// Custom painter for the rotating expedition telemetry compass reticle.
class _CompassReticlePainter extends CustomPainter {
  final double progress;
  final double rotation;
  final Color ringColor;
  final Color accentColor;
  final Color gridColor;

  const _CompassReticlePainter({
    required this.progress,
    required this.rotation,
    required this.ringColor,
    required this.accentColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final outerPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Outer circle ring
    canvas.drawCircle(center, radius, outerPaint);

    // Inner subtle guide ring
    final innerPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, radius * 0.72, innerPaint);

    // Compass degree ticks (36 ticks = every 10 degrees)
    for (int i = 0; i < 36; i++) {
      final angle = (i * 10) * math.pi / 180.0;
      final isMajor = i % 9 == 0; // 0, 90, 180, 270
      final tickLength = isMajor ? 9.0 : 4.0;
      final tickPaint = Paint()
        ..color = isMajor ? ringColor : ringColor.withValues(alpha: 0.4)
        ..strokeWidth = isMajor ? 1.5 : 1.0;

      final p1 = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Rotating needle & North marker
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 2 * math.pi);

    // North arrow triangle (Signal Orange)
    final northPath = Path()
      ..moveTo(0, -radius * 0.7)
      ..lineTo(6, -radius * 0.3)
      ..lineTo(-6, -radius * 0.3)
      ..close();
    canvas.drawPath(
      northPath,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill,
    );

    // South arrow triangle (Ink)
    final southPath = Path()
      ..moveTo(0, radius * 0.7)
      ..lineTo(6, radius * 0.3)
      ..lineTo(-6, radius * 0.3)
      ..close();
    canvas.drawPath(
      southPath,
      Paint()
        ..color = ringColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill,
    );

    // Center pivot dot
    canvas.drawCircle(Offset.zero, 3.5, Paint()..color = ringColor);
    canvas.drawCircle(Offset.zero, 1.5, Paint()..color = FN.paper);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassReticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.ringColor != ringColor;
  }
}
