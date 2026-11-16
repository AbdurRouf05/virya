import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/domain/share_options.dart';
import 'package:virya/features/share/presentation/widgets/studio_button.dart';
import 'package:virya/features/share/presentation/widgets/studio_chip.dart';
import 'package:virya/features/share/presentation/widgets/studio_row.dart';

/// Bottom control panel: format, stats, accent, video options, photo
/// picker (foto template) and export buttons.
class StudioControls extends StatelessWidget {
  final ShareOptions opts;
  final CardTemplate template;
  final bool hd;
  final RecapLength length;
  final double distanceM;
  final List<String> photos;
  final String? selectedPhoto;
  final bool busy;
  final ValueChanged<ShareOptions> onOpts;
  final ValueChanged<bool> onHd;
  final ValueChanged<RecapLength> onLength;
  final VoidCallback onPickPhoto;
  final ValueChanged<String> onPhoto;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onVideo;

  const StudioControls({
    super.key,
    required this.opts,
    required this.template,
    required this.hd,
    required this.length,
    required this.distanceM,
    required this.photos,
    required this.selectedPhoto,
    required this.busy,
    required this.onOpts,
    required this.onHd,
    required this.onLength,
    required this.onPickPhoto,
    required this.onPhoto,
    required this.onShare,
    required this.onSave,
    required this.onVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FN.nightSurface,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._optionRows(),
            _DurationHint(length: length, distanceM: distanceM),
            if (template == CardTemplate.foto) _photoRow(),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                flex: 3,
                child: StudioButton(
                  label: FN.caps('Bagikan gambar'),
                  primary: true,
                  onTap: busy ? null : onShare,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: StudioButton(label: FN.caps('Simpan'), onTap: busy ? null : onSave),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: StudioButton(label: FN.caps('Buat video'), onTap: busy ? null : onVideo),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  List<Widget> _optionRows() => [
        StudioRow(label: FN.caps('Format'), children: [
          for (final f in CardFormat.values)
            StudioChip(
              label: f.label,
              selected: opts.format == f,
              onTap: () => onOpts(opts.copyWith(format: f)),
            ),
        ]),
        StudioRow(label: FN.caps('Data'), children: [
          for (final s in ShareStat.values)
            StudioChip(
              label: s.label,
              selected: opts.stats.contains(s),
              onTap: () {
                final next = Set<ShareStat>.of(opts.stats);
                next.contains(s) ? next.remove(s) : next.add(s);
                onOpts(opts.copyWith(stats: next));
              },
            ),
        ]),
        StudioRow(label: FN.caps('Aksen'), children: [
          for (final a in AccentChoice.values)
            StudioChip(
              label: a.label,
              swatch: a.swatch,
              selected: opts.accent == a,
              onTap: () => onOpts(opts.copyWith(accent: a)),
            ),
        ]),
        StudioRow(label: FN.caps('Video'), children: [
          StudioChip(label: '720P', selected: !hd, onTap: () => onHd(false)),
          StudioChip(label: '1080P', selected: hd, onTap: () => onHd(true)),
        ]),
        StudioRow(label: FN.caps('Durasi'), children: [
          for (final l in RecapLength.values)
            StudioChip(
              label: l.label,
              selected: length == l,
              onTap: () => onLength(l),
            ),
        ]),
      ];

  Widget _photoRow() => StudioRow(label: FN.caps('Foto'), children: [
        StudioChip(label: FN.caps('+ Galeri'), selected: false, onTap: onPickPhoto),
        for (final p in photos)
          GestureDetector(
            onTap: () => onPhoto(p),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                border: FN.frame(color: p == selectedPhoto ? FN.signal : FN.nightLine, width: 2), borderRadius: FN.boxRadius,),
              child: Image.file(File(p),
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                  cacheWidth: 96,
                  errorBuilder: (_, _, _) =>
                      const SizedBox(width: 34, height: 34)),
            ),
          ),
      ]);
}

/// "N DTK · 1 DTK ≈ X KM" line under the duration chips.
class _DurationHint extends StatelessWidget {
  final RecapLength length;
  final double distanceM;
  const _DurationHint({required this.length, required this.distanceM});

  @override
  Widget build(BuildContext context) {
    final routeS = length.routeSeconds(distanceM);
    final totalDtk = length.totalSeconds(distanceM).round();
    final distanceKm = distanceM / 1000.0;
    final speedKmPerS = distanceKm / routeS;
    final speedText = speedKmPerS < 0.1
        ? '≈ ${(speedKmPerS * 1000).round()} M'
        : '≈ ${speedKmPerS.toStringAsFixed(1)} KM';
    return Padding(
      padding: const EdgeInsets.only(left: 52, bottom: 6),
      child: Text(
        FN.caps('$totalDtk dtk · 1 dtk $speedText'),
        style: FN.label(size: 8.5, color: FN.inkMuted),
      ),
    );
  }
}
