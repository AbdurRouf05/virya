import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/features/share/domain/share_data.dart';
import 'package:stravo/features/share/domain/share_format.dart';
import 'package:stravo/features/share/domain/share_options.dart';
import 'package:stravo/features/share/render/paper_painters.dart';
import 'package:stravo/features/share/render/route_projection.dart';
import 'package:stravo/features/share/render/topo_ink_renderer.dart';
import 'package:stravo/features/share/video/recap_timeline.dart';
import 'package:stravo/features/share/video/video_encoder.dart';

class RecapCancelled implements Exception {
  @override
  String toString() => 'Render video dibatalkan';
}

class _Pal {
  final Color bg, ink, muted, line, contour, accent, panel;
  const _Pal(this.bg, this.ink, this.muted, this.line, this.contour,
      this.accent, this.panel);
}

/// Composes the ~18 s recap (intro → Topo-Ink route with HUD, photo pops,
/// sector notes → outro) frame by frame and streams RGBA into a [FrameSink].
/// All drawing happens in a 360-wide design space scaled to the output.
class RecapVideoRenderer {
  final ShareData data;
  final int width;
  final int height;
  final bool night;
  final RecapTimeline timeline;
  final FrameSinkFactory sinkFactory;
  late final _Pal _p;

  final _progress = StreamController<double>.broadcast();
  bool _cancelled = false;
  bool _prepared = false;

  late final TopoInkRenderer _topo;
  late final List<double> _gain;
  late final double _seriesTotal;
  final _photos = <(SharePhoto, ui.Image, int)>[]; // photo, image, pass frame
  final _sectorFrames = <int>[];
  ui.Image? _bgPaper, _bgScene, _grainIntro, _grainRoute, _grainOutro;

  RecapVideoRenderer({
    required this.data,
    this.width = 1080,
    this.height = 1920,
    this.night = true,
    Color? accent,
    this.timeline = const RecapTimeline(),
    FrameSinkFactory? sinkFactory,
  }) : sinkFactory = sinkFactory ?? VideoEncoder.create {
    final a = accent ?? (night ? FN.acid : FN.signal);
    _p = night
        ? _Pal(FN.night, FN.paper, const Color(0xFF8C887D), FN.nightLine,
            const Color(0xFF24241F), a, FN.nightSurface)
        : _Pal(FN.paper, FN.ink, FN.inkMuted, FN.ink, FN.paperLine, a,
            FN.paperDeep);
  }

  int get fps => timeline.fps;
  int get totalFrames => timeline.totalFrames;
  Stream<double> get progress => _progress.stream;
  double get _k => width / 360.0;
  double get _h => height / _k; // design height

  void cancel() => _cancelled = true;

  double _frac(double distM) =>
      _seriesTotal <= 0 ? 0 : (distM / _seriesTotal).clamp(0.0, 1.0);

  Future<ui.Image> _bake(void Function(Canvas c) paint) async {
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    c.scale(_k); // ruang desain 360-lebar → resolusi output
    paint(c);
    final pic = rec.endRecording();
    final img = await pic.toImage(width, height);
    pic.dispose();
    return img;
  }

  /// Builds geometry and decodes photos (once).
  Future<void> prepare() async {
    if (_prepared) return;
    _prepared = true;
    _seriesTotal = data.dist.isEmpty ? 0 : data.dist.last;
    _gain = data.cumulativeGain();
    _topo = TopoInkRenderer(
      lat: data.lat,
      lon: data.lon,
      ele: data.ele,
      dist: data.dist,
      seed: data.seed,
      markerFracs: [for (final p in data.photos) _frac(p.distanceM)],
      sectorFracs: [
        for (final s in data.sectors)
          (_frac(s.startDistanceM), _frac(s.endDistanceM)),
      ],
    );
    _bgPaper = await _bake((c) => _backgroundRaw(c, paper: true));
    _bgScene = await _bake((c) => _backgroundRaw(c, paper: !night));
    _grainIntro = await _bake((c) => paintGrain(c, Rect.fromLTWH(0, 0, 360, _h), seed: data.seed, density: 0.05));
    _grainRoute = await _bake((c) => paintGrain(c, Rect.fromLTWH(0, 0, 360, _h), seed: data.seed + 1, density: 0.04,
        dark: night ? const Color(0x30000000) : const Color(0x1E141414),
        light: night ? const Color(0x10FFFFFF) : const Color(0x33FFFFFF)));
    _grainOutro = await _bake((c) => paintGrain(c, Rect.fromLTWH(0, 0, 360, _h), seed: data.seed + 2, density: 0.05));
    for (final s in data.sectors) {
      _sectorFrames.add(timeline.frameAtProgress(_frac(s.startDistanceM)));
    }
    for (final p in data.photos) {
      try {
        final f = File(p.path);
        if (!await f.exists()) continue;
        final codec = await ui.instantiateImageCodec(await f.readAsBytes(),
            targetWidth: (220 * _k).round());
        final img = (await codec.getNextFrame()).image;
        _photos.add((p, img, timeline.frameAtProgress(_frac(p.distanceM))));
      } catch (_) {
        // Unreadable photo: skip.
      }
    }
  }

