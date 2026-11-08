import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Horizontal photo strip with km captions.
class PhotoStrip extends StatelessWidget {
  final List<WaypointPhoto> photos;
  final Fmt fmt;
  const PhotoStrip({super.key, required this.photos, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final p = photos[i];
          return Container(
            width: 124,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: FN.paper,
              border: Border.all(color: FN.ink, width: 1),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Image.file(
                    File(p.filePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    cacheWidth: 300,
                    errorBuilder: (_, _, _) => Container(
                      color: FN.paperDeep,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${fmt.distUnit} ${fmt.distance(p.distanceFromStartMeters, decimals: 1)}',
                  style: FN.label(size: 9.5, color: FN.ink),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
