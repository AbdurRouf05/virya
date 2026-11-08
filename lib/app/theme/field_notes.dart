import 'package:flutter/material.dart';
import 'package:stravo/core/constants/enums.dart';

/// SHARED CONTRACT — "Field Notes / Topo Brutalist" visual identity.
///
/// Expedition-notebook look: cream paper, black ink, one loud safety-orange
/// accent, contour-line textures, condensed poster numerals, mono labels.
/// Night variant (ink background) is used while recording (OLED friendly).
/// Extend freely; do not rename existing tokens.
class FN {
  FN._();

  // Paper (day)
  static const paper = Color(0xFFEFE9DC);
  static const paperDeep = Color(0xFFE3DBC9);
  static const paperLine = Color(0xFFCFC6B2); // grid / contour lines on paper

  // Ink
  static const ink = Color(0xFF141414);
  static const inkSoft = Color(0xFF3A3A36);
  static const inkMuted = Color(0xFF77736A);

  // Night (recording, dark cards)
  static const night = Color(0xFF0E0E0C);
  static const nightSurface = Color(0xFF1A1A17);
  static const nightLine = Color(0xFF2E2E29);

  // Accents
  static const signal = Color(0xFFFF4F00); // safety orange — the one loud color
  static const acid = Color(0xFFC6FF00); // highlight on night backgrounds only
  static const ok = Color(0xFF2F7D4F);
  static const warn = Color(0xFFD9481B);

  // Surface ramp
  static const Map<SurfaceType, Color> surface = {
    SurfaceType.asphalt: Color(0xFF6B6B66),
    SurfaceType.smoothGravel: Color(0xFFC9A227),
    SurfaceType.roughGravel: Color(0xFFB5541B),
    SurfaceType.dirt: Color(0xFF7A4E2D),
    SurfaceType.cobblestone: Color(0xFF8A7F72),
    SurfaceType.unknown: Color(0xFFA9A49A),
  };

  /// Gradient color for a grade in percent (climb index).
  static Color grade(double pct) {
    if (pct < 3) return inkSoft;
    if (pct < 5) return const Color(0xFFD8B23A);
    if (pct < 8) return const Color(0xFFE8812A);
    if (pct < 11) return const Color(0xFFD9481B);
    if (pct < 15) return const Color(0xFFA3161B);
    return const Color(0xFF5B0E2D);
  }

  // Font families (bundled in assets/fonts, fully offline)
  static const display = 'Anton'; // condensed poster numerals & titles
  static const mono = 'PlexMono'; // labels, units, data
  static const sans = 'PlexSans'; // body text

  static const tabular = [FontFeature.tabularFigures()];

  static TextStyle bigNumber(double size, {Color color = ink}) => TextStyle(
        fontFamily: display,
        fontSize: size,
        height: 0.95,
        color: color,
        fontFeatures: tabular,
      );

  static TextStyle label({double size = 11, Color color = inkMuted}) =>
      TextStyle(
        fontFamily: mono,
        fontSize: size,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
