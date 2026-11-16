import 'dart:async';

import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/widgets/virya_mark.dart';
import 'package:virya/features/splash/presentation/look_gate.dart';

/// Layar pembuka: hanya logo Virya di tengah, lanjutan langsung dari splash
/// Android (`res/drawable/splash_icon.xml`, logo 120dp di tengah layar)
/// supaya perpindahannya tidak terasa. Tahan sebentar lalu memudar ke
/// [target]; sentuh di mana saja untuk langsung lanjut.
class EntryLoadingScreen extends StatefulWidget {
  const EntryLoadingScreen({
    super.key,
    this.target = const LookGate(),
    this.hold = const Duration(milliseconds: 700),
  });

  final Widget target;

  /// Lama logo ditahan sebelum memudar ke [target].
  final Duration hold;

  /// Lebar logo, sama dengan logo splash Android.
  static const double markSize = 120;

  static const Duration fade = Duration(milliseconds: 450);

  @override
  State<EntryLoadingScreen> createState() => _EntryLoadingScreenState();
}

class _EntryLoadingScreenState extends State<EntryLoadingScreen> {
  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.hold, _proceed);
  }

  void _proceed() {
    if (_leaving || !mounted) return;
    _leaving = true;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => widget.target,
        transitionDuration: EntryLoadingScreen.fade,
        transitionsBuilder:
            (_, animation, __, child) => FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FN.paper,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceed,
        child: Center(
          child: ViryaMark(
            size: EntryLoadingScreen.markSize,
            ink: FN.ink,
            accent: FN.signal,
          ),
        ),
      ),
    );
  }
}
