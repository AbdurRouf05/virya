import 'package:flutter/material.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/constants/sport_category.dart';

/// "Bersih" terang: latar putih gading, kartu putih bergaris tipis, tinta
/// hampir hitam, oranye hanya untuk hal terpenting. Bukan pilihan warna
/// Tegas; dipilih lewat Gaya di pengaturan.
const bersihStyle = Palette(
  id: 'bersih',
  name: 'Bersih',
  description: 'Tenang, rapi, hanya yang penting',
  brightness: Brightness.light,
  gaya: UiGaya.bersih,
  paper: Color(0xFFF7F6F3),
  paperDeep: Color(0xFFF0EEEA),
  paperLine: Color(0xFFECEAE5),
  card: Color(0xFFFFFFFF),
  ink: Color(0xFF1B1B1A),
  inkSoft: Color(0xFF4F4D48),
  inkMuted: Color(0xFF8A8780),
  night: Color(0xFF141413),
  nightSurface: Color(0xFF1F1E1C),
  nightLine: Color(0xFF33322F),
  onNight: Color(0xFFF7F6F3),
  onNightMuted: Color(0xFFB5B2AB),
  signal: Color(0xFFFF4F00),
  acid: Color(0xFFFF7A3D),
  ok: Color(0xFF2E7D5B),
  warn: Color(0xFFD9481B),
  caution: Color(0xFFD9A030),
  onAccent: Color(0xFF1B1B1A),
  surface: {
    SurfaceType.asphalt: Color(0xFF6B6B66),
    SurfaceType.smoothGravel: Color(0xFFC9A227),
    SurfaceType.roughGravel: Color(0xFFB5541B),
    SurfaceType.dirt: Color(0xFF7A4E2D),
    SurfaceType.cobblestone: Color(0xFF8A7F72),
    SurfaceType.unknown: Color(0xFFB8B4AC),
  },
  category: {
    SportCategory.cycling: Color(0xFFFF4F00),
    SportCategory.running: Color(0xFF1B1B1A),
    SportCategory.walking: Color(0xFF2E7D5B),
    SportCategory.strength: Color(0xFF4A63C9),
  },
  gradeRamp: [
    Color(0xFF4F4D48),
    Color(0xFFD8B23A),
    Color(0xFFE8812A),
    Color(0xFFD9481B),
    Color(0xFFA3161B),
    Color(0xFF5B0E2D),
  ],
  hrZones: [
    Color(0xFFC9C6BF),
    Color(0xFF8A8780),
    Color(0xFFD8B23A),
    Color(0xFFE8812A),
  ],
  display: 'PlexSans',
  mono: 'PlexMono',
  sans: 'PlexSans',
);
