import 'package:flutter/material.dart';
import 'package:virya/features/body/domain/body_models.dart';
import 'package:virya/features/body/presentation/widgets/body_photo_frame.dart';

/// Tiga foto satu check-in, urut DEPAN · SAMPING · BELAKANG.
class BodyPhotoRow extends StatelessWidget {
  final BodyEntry entry;
  const BodyPhotoRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final pose in BodyPose.values) ...[
          if (pose != BodyPose.values.first) const SizedBox(width: 8),
          Expanded(child: BodyPhotoFrame(shot: entry.shots[pose])),
        ],
      ],
    );
  }
}
