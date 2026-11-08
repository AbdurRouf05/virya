import 'package:flutter/material.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/constants/sport_category.dart';

/// "Malam": halaman gelap, tinta krem, aksen oranye tetap sama.
const nightStyle = Palette(
  id: 'night',
  name: 'Malam',
  description: 'Gelap dan tenang untuk mata',
  brightness: Brightness.dark,
  paper: Color(0xFF15140F),
  paperDeep: Color(0xFF211F19),
  paperLine: Color(0xFF36332B),
  ink: Color(0xFFEDE7D9),
  inkSoft: Color(0xFFC9C3B5),
  inkMuted: Color(0xFF9A958A),
  night: Color(0xFF0B0A08),
  nightSurface: Color(0xFF1A1914),
  nightLine: Color(0xFF2E2C25),
  onNight: Color(0xFFEFE9DC),
  onNightMuted: Color(0xFFCFC6B2),
  signal: Color(0xFFFF5A14),
  acid: Color(0xFFC6FF00),
  ok: Color(0xFF5BBF84),
  warn: Color(0xFFFF6B3D),
  caution: Color(0xFFE8B23A),
  onAccent: Color(0xFF141414),
  surface: {
    SurfaceType.asphalt: Color(0xFF9A9A92),
    SurfaceType.smoothGravel: Color(0xFFD8B23A),
    SurfaceType.roughGravel: Color(0xFFE0763A),
    SurfaceType.dirt: Color(0xFFB98255),
    SurfaceType.cobblestone: Color(0xFFB5AA9C),
    SurfaceType.unknown: Color(0xFF7A766C),
  },
  category: {
    SportCategory.cycling: Color(0xFFFF5A14),
    SportCategory.running: Color(0xFFEDE7D9),
    SportCategory.walking: Color(0xFF5BBF84),
    SportCategory.strength: Color(0xFF7C93F0),
  },
  gradeRamp: [
    Color(0xFFC9C3B5),
    Color(0xFFD8B23A),
    Color(0xFFE8812A),
    Color(0xFFFF6B3D),
    Color(0xFFE5484D),
    Color(0xFFE0527A),
  ],
  display: 'Anton',
  mono: 'PlexMono',
  sans: 'PlexSans',
);
