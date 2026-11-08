import 'dart:ui';

import 'package:virya/app/theme/field_notes.dart';

/// Colors for the Topo-Ink renderer.
class TopoInkStyle {
  final Color? background;
  final Color ground;
  final Color rim;
  final Color grid;
  final Color contour;
  final Color shadow;
  final Color curtain;
  final Color ribbon;
  final Color accent;
  final Color head;
  final bool glow;

  const TopoInkStyle({
    this.background,
    required this.ground,
    required this.rim,
    required this.grid,
    required this.contour,
    required this.shadow,
    required this.curtain,
    required this.ribbon,
    required this.accent,
    required this.head,
    this.glow = true,
  });

  /// [accent] defaults to `FN.acid`.
  factory TopoInkStyle.night({Color? accent, bool background = true}) =>
      TopoInkStyle(
        background: background ? FN.night : null,
        ground: const Color(0xFF151513),
        rim: const Color(0xFF55554C),
        grid: const Color(0xFF26261F),
        contour: const Color(0xFF2E2E27),
        shadow: const Color(0x66000000),
        curtain: const Color(0x40EFE9DC),
        ribbon: const Color(0x80EFE9DC),
        accent: accent ?? FN.acid,
        head: FN.paper,
      );

  /// [accent] defaults to `FN.signal`.
  factory TopoInkStyle.paper({Color? accent, bool background = true}) =>
      TopoInkStyle(
        background: background ? FN.paper : null,
        ground: FN.paperDeep,
        rim: FN.inkSoft,
        grid: const Color(0x30141414),
        contour: FN.paperLine,
        shadow: const Color(0x30141414),
        curtain: const Color(0x55141414),
        ribbon: FN.ink,
        accent: accent ?? FN.signal,
        head: FN.ink,
        glow: false,
      );
}
