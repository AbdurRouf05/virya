import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/body/domain/body_models.dart';
import 'package:virya/features/body/presentation/widgets/body_photo_frame.dart';

/// Slot satu pose di layar check-in: foto yang ada, atau ajakan menambah.
class BodyPoseSlot extends StatelessWidget {
  final BodyPose pose;
  final BodyShot? shot;
  final VoidCallback onTap;

  const BodyPoseSlot({
    super.key,
    required this.pose,
    required this.shot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: shot == null
          ? 'Tambah foto ${pose.label}'
          : 'Ambil ulang foto ${pose.label}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              pose.label,
              textAlign: TextAlign.center,
              style: FN
                  .label(size: 10.5, color: FN.ink)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            BodyPhotoFrame(
              shot: shot,
              cacheWidth: 360,
              empty: Center(
                child: Icon(
                  Icons.add_a_photo_outlined,
                  size: 26,
                  color: FN.inkMuted,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              shot == null ? 'TAMBAH' : 'AMBIL ULANG',
              textAlign: TextAlign.center,
              style: FN.label(size: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}
