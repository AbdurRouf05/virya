import 'package:flutter/material.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/constants/sport_category.dart';

/// "Hutan": kertas hijau pucat, tinta hijau tua, aksen karat.
const forestStyle = Palette(
  id: 'forest',
  name: 'Hutan',
  description: 'Hijau pucat, tinta hutan, aksen karat',
  brightness: Brightness.light,
  paper: Color(0xFFE9EADB),
  paperDeep: Color(0xFFDCDEC9),
  paperLine: Color(0xFFC2C6AC),
  ink: Color(0xFF1B2A1E),
  inkSoft: Color(0xFF39493A),
  inkMuted: Color(0xFF677264),
  night: Color(0xFF0F1710),
  nightSurface: Color(0xFF1A241B),
  nightLine: Color(0xFF2D3A2E),
  onNight: Color(0xFFE9EADB),
  onNightMuted: Color(0xFFC2C6AC),
  signal: Color(0xFFD4601F),
  acid: Color(0xFFD9F05A),
  ok: Color(0xFF3E7A3A),
  warn: Color(0xFFB93A1F),
  caution: Color(0xFFD49A2A),
  onAccent: Color(0xFF0F1710),
  surface: {
    SurfaceType.asphalt: Color(0xFF6B6F63),
    SurfaceType.smoothGravel: Color(0xFFC9A227),
    SurfaceType.roughGravel: Color(0xFFB5541B),
    SurfaceType.dirt: Color(0xFF7A4E2D),
    SurfaceType.cobblestone: Color(0xFF8A8672),
    SurfaceType.unknown: Color(0xFFA7A993),
  },
  category: {
    SportCategory.cycling: Color(0xFFD4601F),
    SportCategory.running: Color(0xFF1B2A1E),
    SportCategory.walking: Color(0xFF3E7A3A),
    SportCategory.strength: Color(0xFF4A5FB0),
  },
  gradeRamp: [
    Color(0xFF39493A),
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
