import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/data/share_export.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/domain/share_options.dart';
import 'package:virya/features/share/presentation/widgets/studio_controls.dart';
import 'package:virya/features/share/presentation/widgets/studio_preview.dart';
import 'package:virya/features/share/presentation/widgets/studio_template_tabs.dart';
import 'package:virya/features/share/presentation/widgets/studio_video_dialog.dart';
import 'package:virya/features/share/video/recap_timeline.dart';
import 'package:virya/features/share/video/recap_video_renderer.dart';

/// Studio content for one activity: template pager, controls and export
/// actions (PNG share/save, recap MP4 on Android).
class ShareStudioBody extends StatefulWidget {
  final ShareData data;
  const ShareStudioBody({super.key, required this.data});
  @override
  State<ShareStudioBody> createState() => _ShareStudioBodyState();
}

class _ShareStudioBodyState extends State<ShareStudioBody> {
  final _pages = PageController(viewportFraction: 0.86);
  final _keys = {for (final t in CardTemplate.values) t: GlobalKey()};
  var _template = CardTemplate.fieldNotes;
  var _opts = const ShareOptions();
  var _busy = false;
  var _hd = false; // video 1080p vs 720p (default 720p untuk render lebih cepat)
  var _length = RecapLength.auto;
  String? _photoPath;

  ShareData get data => widget.data;

  List<CardTemplate> get _templates => [
    for (final t in CardTemplate.values)
      if (t != CardTemplate.sektor || (data.sport.isCycling && data.sectors.isNotEmpty)) t,
  ];

  @override
  void initState() {
    super.initState();
    if (!_templates.contains(_template)) {
      _template = _templates.first;
    }
    if (data.photos.isNotEmpty) _loadPhoto(data.photos.first.path);
  }

  @override
  void dispose() {
    _pages.dispose();
    _opts.photo?.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: FN.onNight,
        content: Text(msg, style: FN.label(size: 11, color: FN.onAccent)),
      ));
  }

  Future<void> _loadPhoto(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 1440);
      final img = (await codec.getNextFrame()).image;
      if (!mounted) {
        img.dispose();
        return;
      }
      final old = _opts.photo;
      setState(() {
        _opts = _opts.copyWith(photo: img);
        _photoPath = path;
      });
      if (old != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    } catch (e) {
      _snack('Foto tidak bisa dibuka');
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final x = await ImagePicker()
          .pickImage(source: ImageSource.gallery, maxWidth: 2160);
      if (x != null) await _loadPhoto(x.path);
    } catch (e) {
      _snack('Galeri tidak tersedia');
    }
  }

  Future<File> _renderPng() async {
    final key = _keys[_template]!;
    final png = await ShareExport.capturePng(key, _opts.format.pixelRatio);
    return ShareExport.savePng(
        png, '${_template.name}_${_opts.format.name}');
  }

  Future<void> _run(Future<void> Function() job) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await job();
    } catch (e) {
      _snack('Gagal: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareImage() => _run(() async {
        final f = await _renderPng();
        await ShareExport.shareFile(f.path, mime: 'image/png');
      });

  Future<void> _save() => _run(() async {
        final f = await _renderPng();
        final loc = await ShareExport.exportImageToGallery(
          f,
          '${_template.name}_${_opts.format.name}',
        );
        _snack('Tersimpan di Galeri: $loc');
      });

  Future<void> _makeVideo() async {
    if (kIsWeb || !Platform.isAndroid) {
      _snack('Video hanya di Android');
      return;
    }
    if (!data.hasRoute) {
      _snack('Rute kosong — video tidak bisa dibuat');
      return;
    }
    final night = _template.isDark || _opts.accent == AccentChoice.acid;
    final renderer = RecapVideoRenderer(
      data: data,
      width: _hd ? 1080 : 720,
      height: _hd ? 1920 : 1280,
      night: night,
      accent: _opts.accent == AccentChoice.signal && night
          ? FN.acid
          : _opts.accent.resolve(dark: night),
      timeline: RecapTimeline(routeS: _length.routeSeconds(data.distanceM)),
    );
    await _run(() async {
      final out = await ShareExport.newVideoPath();
      if (!mounted) return;
      final job = renderer.render(outputPath: out);
      final path = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => StudioVideoDialog(renderer: renderer, job: job),
      );
      if (path == null || !mounted) return;

      // Pilihan setelah render: Simpan ke Galeri HP atau Bagikan
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: FN.nightSurface,
        shape: const RoundedRectangleBorder(),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: FN.signal, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'VIDEO RECAP SELESAI',
                      style: FN
                          .label(size: 13, color: FN.onNight)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Video berhasil dibuat (${_hd ? '1080p HD' : '720p'}). Silakan pilih tindakan:',
                  style: TextStyle(fontFamily: FN.sans, color: FN.onNightMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: FN.acid,
                    foregroundColor: FN.night,
                    shape: const RoundedRectangleBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.download_rounded),
                  label: Text(
                    'SIMPAN KE GALERI',
                    style: FN.label(size: 12, color: FN.night).copyWith(fontWeight: FontWeight.w700),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final loc = await ShareExport.exportVideoToGallery(path);
                    _snack('Video tersimpan di Galeri: $loc');
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FN.onNight,
                    side: BorderSide(color: FN.onNightMuted),
                    shape: const RoundedRectangleBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.share_rounded),
                  label: Text('BAGIKAN VIDEO', style: FN.label(size: 12, color: FN.onNight)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ShareExport.shareFile(path, mime: 'video/mp4');
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StudioTemplateTabs(
          templates: _templates,
          selected: _template,
          onTap: (t) => _pages.animateToPage(_templates.indexOf(t),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pages,
            itemCount: _templates.length,
            onPageChanged: (i) =>
                setState(() => _template = _templates[i]),
            itemBuilder: (_, i) => StudioPreview(
              data: data,
              template: _templates[i],
              options: _opts,
              repaintKey: _keys[_templates[i]]!,
            ),
          ),
        ),
        StudioControls(
          opts: _opts,
          template: _template,
          hd: _hd,
          length: _length,
          distanceM: data.distanceM,
          photos: data.photos.map((p) => p.path).toList(),
          selectedPhoto: _photoPath,
          busy: _busy,
          onOpts: (o) => setState(() => _opts = o),
          onHd: (v) => setState(() => _hd = v),
          onLength: (l) => setState(() => _length = l),
          onPickPhoto: _pickPhoto,
          onPhoto: _loadPhoto,
          onShare: _shareImage,
          onSave: _save,
          onVideo: _makeVideo,
        ),
      ],
    );
  }
}
