import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:stravo/app/theme/field_notes.dart';

/// Output formats. Cards are laid out at 360 logical px wide and exported
/// with pixelRatio = width / 360, giving exact pixel sizes.
enum CardFormat {
  story(1080, 1920, 'STORY 9:16'),
  feed(1080, 1350, 'FEED 4:5'),
  square(1080, 1080, 'KOTAK 1:1');

  const CardFormat(this.pixelWidth, this.pixelHeight, this.label);
  final int pixelWidth;
  final int pixelHeight;
  final String label;

  static const logicalWidth = 360.0;
  double get pixelRatio => pixelWidth / logicalWidth;
  Size get logicalSize =>
      Size(logicalWidth, logicalWidth * pixelHeight / pixelWidth);
}

enum CardTemplate {
  fieldNotes('FIELD NOTES'),
  sektor('SEKTOR'),
  profil('PROFIL'),
  nightInk('NIGHT INK'),
  sticker('STICKER'),
  foto('FOTO');

  const CardTemplate(this.label);
  final String label;

  bool get isDark => this == nightInk;
  bool get isTransparent => this == sticker;
}

/// Optional stats (distance is always shown big).
enum ShareStat {
  time('WAKTU'),
  elevation('ELEV'),
  speed('RATA2'),
  grit('GRIT'),
  heartRate('HR');

  const ShareStat(this.label);
  final String label;
}

/// Panjang video. Intro (1.5 dtk) + outro (2.5 dtk) = 4 dtk tetap.
enum RecapLength {
  auto('OTOMATIS'),
  s15('15 DTK'),
  s30('30 DTK'),
  s60('60 DTK');

  const RecapLength(this.label);
  final String label;

  /// Detik untuk adegan rute (tanpa intro/outro).
  double routeSeconds(double distanceM) => switch (this) {
        RecapLength.auto => (distanceM / 1000 * 0.55).clamp(10.0, 55.0),
        RecapLength.s15 => 11,
        RecapLength.s30 => 26,
        RecapLength.s60 => 56,
      };

  /// Total detik video.
  double totalSeconds(double distanceM) => routeSeconds(distanceM) + 4;
}

enum AccentChoice {
  signal('SIGNAL'),
  acid('ACID'),
  ink('TINTA');

  const AccentChoice(this.label);
  final String label;

  /// Acid stays on dark grounds only; on paper it becomes a readable olive.
  Color resolve({required bool dark}) => switch (this) {
        AccentChoice.signal => FN.signal,
        AccentChoice.acid => dark ? FN.acid : const Color(0xFF5E7A00),
        AccentChoice.ink => dark ? FN.paper : FN.ink,
      };

  Color get swatch => switch (this) {
        AccentChoice.signal => FN.signal,
        AccentChoice.acid => FN.acid,
        AccentChoice.ink => FN.ink,
      };
}

class ShareOptions {
  final CardFormat format;
  final AccentChoice accent;
  final Set<ShareStat> stats;

  /// Decoded background photo for the FOTO template.
  final ui.Image? photo;

  const ShareOptions({
    this.format = CardFormat.story,
    this.accent = AccentChoice.signal,
    this.stats = const {
      ShareStat.time,
      ShareStat.elevation,
      ShareStat.speed,
      ShareStat.grit,
    },
    this.photo,
  });

  ShareOptions copyWith({
    CardFormat? format,
    AccentChoice? accent,
    Set<ShareStat>? stats,
    ui.Image? photo,
    bool clearPhoto = false,
  }) =>
      ShareOptions(
        format: format ?? this.format,
        accent: accent ?? this.accent,
        stats: stats ?? this.stats,
        photo: clearPhoto ? null : (photo ?? this.photo),
      );
}
