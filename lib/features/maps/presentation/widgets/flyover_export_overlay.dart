import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Modal progress card shown while the MP4 export runs.
class FlyoverExportOverlay extends StatelessWidget {
  const FlyoverExportOverlay({
    super.key,
    required this.progress,
    required this.stage,
    required this.cancelling,
    required this.onCancel,
  });
  final double progress;
  final String stage;
  final bool cancelling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ColoredBox(
          color: FN.night.withValues(alpha: .72),
          child: Center(
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: FN.nightSurface,
                border: Border.all(color: FN.acid, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EKSPOR VIDEO 1080×1920',
                    style: FN.label(size: 10, color: FN.acid),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: FN.bigNumber(56, color: FN.paper),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    color: FN.signal,
                    backgroundColor: FN.nightLine,
                  ),
                  const SizedBox(height: 8),
                  Text(stage, style: FN.label(size: 10, color: FN.paperLine)),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: cancelling ? null : onCancel,
                      child: Text(
                        cancelling ? 'MEMBATALKAN…' : 'BATAL',
                        style: FN.label(size: 11, color: FN.warn),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
