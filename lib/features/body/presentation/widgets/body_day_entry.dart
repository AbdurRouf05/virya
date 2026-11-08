import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/day_key.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/body/data/body_providers.dart';
import 'package:virya/features/body/presentation/body_checkin_screen.dart';
import 'package:virya/features/body/presentation/widgets/body_photo_row.dart';

/// Check-in pada [day], untuk detail hari di kalender.
/// Tidak menggambar apa pun bila hari itu tidak ada check-in.
class BodyDayEntry extends ConsumerWidget {
  final DateTime day;
  const BodyDayEntry({super.key, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(bodyEntryOnProvider(dayKeyOf(day)));
    if (entry == null) return const SizedBox.shrink();
    final kg = entry.weightKg;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => openBodyCheckin(context, entry.day),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: FN.ink, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'FOTO TUBUH',
                        style: FN
                            .label(size: 12, color: FN.ink)
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
              ),
              Container(height: 2, color: FN.ink),
              Padding(
                padding: const EdgeInsets.all(12),
                child: BodyPhotoRow(entry: entry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
