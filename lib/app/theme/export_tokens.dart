import 'package:flutter/material.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/core/constants/enums.dart';

/// Token untuk gambar dan video yang keluar dari aplikasi (kartu share, recap,
/// timelapse). Selalu Field Notes, apa pun style yang aktif, supaya hasil
/// bagikan konsisten. Layar biasa tetap memakai `FN.*`.
class FNExport {
  FNExport._();

  static const _p = fieldNotesStyle;

  static Color get paper => _p.paper;
  static Color get paperDeep => _p.paperDeep;
  static Color get paperLine => _p.paperLine;
  static Color get ink => _p.ink;
  static Color get inkSoft => _p.inkSoft;
  static Color get inkMuted => _p.inkMuted;
  static Color get night => _p.night;
  static Color get nightSurface => _p.nightSurface;
  static Color get nightLine => _p.nightLine;
  static Color get signal => _p.signal;
  static Color get acid => _p.acid;
  static Color get warn => _p.warn;

  static Map<SurfaceType, Color> get surface => _p.surface;

  static Color grade(double pct) {
    final r = _p.gradeRamp;
    if (pct < 3) return r[0];
    if (pct < 5) return r[1];
    if (pct < 8) return r[2];
    if (pct < 11) return r[3];
    if (pct < 15) return r[4];
    return r[5];
  }

  static String get display => _p.display;
  static String get mono => _p.mono;
  static String get sans => _p.sans;

  static TextStyle bigNumber(double size, {Color? color}) => TextStyle(
    fontFamily: display,
    fontSize: size,
    height: 0.95,
    color: color ?? ink,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle label({double size = 11, Color? color}) => TextStyle(
    fontFamily: mono,
    fontSize: size,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w500,
    color: color ?? inkMuted,
  );
}
