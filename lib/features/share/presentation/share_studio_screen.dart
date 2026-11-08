import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/core/data/activity_repository.dart';
import 'package:stravo/features/share/data/share_export.dart';
import 'package:stravo/features/share/domain/share_data.dart';
import 'package:stravo/features/share/domain/share_options.dart';
import 'package:stravo/features/share/templates/share_card.dart';
import 'package:stravo/features/share/video/recap_timeline.dart';
import 'package:stravo/features/share/video/recap_video_renderer.dart';

/// Share studio: swipe templates, pick format/stats/accent, export PNG,
/// or render the recap MP4 (Android).
class ShareStudioScreen extends ConsumerWidget {
  final String activityId;
  const ShareStudioScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activityBundleProvider(activityId));
    return Scaffold(
      backgroundColor: FN.night,
      appBar: AppBar(
        backgroundColor: FN.night,
        foregroundColor: FN.paper,
        elevation: 0,
        title: Text('STUDIO BAGIKAN',
            style: FN.label(size: 13, color: FN.paper)
                .copyWith(fontWeight: FontWeight.w700, letterSpacing: 2)),
      ),
      body: async.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: FN.signal)),
        error: (e, _) => _Message('Gagal memuat aktivitas\n$e'),
        data: (b) => b == null
            ? const _Message('Aktivitas tidak ditemukan')
            : _Studio(data: ShareData.fromBundle(b)),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  const _Message(this.text);
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(text,
              textAlign: TextAlign.center,
              style: FN.label(size: 12, color: FN.paper)),
        ),
      );
}

class _Studio extends StatefulWidget {
  final ShareData data;
  const _Studio({required this.data});
  @override
  State<_Studio> createState() => _StudioState();
}

class _StudioState extends State<_Studio> {
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
        backgroundColor: FN.paper,
        content: Text(msg, style: FN.label(size: 11, color: FN.ink)),
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
        _snack('Tersimpan: ${f.path}');
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
        builder: (_) => _VideoDialog(renderer: renderer, job: job),
      );
      if (path == null) return;
      _snack('Video tersimpan: $path');
      await ShareExport.shareFile(path, mime: 'video/mp4');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TemplateTabs(
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
            itemBuilder: (_, i) {
              final t = _templates[i];
              final size = _opts.format.logicalSize;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Container(
                      decoration: const BoxDecoration(boxShadow: [
                        BoxShadow(color: Color(0x88000000), blurRadius: 18),
                      ]),
                      child: Stack(children: [
                        if (t.isTransparent)
                          CustomPaint(
                              size: size, painter: const _CheckerPainter()),
                        RepaintBoundary(
                          key: _keys[t],
                          child: ShareCard(
                              data: data, template: t, options: _opts),
                        ),
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _Controls(
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

class _TemplateTabs extends StatelessWidget {
  final List<CardTemplate> templates;
  final CardTemplate selected;
  final ValueChanged<CardTemplate> onTap;
  const _TemplateTabs({
    required this.templates,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            for (final t in templates)
              GestureDetector(
                onTap: () => onTap(t),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: t == selected ? FN.signal : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    t.label,
                    style: FN.label(
                      size: 11,
                      color: t == selected ? FN.paper : FN.inkMuted,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _Controls extends StatelessWidget {
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

  const _Controls({
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
            _Row(label: 'FORMAT', children: [
              for (final f in CardFormat.values)
                _Chip(
                  label: f.label,
                  selected: opts.format == f,
                  onTap: () => onOpts(opts.copyWith(format: f)),
                ),
            ]),
            _Row(label: 'DATA', children: [
              for (final s in ShareStat.values)
                _Chip(
                  label: s.label,
                  selected: opts.stats.contains(s),
                  onTap: () {
                    final next = Set<ShareStat>.of(opts.stats);
                    next.contains(s) ? next.remove(s) : next.add(s);
                    onOpts(opts.copyWith(stats: next));
                  },
                ),
            ]),
            _Row(label: 'AKSEN', children: [
              for (final a in AccentChoice.values)
                _Chip(
                  label: a.label,
                  swatch: a.swatch,
                  selected: opts.accent == a,
                  onTap: () => onOpts(opts.copyWith(accent: a)),
                ),
            ]),
            _Row(label: 'VIDEO', children: [
              _Chip(label: '720P', selected: !hd, onTap: () => onHd(false)),
              _Chip(label: '1080P', selected: hd, onTap: () => onHd(true)),
            ]),
            _Row(label: 'DURASI', children: [
              for (final l in RecapLength.values)
                _Chip(
                  label: l.label,
                  selected: length == l,
                  onTap: () => onLength(l),
                ),
            ]),
            Builder(builder: (context) {
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
                  '$totalDtk DTK · 1 DTK $speedText',
                  style: FN.label(size: 8.5, color: FN.inkMuted),
                ),
              );
            }),
            if (template == CardTemplate.foto)
              _Row(label: 'FOTO', children: [
                _Chip(label: '+ GALERI', selected: false, onTap: onPickPhoto),
                for (final p in photos)
                  GestureDetector(
                    onTap: () => onPhoto(p),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: p == selectedPhoto ? FN.signal : FN.nightLine,
                          width: 2,
                        ),
                      ),
                      child: Image.file(File(p),
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                          cacheWidth: 96,
                          errorBuilder: (_, _, _) =>
                              const SizedBox(width: 34, height: 34)),
                    ),
                  ),
              ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                flex: 3,
                child: _Button(
                  label: 'BAGIKAN GAMBAR',
                  primary: true,
                  onTap: busy ? null : onShare,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _Button(label: 'SIMPAN', onTap: busy ? null : onSave),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _Button(label: 'BUAT VIDEO', onTap: busy ? null : onVideo),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _Row({required this.label, required this.children});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(
            width: 52,
            child: Text(label, style: FN.label(size: 9, color: FN.inkMuted)),
          ),
          Expanded(
            child: SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: children,
              ),
            ),
          ),
        ]),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? swatch;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.swatch,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? FN.paper : Colors.transparent,
            border: Border.all(color: selected ? FN.paper : FN.nightLine),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (swatch != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: swatch,
                  border: Border.all(color: FN.inkMuted, width: 0.5),
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: FN.label(size: 9.5, color: selected ? FN.ink : FN.paper)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      );
}

class _Button extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback? onTap;
  const _Button({required this.label, this.primary = false, this.onTap});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary ? FN.signal : Colors.transparent,
              border: Border.all(color: primary ? FN.signal : FN.paper, width: 1.4),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  style: FN.label(size: 11, color: primary ? FN.ink : FN.paper)
                      .copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.6),
                ),
              ),
            ),
          ),
        ),
      );
}

class _VideoDialog extends StatefulWidget {
  final RecapVideoRenderer renderer;
  final Future<String> job;
  const _VideoDialog({required this.renderer, required this.job});
  @override
  State<_VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<_VideoDialog> {
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

class _CheckerPainter extends CustomPainter {
  const _CheckerPainter();
  @override
  void paint(Canvas canvas, Size size) {
    const s = 12.0;
    final a = Paint()..color = const Color(0xFF4A4A44);
    final b = Paint()..color = const Color(0xFF6A6A62);
    for (var y = 0.0; y < size.height; y += s) {
      for (var x = 0.0; x < size.width; x += s) {
        final even = ((x / s).floor() + (y / s).floor()).isEven;
        canvas.drawRect(Rect.fromLTWH(x, y, s, s), even ? a : b);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter old) => false;
}
