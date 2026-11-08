import 'package:flutter/material.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/constants/sport_category.dart';

/// Design tokens used by every widget. Values come from the active
/// [Palette] (see `styles/`), so tokens are NOT const — never use `FN.*`
/// inside a `const` expression. Change style with [FN.use].
class FN {
  FN._();

  static Palette _p = fieldNotesStyle;
  static Palette get palette => _p;

  /// Switch the active style. Caller must rebuild the app afterwards.
  static void use(Palette p) => _p = p;

  // Paper (day)
  static Color get paper => _p.paper;
  static Color get paperDeep => _p.paperDeep;
  static Color get paperLine => _p.paperLine; // grid / contour lines

  // Ink
  static Color get ink => _p.ink;
  static Color get inkSoft => _p.inkSoft;
  static Color get inkMuted => _p.inkMuted;

  // Night (recording, dark cards)
  static Color get night => _p.night;
  static Color get nightSurface => _p.nightSurface;
  static Color get nightLine => _p.nightLine;

  // Accents
  static Color get signal => _p.signal; // the one loud color
  static Color get acid => _p.acid; // highlight on night backgrounds only
  static Color get ok => _p.ok;
  static Color get warn => _p.warn;
  static Color get caution => _p.caution;
  static Color category(SportCategory c) => _p.category[c]!;

  static Map<SurfaceType, Color> get surface => _p.surface;

  /// Color for a grade in percent (climb index).
  static Color grade(double pct) {
    final r = _p.gradeRamp;
    if (pct < 3) return r[0];
    if (pct < 5) return r[1];
    if (pct < 8) return r[2];
    if (pct < 11) return r[3];
    if (pct < 15) return r[4];
    return r[5];
  }

  // Font families (bundled in assets/fonts, fully offline)
  static String get display => _p.display; // poster numerals & titles
  static String get mono => _p.mono; // labels, units, data
  static String get sans => _p.sans; // body text

  static const tabular = [FontFeature.tabularFigures()];

  static TextStyle bigNumber(double size, {Color? color}) => TextStyle(
    fontFamily: display,
    fontSize: size,
    height: 0.95,
    color: color ?? ink,
    fontFeatures: tabular,
  );

  static TextStyle label({double size = 11, Color? color}) => TextStyle(
    fontFamily: mono,
    fontSize: size,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w500,
    color: color ?? inkMuted,
  );
}
