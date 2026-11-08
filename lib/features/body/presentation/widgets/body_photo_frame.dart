import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/body/domain/body_models.dart';

/// Bingkai foto 3:4, dipotong dari tengah seperti pratinjau kamera.
/// Bila [shot] kosong, bingkai menampilkan [empty].
class BodyPhotoFrame extends StatelessWidget {
  final BodyShot? shot;
  final int cacheWidth;
  final Widget? empty;

  const BodyPhotoFrame({
    super.key,
    required this.shot,
    this.cacheWidth = 240,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    final s = shot;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: FN.paperDeep,
          border: Border.all(color: FN.ink, width: 1.5),
        ),
        child: s == null
            ? empty
            : Image.file(
                File(s.path),
                fit: BoxFit.cover,
                cacheWidth: cacheWidth,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => Center(
                  child: Icon(Icons.broken_image_outlined, color: FN.inkMuted),
                ),
              ),
      ),
    );
  }
}
