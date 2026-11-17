import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/body/domain/body_models.dart';
import 'package:virya/features/body/presentation/widgets/body_photo_row.dart';

/// Satu tanggal di daftar progres: tanggal, berat, dan tiga foto.
class BodyEntryTile extends StatelessWidget {
  final BodyEntry entry;
  final VoidCallback onTap;

  const BodyEntryTile({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final kg = entry.weightKg;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    Fmt.dateStamp(entry.day, withTime: false),
                    style: FN
                        .label(size: 11, color: FN.ink)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (kg != null)
                  Text(
                    '${kg.toStringAsFixed(1)} kg',
                    style: FN.label(size: 11, color: FN.ink),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            BodyPhotoRow(entry: entry),
          ],
        ),
      ),
    );
  }
}