  /// Renders all frames into a new sink at [outputPath]; returns the file path.
  Future<String> render({required String outputPath, int? bitrate}) async {
    await prepare();
    final sink = await sinkFactory(
      outputPath: outputPath,
      width: width,
      height: height,
      fps: fps,
      bitrate: bitrate ?? (width >= 1080 ? 10000000 : 6000000),
    );
    final swTotal = Stopwatch()..start();
    Future<void>? inFlight;
    var paintRasterMs = 0, bytesMs = 0, encodeMs = 0;
    try {
      final total = totalFrames;
      for (var i = 0; i < total; i++) {
        if (_cancelled) throw RecapCancelled();
        final swFrame = Stopwatch()..start();
        final img = await renderFrame(i);
        final aMs = swFrame.elapsedMilliseconds;

        swFrame.reset();
        swFrame.start();
        final bd = await img.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
        img.dispose();
        if (bd == null) throw StateError('Gagal membaca frame $i');
        final bMs = swFrame.elapsedMilliseconds;

        swFrame.reset();
        swFrame.start();
        if (inFlight != null) await inFlight;
        final cMs = swFrame.elapsedMilliseconds;

        paintRasterMs += aMs;
        bytesMs += bMs;
        encodeMs += cMs;

        inFlight = sink.addFrameRgba(
            bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes));
        _progress.add((i + 1) / total);

        if ((i + 1) % 60 == 0 || i == total - 1) {
          final count = (i % 60) + 1;
          debugPrint(
              '[recap-perf] frame ${i + 1}/$total paint+raster=${(paintRasterMs / count).round()}ms bytes=${(bytesMs / count).round()}ms encode=${(encodeMs / count).round()}ms');
          paintRasterMs = 0;
          bytesMs = 0;
          encodeMs = 0;
        }
      }
      if (inFlight != null) await inFlight;
      if (_cancelled) throw RecapCancelled();
      final res = await sink.finish();
      debugPrint('[recap-perf] TOTAL ${swTotal.elapsedMilliseconds} ms untuk $total frame (${width}x$height)');
      return res;
    } catch (e) {
      try {
        await inFlight;
      } catch (_) {}
      try {
        await sink.cancel();
      } catch (_) {}
      rethrow;
    } finally {
      dispose();
    }
  }

  void dispose() {
    for (final p in _photos) {
      p.$2.dispose();
    }
    _photos.clear();
    _bgPaper?.dispose();
    _bgScene?.dispose();
    _grainIntro?.dispose();
    _grainRoute?.dispose();
    _grainOutro?.dispose();
    _bgPaper = null;
    _bgScene = null;
    _grainIntro = null;
    _grainRoute = null;
    _grainOutro = null;
    if (!_progress.isClosed) _progress.close();
  }

  Future<ui.Image> renderFrame(int i) {
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    paintFrame(c, i);
    final pic = rec.endRecording();
    final img = pic.toImage(width, height);
    return img.whenComplete(pic.dispose);
  }

  /// Paints frame [i] at output resolution (call [prepare] first).
  void paintFrame(Canvas canvas, int i) {
    canvas.save();
    canvas.scale(_k);
    final f = timeline.at(i);
    switch (f.scene) {
      case RecapScene.intro:
        _intro(canvas, f.local);
      case RecapScene.route:
        final wipe = _ease((f.sceneTimeS / 0.35).clamp(0.0, 1.0));
        if (wipe < 1) {
          _intro(canvas, 1);
          canvas.save();
          canvas.clipRect(Rect.fromLTWH(0, 0, 360 * wipe, _h));
        }
        _route(canvas, f);
        if (wipe < 1) {
          canvas.restore();
          canvas.drawRect(Rect.fromLTWH(360 * wipe - 3, 0, 3, _h),
              Paint()..color = _p.accent);
        }
      case RecapScene.outro:
        final wipe = _ease((f.sceneTimeS / 0.4).clamp(0.0, 1.0));
        if (wipe < 1) {
          _route(canvas, timeline.at(timeline.outroStart - 1));
          canvas.save();
          canvas.clipRect(Rect.fromLTWH(0, _h * (1 - wipe), 360, _h));
        }
        _outro(canvas, f.local, f.sceneTimeS);
        if (wipe < 1) canvas.restore();
    }
    canvas.restore();
  }

  // ---------------------------------------------------------------- scenes

  void _drawCached(Canvas c, ui.Image img) {
    c.save();
    c.scale(1 / _k); // canvas sedang di-scale _k; image sudah resolusi output
    c.drawImage(img, Offset.zero, Paint()..filterQuality = FilterQuality.none);
    c.restore();
  }

  void _background(Canvas c, {required bool paper}) {
    final img = paper ? _bgPaper : _bgScene;
    if (img == null) return _backgroundRaw(c, paper: paper); // fallback bila prepare belum jalan
    _drawCached(c, img);
  }

  void _backgroundRaw(Canvas c, {required bool paper}) {
    final r = Rect.fromLTWH(0, 0, 360, _h);
    final bg = paper ? FN.paper : _p.bg;
    c.drawRect(r, Paint()..color = bg);
    paintContours(c, r,
        seed: data.seed,
        color: paper ? FN.paperLine : _p.contour,
        width: 0.6,
        cols: 36);
  }

  void _intro(Canvas c, double t) {
    _background(c, paper: true);
    const ink = FN.ink;
    final a = _p.accent == FN.acid ? FN.signal : _p.accent;
    _text(c, 'STRAVO · FIELD NOTES', 22, 40, mono: true, size: 9, color: ink, bold: true);
    _textR(c, SF.entryNo(data), 338, 40, size: 9, color: ink);
    final rule = _ease((t / 0.5).clamp(0, 1));
    c.drawRect(Rect.fromLTWH(22, 56, 316 * rule, 1.6), Paint()..color = ink);

    final y0 = _h * 0.36;
    final big = TextPainter(
      text: TextSpan(text: SF.sport(data.sport), style: FN.bigNumber(92, color: ink)),
      textDirection: TextDirection.ltr,
    )..layout();
    final s = math.min(1.0, 316 / big.width);
    c.save();
    c.translate(22, y0);
    c.scale(s);
    final reveal = _ease((t / 0.4).clamp(0, 1));
    c.clipRect(Rect.fromLTWH(0, 0, big.width * reveal, big.height));
    big.paint(c, Offset.zero);
    c.restore();

    final title = data.title.toUpperCase();
    final chars = (title.length * ((t - 0.2) / 0.55).clamp(0.0, 1.0)).round();
    _text(c, title.substring(0, chars), 22, y0 + big.height * s + 10,
        size: 15, color: ink, family: FN.sans, bold: true, maxW: 316);
    _text(c, '${SF.date(data.start)} · MULAI ${SF.time(data.start)}', 22,
        y0 + big.height * s + 36,
        mono: true, size: 9, color: FN.inkSoft);

    if (t > 0.55) {
      final k = _ease(((t - 0.55) / 0.3).clamp(0, 1));
      _note(c, Offset(22, _h * 0.68), [
        SF.coord(data.startLat, data.startLon),
        '${SF.km(data.distanceM)} KM',
      ], a, alpha: k);
    }
    _text(c, 'RECAP · ${timeline.durationS.round()} DTK', 22, _h - 40,
        mono: true, size: 8, color: FN.inkMuted);
    if (_grainIntro != null) {
      _drawCached(c, _grainIntro!);
    } else {
      paintGrain(c, Rect.fromLTWH(0, 0, 360, _h), seed: data.seed, density: 0.05);
    }
  }

  void _route(Canvas c, RecapFrame f) {
    _background(c, paper: !night);
    final p = f.progress;
    final yaw = -0.75 + f.local * 1.3;
    final vp = Rect.fromLTWH(0, _h * 0.17, 360, _h * 0.58);
    _topo.paint(c, Size(360, _h),
        t: p,
        yaw: yaw,
        tilt: 1.0,
        viewport: vp,
        style: night
            ? TopoInkStyle.night(accent: _p.accent, background: false)
            : TopoInkStyle.paper(accent: _p.accent, background: false));

    final idx = data.indexAtDistance(p * _seriesTotal);
    final distShown = p * data.distanceM;
    final gain = _gain.isEmpty ? 0.0 : _gain[idx.clamp(0, _gain.length - 1)];
    var sp = 0.0, n = 0;
    for (var j = math.max(0, idx - 3); j <= math.min(data.speed.length - 1, idx + 3); j++) {
      sp += data.speed[j];
      n++;
    }
    sp = n == 0 ? 0 : sp / n;

    // HUD
    _text(c, data.title.toUpperCase(), 22, 26,
        mono: true, size: 8, color: _p.muted, maxW: 230);
    _textR(c, SF.date(data.start), 338, 26, size: 8, color: _p.muted);
    c.drawRect(Rect.fromLTWH(22, 40, 316, 0.8), Paint()..color = _p.line);
    _text(c, 'JARAK', 22, 50, mono: true, size: 7, color: _p.muted);
    final dv = TextPainter(
      text: TextSpan(children: [
        TextSpan(text: SF.km(distShown), style: FN.bigNumber(58, color: _p.ink)),
        TextSpan(text: ' KM', style: FN.bigNumber(18, color: _p.accent)),
      ]),
      textDirection: TextDirection.ltr,
    )..layout();
    dv.paint(c, const Offset(22, 62));
    _text(c, 'ELEV', 232, 50, mono: true, size: 7, color: _p.muted);
    _text(c, '+${gain.round()} M', 232, 60, size: 24, color: _p.ink);
    final runner = data.sport.isRunning;
    _text(c, runner ? 'PACE' : 'KEC', 232, 92, mono: true, size: 7, color: _p.muted);
    _text(c, runner ? '${SF.pace(sp)}/KM' : '${SF.kmh(sp)} KM/J', 232, 102,
        size: 24, color: _p.ink);

    // Surface under the tracer.
    if (data.surface.isNotEmpty) {
      final s = data.surface[idx.clamp(0, data.surface.length - 1)];
      final y = _h * 0.77;
      c.drawRect(Rect.fromLTWH(22, y + 1, 8, 8), Paint()..color = FN.surface[s]!);
      _text(c, 'PERMUKAAN · ${SF.surface(s)}', 36, y, mono: true, size: 8, color: _p.ink, bold: true);
    }

    // Elevation strip with cursor.
    final strip = Rect.fromLTWH(22, _h * 0.81, 316, _h * 0.11);
    if (data.dist.length >= 2) {
      final pts = paintElevation(c, strip,
          dist: data.dist,
          ele: data.ele,
          grade: data.grade,
          byGrade: !night,
          fill: night ? _p.panel : FN.ink,
          edge: night ? _p.muted : FN.ink,
          edgeWidth: 1,
          hatch: !night,
          headroom: 0.05);
      final cx = strip.left + strip.width * p;
      if (night) {
        c.save();
        c.clipRect(Rect.fromLTRB(strip.left, strip.top - 2, cx, strip.bottom));
        final path = Path()..moveTo(pts.first.dx, strip.bottom);
        for (final q in pts) {
          path.lineTo(q.dx, q.dy);
        }
        path
          ..lineTo(pts.last.dx, strip.bottom)
          ..close();
        c.drawPath(path, Paint()..color = _p.accent.withValues(alpha: 0.35));
        c.restore();
      }
      c.drawLine(Offset(cx, strip.top - 6), Offset(cx, strip.bottom),
          Paint()
            ..color = _p.accent
            ..strokeWidth = 1.4);
      final cy = pts[idx.clamp(0, pts.length - 1)].dy;
      c.drawCircle(Offset(cx, cy), 3.2, Paint()..color = _p.accent);
      _text(c, '${SF.km(distShown)} KM', math.min(cx + 4, 300), strip.top - 10,
          mono: true, size: 7, color: _p.accent, bold: true);
    }

    // Sector notes while inside a sector.
    for (var s = 0; s < data.sectors.length; s++) {
      final sec = data.sectors[s];
      final enter = _sectorFrames[s];
      final d = p * _seriesTotal;
      final age = (f.index - enter) / fps;
      final inside = d >= sec.startDistanceM && d <= sec.endDistanceM;
      if (age < 0 || !(inside || age < 1.4)) continue;
      final fade = (age / 0.25).clamp(0.0, 1.0);
      _note(c, Offset(22, _h * 0.2), [
        'SEKTOR ${sec.number}  ${SF.stars(sec.stars)}',
        '${SF.km(sec.lengthM)} KM · ${SF.surface(sec.dominantSurface)}',
      ], _p.accent, alpha: fade, fill: _p.bg);
      break;
    }

    // Photo pop-ups.
    for (var j = 0; j < _photos.length; j++) {
      final (photo, img, at) = _photos[j];
      final age = (f.index - at) / fps;
      if (age < 0 || age > 2.2) continue;
      final inAlpha = (age / 0.28).clamp(0.0, 1.0);
      final outAlpha = age > 1.9 ? (1 - (age - 1.9) / 0.3).clamp(0.0, 1.0) : 1.0;
      final alpha = math.min(inAlpha, outAlpha);
      _polaroid(c, img, photo, Offset(180, _h * 0.44), 1.0, alpha);
    }
    if (_grainRoute != null) {
      _drawCached(c, _grainRoute!);
    } else {
      paintGrain(c, Rect.fromLTWH(0, 0, 360, _h),
          seed: data.seed + 1,
          density: 0.04,
          dark: night ? const Color(0x30000000) : const Color(0x1E141414),
          light: night ? const Color(0x10FFFFFF) : const Color(0x33FFFFFF));
    }
  }

  void _outro(Canvas c, double t, double sceneS) {
    _background(c, paper: true);
    const ink = FN.ink;
    final a = _p.accent == FN.acid ? FN.signal : _p.accent;
    _text(c, 'STRAVO · FIELD NOTES', 22, 40, mono: true, size: 9, color: ink, bold: true);
    _textR(c, SF.date(data.start), 338, 40, size: 9, color: ink);
    c.drawRect(const Rect.fromLTWH(22, 56, 316, 1.6), Paint()..color = ink);

    final box = Rect.fromLTWH(22, 70, 316, _h * 0.42);
    if (data.hasRoute) {
      final pts = RouteProjection.fitPoints(data.lat, data.lon, box, padding: 16);
      paintRoute(c, pts, color: ink, width: 2.4);
      paintStartFinish(c, pts.first, pts.last, color: a, size: 5, fill: FN.paper);
    }
    final y = box.bottom + 10;
    final big = TextPainter(
      text: TextSpan(children: [
        TextSpan(text: SF.km(data.distanceM), style: FN.bigNumber(110, color: ink)),
        TextSpan(text: ' KM', style: FN.bigNumber(28, color: a)),
      ]),
      textDirection: TextDirection.ltr,
    )..layout();
    final s = math.min(1.0, 316 / big.width);
    c.save();
    c.translate(22, y);
    c.scale(s);
    big.paint(c, Offset.zero);
    c.restore();
    final gy = y + big.height * s + 10;
    c.drawRect(Rect.fromLTWH(22, gy, 316, 0.8), Paint()..color = ink);
    final cells = statValues(data, const {
      ShareStat.time,
      ShareStat.elevation,
      ShareStat.speed,
      ShareStat.grit,
    });
    for (var k = 0; k < cells.length && k < 4; k++) {
      final x = 22 + (k % 2) * 160.0, yy = gy + 10 + (k ~/ 2) * 52.0;
      _text(c, cells[k].label, x, yy, mono: true, size: 7, color: FN.inkMuted);
      _text(c, '${cells[k].value} ${cells[k].unit}'.trim(), x, yy + 10, size: 28, color: ink);
    }
    if (sceneS > 0.45) {
      final k = _ease(((sceneS - 0.45) / 0.25).clamp(0.0, 1.0));
      _note(c, Offset(22, box.bottom - 34), ['FINIS', SF.coord(data.startLat, data.startLon)],
          a, alpha: k, fill: FN.paper);
    }
    _text(c, 'DICATAT OFFLINE · STRAVO PRO', 22, _h - 40, mono: true, size: 8, color: FN.inkMuted);
    if (_grainOutro != null) {
      _drawCached(c, _grainOutro!);
    } else {
      paintGrain(c, Rect.fromLTWH(0, 0, 360, _h), seed: data.seed + 2, density: 0.05);
    }
  }

  // --------------------------------------------------------------- helpers

  void _polaroid(Canvas c, ui.Image img, SharePhoto p, Offset center,
      double scale, double alpha) {
    const w = 200.0;
    final ar = img.height / img.width;
    final ih = (w - 16) * ar.clamp(0.6, 1.3);
    final h = ih + 16 + 22;
    c.save();
    c.translate(center.dx, center.dy);
    c.scale(scale);
    final frame = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    c.saveLayer(frame.inflate(20), Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
    c.drawRect(frame.shift(const Offset(3, 5)),
        Paint()
          ..color = const Color(0x66000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    c.drawRect(frame, Paint()..color = FN.paper);
    final ir = Rect.fromLTWH(frame.left + 8, frame.top + 8, w - 16, ih);
    paintImage(canvas: c, rect: ir, image: img, fit: BoxFit.cover,
        filterQuality: FilterQuality.medium);
    final cap = p.caption?.toUpperCase() ?? 'FOTO';
    _text(c, '$cap · KM ${SF.km(p.distanceM)}', frame.left + 10, ir.bottom + 6,
        mono: true, size: 7.5, color: FN.ink, bold: true, maxW: w - 20);
    c.restore();
    c.restore();
  }

  void _note(Canvas c, Offset topLeft, List<String> lines, Color color,
      {double alpha = 1, Color? fill}) {
    final tps = [
      for (var i = 0; i < lines.length; i++)
        monoText(lines[i],
            size: i == 0 ? 11 : 8.5,
            color: color.withValues(alpha: color.a * alpha),
            weight: FontWeight.w700,
            spacing: 1.4),
    ];
    final w = tps.fold<double>(0, (m, t) => math.max(m, t.width)) + 16;
    final h = tps.fold<double>(0, (m, t) => m + t.height) + 10;
    final dy = (1 - alpha) * 6;
    final r = Rect.fromLTWH(topLeft.dx, topLeft.dy + dy, w, h);
    if (fill != null) {
      c.drawRect(r, Paint()..color = fill.withValues(alpha: 0.9 * alpha));
    }
    c.drawRect(Rect.fromLTWH(r.left, r.top, 3, r.height),
        Paint()..color = color.withValues(alpha: color.a * alpha));
    var y = r.top + 5;
    for (final t in tps) {
      t.paint(c, Offset(r.left + 10, y));
      y += t.height;
    }
  }

  void _text(Canvas c, String s, double x, double y,
      {bool mono = false,
      double size = 10,
      Color color = FN.ink,
      bool bold = false,
      String? family,
      double? maxW}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: mono || family != null
            ? TextStyle(
                fontFamily: family ?? FN.mono,
                fontSize: size,
                letterSpacing: mono ? 1.3 : 0.4,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: color,
              )
            : FN.bigNumber(size, color: color),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: maxW != null ? '…' : null,
    )..layout(maxWidth: maxW ?? double.infinity);
    tp.paint(c, Offset(x, y));
  }

  void _textR(Canvas c, String s, double right, double y,
      {double size = 9, Color color = FN.ink}) {
    final tp = monoText(s, size: size, color: color);
    tp.paint(c, Offset(right - tp.width, y));
  }

  static double _ease(double x) => 1 - math.pow(1 - x, 3).toDouble();
}
