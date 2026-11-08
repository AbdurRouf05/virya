import 'package:flutter/material.dart';
import 'package:virya/core/constants/enums.dart';

/// All visual tokens of one style. A style = one [Palette] instance
/// (see `styles/`). Widgets never read this directly; they use `FN.*`.
@immutable
class Palette {
  final String id;
  final String name;

  // Day surfaces
  final Color paper;
  final Color paperDeep;
  final Color paperLine;

  // Text / strokes
  final Color ink;
  final Color inkSoft;
  final Color inkMuted;

  // Night surfaces (recording, dark cards)
  final Color night;
  final Color nightSurface;
  final Color nightLine;

  // Accents
  final Color signal;
  final Color acid;
  final Color ok;
  final Color warn;
  final Color caution; // amber: degraded state (weak GPS, near limit)

  final Map<SurfaceType, Color> surface;

  /// Climb colors for grade buckets: <3, <5, <8, <11, <15, >=15 (%).
  final List<Color> gradeRamp;

  // Font families
  final String display;
  final String mono;
  final String sans;

  const Palette({
    required this.id,
    required this.name,
    required this.paper,
    required this.paperDeep,
    required this.paperLine,
    required this.ink,
    required this.inkSoft,
    required this.inkMuted,
    required this.night,
    required this.nightSurface,
    required this.nightLine,
    required this.signal,
    required this.acid,
    required this.ok,
    required this.warn,
    required this.caution,
    required this.surface,
    required this.gradeRamp,
    required this.display,
    required this.mono,
    required this.sans,
  });
}
