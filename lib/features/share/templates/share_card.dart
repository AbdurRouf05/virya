import 'package:flutter/material.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/features/share/domain/share_data.dart';
import 'package:stravo/features/share/domain/share_options.dart';
import 'package:stravo/features/share/templates/field_notes_card.dart';
import 'package:stravo/features/share/templates/foto_card.dart';
import 'package:stravo/features/share/templates/night_ink_card.dart';
import 'package:stravo/features/share/templates/profil_card.dart';
import 'package:stravo/features/share/templates/sektor_card.dart';
import 'package:stravo/features/share/templates/sticker_card.dart';

/// Renders [template] at the exact logical size of the chosen format
/// (360 px wide). Wrap in a RepaintBoundary and export with
/// `pixelRatio: options.format.pixelRatio`.
class ShareCard extends StatelessWidget {
  final ShareData data;
  final CardTemplate template;
  final ShareOptions options;
  const ShareCard({
    super.key,
    required this.data,
    required this.template,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.maybeOf(context) ?? const MediaQueryData();
    final child = switch (template) {
      CardTemplate.fieldNotes => FieldNotesCard(data: data, options: options),
      CardTemplate.sektor => SektorCard(data: data, options: options),
      CardTemplate.profil => ProfilCard(data: data, options: options),
      CardTemplate.nightInk => NightInkCard(data: data, options: options),
      CardTemplate.sticker => StickerCard(data: data, options: options),
      CardTemplate.foto => FotoCard(data: data, options: options),
    };
    return SizedBox.fromSize(
      size: options.format.logicalSize,
      child: MediaQuery(
        data: mq.copyWith(textScaler: TextScaler.noScaling),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: FN.mono,
              color: FN.ink,
              decoration: TextDecoration.none,
            ),
            child: ClipRect(child: child),
          ),
        ),
      ),
    );
  }
}
