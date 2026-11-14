import 'dart:async';
import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/widgets/virya_mark.dart';
import 'package:virya/features/home/presentation/home_shell.dart';

/// Interactive splash & entry loading screen matching the Field Notes technical design system.
///
/// Features:
/// - 32px technical grid on dark ground (`FN.night`).
/// - Official 5-block stepped chevron mark (`ViryaMark`).
/// - Realtime animated checklist log with progress bar.
/// - Tap-to-skip functionality allowing immediate entry into the app.
class EntryLoadingScreen extends StatefulWidget {
  final Widget target;
  final Duration totalDuration;

  const EntryLoadingScreen({
    super.key,
    this.target = const HomeShell(),
    this.totalDuration = const Duration(milliseconds: 2300),
  });

  @override
  State<EntryLoadingScreen> createState() => _EntryLoadingScreenState();
}

class _EntryLoadingScreenState extends State<EntryLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _progress;

  bool _step1 = false;
  bool _step2 = false;
  bool _step3 = false;
  bool _transitioning = false;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: widget.totalDuration,
    );

    _progress = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeInOutCubic,
    );

    _anim.forward();

    // Sequence the technical checkmarks
    _timers.add(Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _step1 = true);
    }));
    _timers.add(Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _step2 = true);
    }));
    _timers.add(Timer(const Duration(milliseconds: 1750), () {
      if (mounted) setState(() => _step3 = true);
    }));

    // Transition to Home
    _timers.add(Timer(widget.totalDuration, _proceed));
  }

  void _proceed() {
    if (_transitioning || !mounted) return;
    _transitioning = true;
    for (final t in _timers) {
      t.cancel();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => widget.target,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          final curve =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FN.night,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceed,
        child: Stack(
          children: [
            // 32px Technical grid
            const Positioned.fill(child: _GridPattern()),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top technical badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _MetaTag(text: 'SYS//INIT 1.0.3'),
                        _StampBadge(text: 'OFFLINE-FIRST'),
                        _MetaTag(text: '50Hz SENSORS'),
                      ],
                    ),

                    // Center Brand Area with Official ViryaMark
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ViryaMark(
                          size: 96,
                          ink: FN.onNight,
                          accent: FN.signal,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'VIRYA',
                          style: TextStyle(
                            fontFamily: FN.display,
                            fontSize: 54,
                            letterSpacing: 2,
                            height: 0.95,
                            color: FN.onNight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PERSONAL FIELD TRACKER',
                          style: FN.label(size: 10, color: FN.onNightMuted).copyWith(
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Bottom progress bar and checklist
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Thin neon progress bar
                        AnimatedBuilder(
                          animation: _progress,
                          builder: (_, __) => Container(
                            height: 3,
                            width: double.infinity,
                            color: FN.nightLine,
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _progress.value.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FN.acid,
                                  boxShadow: [
                                    BoxShadow(
                                      color: FN.acid.withValues(alpha: 0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Terminal logs
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LogItem(
                                show: _step1,
                                tag: '[OK]',
                                text: 'MENGHUBUNGKAN SQLITE DRIFT...',
                              ),
                              const SizedBox(height: 5),
                              _LogItem(
                                show: _step2,
                                tag: '[OK]',
                                text: 'VERIFIKASI PMTILES VECTOR MAP...',
                              ),
                              const SizedBox(height: 5),
                              _LogItem(
                                show: _step3,
                                tag: '[READY]',
                                text: 'MEMASUKI INSTRUMEN LAPANGAN',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          '[ SENTUH UNTUK LEWATI ]',
                          style: FN.label(size: 9, color: FN.onNightMuted).copyWith(
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final bool show;
  final String tag;
  final String text;

  const _LogItem({
    required this.show,
    required this.tag,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: show ? 1.0 : 0.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: FN.label(size: 10, color: FN.acid).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: FN.label(size: 10, color: FN.onNightMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final String text;
  const _MetaTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: FN.nightSurface.withValues(alpha: 0.6),
        border: Border.all(color: FN.nightLine),
      ),
      child: Text(text, style: FN.label(size: 9, color: FN.onNightMuted)),
    );
  }
}

class _StampBadge extends StatelessWidget {
  final String text;
  const _StampBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.05,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: FN.signal, width: 1.5),
        ),
        child: Text(
          text,
          style: FN.label(size: 9, color: FN.signal).copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _GridPattern extends StatelessWidget {
  const _GridPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPatternPainter(FN.nightLine),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  final Color color;
  const _GridPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
