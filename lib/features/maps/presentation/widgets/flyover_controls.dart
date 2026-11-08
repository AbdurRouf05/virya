import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_chip.dart';
import 'package:virya/features/share/domain/share_options.dart';

/// Scrubber, export options (length/resolution), play, speed and export.
class FlyoverControls extends StatelessWidget {
  const FlyoverControls({
    super.key,
    required this.u,
    required this.playing,
    required this.speed,
    required this.speeds,
    required this.exportLength,
    required this.exportHd,
    required this.videoW,
    required this.videoH,
    required this.disabled,
    required this.onSeek,
    required this.onTogglePlay,
    required this.onSpeed,
    required this.onLength,
    required this.onHd,
    required this.onExport,
  });

  final double u;
  final bool playing;
  final double speed;
  final List<double> speeds;
  final RecapLength exportLength;
  final bool exportHd;
  final int videoW, videoH;
  final bool disabled;
  final ValueChanged<double> onSeek;
  final VoidCallback onTogglePlay;
  final ValueChanged<double> onSpeed;
  final ValueChanged<RecapLength> onLength;
  final ValueChanged<bool> onHd;
  final VoidCallback onExport;

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: FlyoverChip(label, selected: selected, onTap: disabled ? null : onTap),
      );

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              activeTrackColor: FN.signal,
              inactiveTrackColor: FN.nightLine,
              thumbColor: FN.acid,
              overlayColor: FN.acid.withValues(alpha: .15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(value: u.clamp(0.0, 1.0), onChanged: disabled ? null : onSeek),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('DURASI: ', style: FN.label(size: 9, color: FN.paperLine)),
                  for (final l in RecapLength.values)
                    _chip(l.label, exportLength == l, () => onLength(l)),
                  const SizedBox(width: 8),
                  Text('RESOLUSI: ', style: FN.label(size: 9, color: FN.paperLine)),
                  _chip('720P', !exportHd, () => onHd(false)),
                  _chip('1080P', exportHd, () => onHd(true)),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: FN.signal),
                child: IconButton(
                  color: FN.night,
                  iconSize: 30,
                  onPressed: disabled ? null : onTogglePlay,
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                ),
              ),
              const SizedBox(width: 10),
              for (final s in speeds) _chip('${s.toInt()}×', speed == s, () => onSpeed(s)),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: FN.acid,
                  side: BorderSide(color: FN.acid, width: 1.5),
                  shape: const RoundedRectangleBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                ),
                onPressed: disabled ? null : onExport,
                child: Text(
                  'EKSPOR $videoW×$videoH',
                  style: FN.label(size: 10, color: FN.acid),
                ),
              ),
            ],
          ),
        ],
      );
}
