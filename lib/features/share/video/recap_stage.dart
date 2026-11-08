import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/render/paper_painters.dart';
import 'package:virya/features/share/render/topo_ink_renderer.dart';
import 'package:virya/features/share/video/recap_palette.dart';
import 'package:virya/features/share/video/recap_timeline.dart';

/// Shared state for the recap scenes: geometry, decoded photos and baked
/// background/grain layers. Drawing happens in a 360-wide design space.
class RecapStage {
  final ShareData data;
  final int width;
  final int height;
  final bool night;
  final RecapTimeline timeline;
  final RecapPalette pal;

  RecapStage({
    required this.data,
    required this.width,
    required this.height,
    required this.night,
    required this.timeline,
    required this.pal,
  });

  late final TopoInkRenderer topo;
  late final List<double> gain;
  late final double seriesTotal;
  final photos = <(SharePhoto, ui.Image, int)>[]; // photo, image, pass frame
  final sectorFrames = <int>[];
  ui.Image? _bgPaper, _bgScene;
  final _grain = <RecapScene, ui.Image>{};

  /// Output pixels per design unit.
  double get k => width / 360.0;

  /// Design height.
  double get h => height / k;
  int get fps => timeline.fps;

  double frac(double distM) =>
      seriesTotal <= 0 ? 0 : (distM / seriesTotal).clamp(0.0, 1.0);

  Future<ui.Image> _bake(void Function(Canvas c) paint) async {
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    c.scale(k); // ruang desain 360-lebar → resolusi output
    paint(c);
    final pic = rec.endRecording();
    final img = await pic.toImage(width, height);
    pic.dispose();
    return img;
  }

  /// Builds geometry, bakes static layers and decodes photos.
  Future<void> prepare() async {
    seriesTotal = data.dist.isEmpty ? 0 : data.dist.last;
    gain = data.cumulativeGain();
    topo = TopoInkRenderer(
      lat: data.lat,
      lon: data.lon,
      ele: data.ele,
      dist: data.dist,
      seed: data.seed,
      markerFracs: [for (final p in data.photos) frac(p.distanceM)],
      sectorFracs: [
        for (final s in data.sectors)
          (frac(s.startDistanceM), frac(s.endDistanceM)),
      ],
    );
    _bgPaper = await _bake((c) => _backgroundRaw(c, paper: true));
    _bgScene = await _bake((c) => _backgroundRaw(c, paper: !night));
    for (final scene in RecapScene.values) {
      _grain[scene] = await _bake((c) => _grainRaw(c, scene));
    }
    for (final s in data.sectors) {
      sectorFrames.add(timeline.frameAtProgress(frac(s.startDistanceM)));
    }
    for (final p in data.photos) {
      try {
        final f = File(p.path);
        if (!await f.exists()) continue;
        final codec = await ui.instantiateImageCodec(await f.readAsBytes(),
            targetWidth: (220 * k).round());
        final img = (await codec.getNextFrame()).image;
        photos.add((p, img, timeline.frameAtProgress(frac(p.distanceM))));
      } catch (_) {
        // Unreadable photo: skip.
      }
    }
  }

  void dispose() {
    for (final p in photos) {
      p.$2.dispose();
    }
    photos.clear();
    _bgPaper?.dispose();
    _bgScene?.dispose();
    for (final g in _grain.values) {
      g.dispose();
    }
    _bgPaper = null;
    _bgScene = null;
    _grain.clear();
  }

  void _drawCached(Canvas c, ui.Image img) {
    c.save();
    c.scale(1 / k); // canvas sedang di-scale k; image sudah resolusi output
    c.drawImage(img, Offset.zero, Paint()..filterQuality = FilterQuality.none);
    c.restore();
  }

  /// Paper (or scene) background with contours.
  void background(Canvas c, {required bool paper}) {
    final img = paper ? _bgPaper : _bgScene;
    if (img == null) return _backgroundRaw(c, paper: paper); // fallback bila prepare belum jalan
    _drawCached(c, img);
  }

  void _backgroundRaw(Canvas c, {required bool paper}) {
    final r = Rect.fromLTWH(0, 0, 360, h);
    final bg = paper ? FN.paper : pal.bg;
    c.drawRect(r, Paint()..color = bg);
    paintContours(c, r,
        seed: data.seed,
        color: paper ? FN.paperLine : pal.contour,
        width: 0.6,
        cols: 36);
  }

  /// Grain overlay for [scene].
  void grain(Canvas c, RecapScene scene) {
    final img = _grain[scene];
    if (img != null) {
      _drawCached(c, img);
    } else {
      _grainRaw(c, scene);
    }
  }

  void _grainRaw(Canvas c, RecapScene scene) {
    final r = Rect.fromLTWH(0, 0, 360, h);
    switch (scene) {
      case RecapScene.intro:
        paintGrain(c, r, seed: data.seed, density: 0.05);
      case RecapScene.route:
        paintGrain(c, r,
            seed: data.seed + 1,
            density: 0.04,
            dark: night ? const Color(0x30000000) : const Color(0x1E141414),
            light: night ? const Color(0x10FFFFFF) : const Color(0x33FFFFFF));
      case RecapScene.outro:
        paintGrain(c, r, seed: data.seed + 2, density: 0.05);
    }
  }
}
