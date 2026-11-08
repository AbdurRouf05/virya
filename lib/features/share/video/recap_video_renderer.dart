import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/video/recap_draw.dart';
import 'package:virya/features/share/video/recap_intro_scene.dart';
import 'package:virya/features/share/video/recap_outro_scene.dart';
import 'package:virya/features/share/video/recap_palette.dart';
import 'package:virya/features/share/video/recap_route_scene.dart';
import 'package:virya/features/share/video/recap_stage.dart';
import 'package:virya/features/share/video/recap_timeline.dart';
import 'package:virya/features/share/video/video_encoder.dart';

class RecapCancelled implements Exception {
  @override
  String toString() => 'Render video dibatalkan';
}

/// Composes the ~18 s recap (intro → Topo-Ink route with HUD, photo pops,
/// sector notes → outro) frame by frame and streams RGBA into a [FrameSink].
/// All drawing happens in a 360-wide design space scaled to the output.
/// Scenes live in `recap_*_scene.dart`; shared state in [RecapStage].
class RecapVideoRenderer {
  final ShareData data;
  final int width;
  final int height;
  final bool night;
  final RecapTimeline timeline;
  final FrameSinkFactory sinkFactory;
  late final RecapStage _stage;

  final _progress = StreamController<double>.broadcast();
  bool _cancelled = false;
  bool _prepared = false;

  RecapVideoRenderer({
    required this.data,
    this.width = 1080,
    this.height = 1920,
    this.night = true,
    Color? accent,
    this.timeline = const RecapTimeline(),
    FrameSinkFactory? sinkFactory,
  }) : sinkFactory = sinkFactory ?? VideoEncoder.create {
    _stage = RecapStage(
      data: data,
      width: width,
      height: height,
      night: night,
      timeline: timeline,
      pal: RecapPalette.of(night: night, accent: accent),
    );
  }

  int get fps => timeline.fps;
  int get totalFrames => timeline.totalFrames;
  Stream<double> get progress => _progress.stream;
  double get _k => _stage.k;
  double get _h => _stage.h;

  void cancel() => _cancelled = true;

  /// Builds geometry and decodes photos (once).
  Future<void> prepare() async {
    if (_prepared) return;
    _prepared = true;
    await _stage.prepare();
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
    _stage.dispose();
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
        paintRecapIntro(canvas, _stage, f.local);
      case RecapScene.route:
        final wipe = recapEase((f.sceneTimeS / 0.35).clamp(0.0, 1.0));
        if (wipe < 1) {
          paintRecapIntro(canvas, _stage, 1);
          canvas.save();
          canvas.clipRect(Rect.fromLTWH(0, 0, 360 * wipe, _h));
        }
        paintRecapRoute(canvas, _stage, f);
        if (wipe < 1) {
          canvas.restore();
          canvas.drawRect(Rect.fromLTWH(360 * wipe - 3, 0, 3, _h),
              Paint()..color = _stage.pal.accent);
        }
      case RecapScene.outro:
        final wipe = recapEase((f.sceneTimeS / 0.4).clamp(0.0, 1.0));
        if (wipe < 1) {
          paintRecapRoute(canvas, _stage, timeline.at(timeline.outroStart - 1));
          canvas.save();
          canvas.clipRect(Rect.fromLTWH(0, _h * (1 - wipe), 360, _h));
        }
        paintRecapOutro(canvas, _stage, f.local, f.sceneTimeS);
        if (wipe < 1) canvas.restore();
    }
    canvas.restore();
  }
}
