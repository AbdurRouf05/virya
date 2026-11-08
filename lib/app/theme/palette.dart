import 'package:flutter/material.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/constants/sport_category.dart';

/// All visual tokens of one style. A style = one [Palette] instance
/// (see `styles/`). Widgets never read this directly; they use `FN.*`.
@immutable
class Palette {
  final String id;
  final String name;

  /// Satu kalimat di pemilih tampilan.
  final String description;

  /// Terang atau gelapnya halaman biasa (status bar ikut ini).
  final Brightness brightness;

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

  /// Teks/ikon di atas permukaan night, foto, atau peta. Selalu terang.
  final Color onNight;
  final Color onNightMuted;

  // Accents
  final Color signal;
  final Color acid;
  final Color ok;
  final Color warn;
  final Color caution; // amber: degraded state (weak GPS, near limit)

  /// Teks/ikon gelap di atas [signal] dan [acid]. Selalu gelap.
  final Color onAccent;

  final Map<SurfaceType, Color> surface;

  /// Climb colors for grade buckets: <3, <5, <8, <11, <15, >=15 (%).
  final List<Color> gradeRamp;

  /// Zona detak jantung Z1 sampai Z4; Z5 memakai [signal].
  final List<Color> hrZones;

  /// Warna per kategori olahraga (kalender, filter, legenda).
  final Map<SportCategory, Color> category;

  // Font families
  final String display;
  final String mono;
  final String sans;

  const Palette({
    required this.id,
    required this.name,
    required this.description,
    required this.brightness,
    required this.paper,
    required this.paperDeep,
    required this.paperLine,
    required this.ink,
    required this.inkSoft,
    required this.inkMuted,
    required this.night,
    required this.nightSurface,
    required this.nightLine,
    required this.onNight,
    required this.onNightMuted,
    required this.signal,
    required this.acid,
    required this.ok,
    required this.warn,
    required this.caution,
    required this.onAccent,
    required this.surface,
    required this.gradeRamp,
    required this.hrZones,
    required this.category,
    required this.display,
    required this.mono,
    required this.sans,
  });
}
