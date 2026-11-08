import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/video/recap_video_renderer.dart';

/// Progress dialog for the recap render; pops with the file path on success.
class StudioVideoDialog extends StatefulWidget {
  final RecapVideoRenderer renderer;
  final Future<String> job;
  const StudioVideoDialog({super.key, required this.renderer, required this.job});
  @override
  State<StudioVideoDialog> createState() => _StudioVideoDialogState();
}

class _StudioVideoDialogState extends State<StudioVideoDialog> {
  double _p = 0;
  String? _error;
  var _cancelling = false;

  @override
  void initState() {
    super.initState();
    widget.renderer.progress.listen((v) {
      if (mounted) setState(() => _p = v);
    });
    widget.job.then((path) {
      if (mounted) Navigator.of(context).pop(path);
    }, onError: (Object e) {
      if (!mounted) return;
      if (e is RecapCancelled) {
        Navigator.of(context).pop();
      } else {
        setState(() => _error = '$e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: FN.paper,
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('MERENDER RECAP',
                style: FN.label(size: 11, color: FN.ink)
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            if (_error != null)
              Text('Gagal: $_error', style: FN.label(size: 10, color: FN.warn))
            else ...[
              Text('${(_p * 100).round()}%', style: FN.bigNumber(56)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _p,
                minHeight: 6,
                color: FN.signal,
                backgroundColor: FN.paperDeep,
              ),
              const SizedBox(height: 6),
              Text('${widget.renderer.width}×${widget.renderer.height} · '
                  '${widget.renderer.fps} FPS · '
                  '${widget.renderer.timeline.durationS.round()} DTK',
                  style: FN.label(size: 9)),
            ],
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _error != null
                    ? () => Navigator.of(context).pop()
                    : _cancelling
                        ? null
                        : () {
                            setState(() => _cancelling = true);
                            widget.renderer.cancel();
                          },
                child: Text(_error != null ? 'TUTUP' : 'BATAL',
                    style: FN.label(size: 11, color: FN.ink)
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
