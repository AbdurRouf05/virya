import 'package:flutter/material.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/core/constants/enums.dart';

/// "Field Notes / Topo Brutalist": cream paper, black ink, one loud
/// safety-orange accent, condensed poster numerals, mono labels.
const fieldNotesStyle = Palette(
  id: 'field_notes',
  name: 'Field Notes',
  paper: Color(0xFFEFE9DC),
  paperDeep: Color(0xFFE3DBC9),
  paperLine: Color(0xFFCFC6B2),
  ink: Color(0xFF141414),
  inkSoft: Color(0xFF3A3A36),
  inkMuted: Color(0xFF77736A),
  night: Color(0xFF0E0E0C),
  nightSurface: Color(0xFF1A1A17),
  nightLine: Color(0xFF2E2E29),
  signal: Color(0xFFFF4F00),
  acid: Color(0xFFC6FF00),
  ok: Color(0xFF2F7D4F),
  warn: Color(0xFFD9481B),
  caution: Color(0xFFE8B23A),
  surface: {
    SurfaceType.asphalt: Color(0xFF6B6B66),
    SurfaceType.smoothGravel: Color(0xFFC9A227),
    SurfaceType.roughGravel: Color(0xFFB5541B),
    SurfaceType.dirt: Color(0xFF7A4E2D),
    SurfaceType.cobblestone: Color(0xFF8A7F72),
    SurfaceType.unknown: Color(0xFFA9A49A),
  },
  gradeRamp: [
    Color(0xFF3A3A36),
    Color(0xFFD8B23A),
    Color(0xFFE8812A),
    Color(0xFFD9481B),
    Color(0xFFA3161B),
    Color(0xFF5B0E2D),
  ],
  display: 'Anton',
  mono: 'PlexMono',
  sans: 'PlexSans',
);
