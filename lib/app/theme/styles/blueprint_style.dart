import 'package:flutter/material.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/constants/sport_category.dart';

/// "Cetak Biru": kertas biru pucat, tinta navy, aksen merah koral.
const blueprintStyle = Palette(
  id: 'blueprint',
  name: 'Cetak Biru',
  description: 'Biru pucat, tinta navy, aksen koral',
  brightness: Brightness.light,
  paper: Color(0xFFE8EEF2),
  paperDeep: Color(0xFFD8E1E8),
  paperLine: Color(0xFFBCC9D4),
  ink: Color(0xFF10243A),
  inkSoft: Color(0xFF2F4558),
  inkMuted: Color(0xFF5F7282),
  night: Color(0xFF0B1622),
  nightSurface: Color(0xFF14212F),
  nightLine: Color(0xFF26384A),
  onNight: Color(0xFFE8EEF2),
  onNightMuted: Color(0xFFBCC9D4),
  signal: Color(0xFFE8432E),
  acid: Color(0xFF7DF9FF),
  ok: Color(0xFF1F7A5C),
  warn: Color(0xFFC8321F),
  caution: Color(0xFFD99A2B),
  onAccent: Color(0xFF0B1622),
  surface: {
    SurfaceType.asphalt: Color(0xFF5F7282),
    SurfaceType.smoothGravel: Color(0xFFC9A227),
    SurfaceType.roughGravel: Color(0xFFB5541B),
    SurfaceType.dirt: Color(0xFF7A4E2D),
    SurfaceType.cobblestone: Color(0xFF7D8A96),
    SurfaceType.unknown: Color(0xFFA3B0BB),
  },
  category: {
    SportCategory.cycling: Color(0xFFE8432E),
    SportCategory.running: Color(0xFF10243A),
    SportCategory.walking: Color(0xFF1F7A5C),
    SportCategory.strength: Color(0xFF2F6FDB),
  },
  gradeRamp: [
    Color(0xFF2F4558),
    Color(0xFFD8B23A),
    Color(0xFFE8812A),
    Color(0xFFD9481B),
    Color(0xFFA3161B),
    Color(0xFF5B0E2D),
  ],
  hrZones: [
    Color(0xFFA9B6C2),
    Color(0xFF7D8A96),
    Color(0xFFD8B23A),
    Color(0xFFE8812A),
  ],
  display: 'Anton',
  mono: 'PlexMono',
  sans: 'PlexSans',
);
