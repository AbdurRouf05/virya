import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/widgets/stamp_chip.dart';

/// Shown when building the camera plan failed; offers a retry.
class FlyoverPlanError extends StatelessWidget {
  const FlyoverPlanError({super.key, required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'GAGAL MENYIAPKAN FLYOVER',
                      textAlign: TextAlign.center,
                      style: FN
                          .label(size: 13, color: FN.paper)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: FN.label(size: 10, color: FN.inkSoft),
                    ),
                    const SizedBox(height: 16),
                    StampChip(text: 'COBA LAGI', color: FN.acid, onTap: onRetry),
                  ],
                ),
              ),
            ),
            Positioned(left: 4, top: 4, child: BackButton(color: FN.paper)),
          ],
        ),
      );
}
