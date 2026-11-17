import 'package:flutter/material.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/constants/sport_category.dart';

/// "Bersih" gelap: hitam hangat, kartu sedikit lebih terang, garis tipis,
/// aksen oranye yang sama.
const bersihDarkStyle = Palette(
  id: 'bersih_gelap',
  name: 'Bersih gelap',
  description: 'Tenang dan gelap',
  brightness: Brightness.dark,
  gaya: UiGaya.bersih,
  paper: Color(0xFF141413),
  paperDeep: Color(0xFF242321),
  paperLine: Color(0xFF2C2B28),
  card: Color(0xFF1C1B19),
  ink: Color(0xFFEDEBE6),
  inkSoft: Color(0xFFC4C1BA),
  inkMuted: Color(0xFF8F8C85),
  night: Color(0xFF0C0C0B),
  nightSurface: Color(0xFF1A1918),
  nightLine: Color(0xFF2E2D2A),
  onNight: Color(0xFFF7F6F3),
  onNightMuted: Color(0xFFB5B2AB),
  signal: Color(0xFFFF5A14),
  acid: Color(0xFFFF8A4C),
  ok: Color(0xFF5BBF84),
  warn: Color(0xFFFF6B3D),
  caution: Color(0xFFE8B23A),
  onAccent: Color(0xFF141413),
  surface: {
    SurfaceType.asphalt: Color(0xFF9A9A92),
    SurfaceType.smoothGravel: Color(0xFFD8B23A),
    SurfaceType.roughGravel: Color(0xFFE0763A),
    SurfaceType.dirt: Color(0xFFB98255),
    SurfaceType.cobblestone: Color(0xFFB5AA9C),
    SurfaceType.unknown: Color(0xFF6F6C66),
  },
  category: {
    SportCategory.cycling: Color(0xFFFF5A14),
    SportCategory.running: Color(0xFFEDEBE6),
    SportCategory.walking: Color(0xFF5BBF84),
    SportCategory.strength: Color(0xFF8095F0),
  },
  gradeRamp: [
    Color(0xFFC4C1BA),
    Color(0xFFD8B23A),
    Color(0xFFE8812A),
    Color(0xFFFF6B3D),
    Color(0xFFE5484D),
    Color(0xFFE0527A),
  ],
  hrZones: [
    Color(0xFF5E5B55),
    Color(0xFF8F8C85),
    Color(0xFFD8B23A),
    Color(0xFFE8812A),
  ],
  display: 'PlexSans',
  mono: 'PlexMono',
  sans: 'PlexSans',
);
