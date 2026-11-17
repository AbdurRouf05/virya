import 'package:flutter/material.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/app/theme/styles/bersih_dark_style.dart';
import 'package:virya/app/theme/styles/bersih_style.dart';
import 'package:virya/app/theme/styles/blueprint_style.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/app/theme/styles/forest_style.dart';
import 'package:virya/app/theme/styles/night_style.dart';

/// Pilihan warna untuk gaya Tegas. To add a style: create one file in
/// this folder exporting a `const Palette`, then add it to [allStyles].
const allStyles = <Palette>[
  fieldNotesStyle,
  nightStyle,
  blueprintStyle,
  forestStyle,
];

/// Warna gaya Bersih (terang, gelap). Tidak ikut pilihan warna Tegas.
const bersihStyles = <Palette>[bersihStyle, bersihDarkStyle];

Palette styleById(String? id) =>
    allStyles.firstWhere((s) => s.id == id, orElse: () => fieldNotesStyle);

/// Palette aktif dari pengaturan: gaya Tegas memakai pilihan warna
/// [styleId]; gaya Bersih memakai [mode] (sistem mengikuti [platform]).
Palette resolveStyle({
  required String? styleId,
  required UiGaya gaya,
  BersihMode mode = BersihMode.terang,
  Brightness platform = Brightness.light,
}) {
  if (gaya == UiGaya.tegas) return styleById(styleId);
  final dark = switch (mode) {
    BersihMode.terang => false,
    BersihMode.gelap => true,
    BersihMode.sistem => platform == Brightness.dark,
  };
  return dark ? bersihDarkStyle : bersihStyle;
}
