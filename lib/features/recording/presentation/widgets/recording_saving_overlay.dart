import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Full-screen dim + spinner while the activity is saved and analysed.
class RecordingSavingOverlay extends StatelessWidget {
  const RecordingSavingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: FN.night.withValues(alpha: 0.92),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(color: FN.signal, strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text('MENYIMPAN & MENGANALISIS…',
                style: FN.label(size: 12, color: FN.onNight)),
          ],
        ),
      ),
    );
  }
}
