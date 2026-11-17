import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/export_tokens.dart';
import 'package:virya/core/video/video_encoder.dart';
import 'package:virya/features/body/domain/body_logic.dart';
import 'package:virya/features/body/domain/body_models.dart';

class BodyTimelapseCancelled implements Exception {
  @override
  String toString() => 'Pembuatan video dibatalkan';
}

/// Merangkai foto satu pose menjadi video. Hanya dua foto yang dibuka sekaligus,
/// jadi pemakaian memori tidak bertambah seiring jumlah check-in.
class BodyTimelapseRenderer {
  static const width = 720;
  static const height = 960;
  static const fps = 15;
  static const _bitrate = 4000000;
  static const _captionHeight = 72.0;

  final FrameSinkFactory sinkFactory;

  BodyTimelapseRenderer({FrameSinkFactory? sinkFactory})
    : sinkFactory = sinkFactory ?? VideoEncoder.create;

  /// Mengembalikan path video. Melempar [BodyTimelapseCancelled] bila dibatalkan
  /// dan [StateError] berpesan siap tampil bila foto yang terbaca kurang dari 2.
  /// Berkas setengah jadi selalu dihapus saat gagal atau dibatalkan.
  Future<String> render({
    required List<BodyEntry> entries,
    required BodyPose pose,
    required String outputPath,
    void Function(double progress)? onProgress,
    bool Function()? isCancelled,
  }) async {
    void checkCancelled() {
      if (isCancelled?.call() ?? false) throw BodyTimelapseCancelled();
    }

    final usable = <BodyEntry>[];
    for (final e in bodyEntriesWithPose(entries, pose)) {
      checkCancelled();
      final probe = await _decode(e.shots[pose]!.path, 32, 32);
      if (probe == null) continue;
      probe.dispose();
      usable.add(e);
    }
    if (usable.length < 2) {
      throw StateError('Butuh minimal 2 foto yang bisa dibaca untuk membuat video.');
    }

    final plan = bodyTimelapseFrames(usable.length);
    final sink = await sinkFactory(
      outputPath: outputPath,
      width: width,
      height: height,
      fps: fps,
      bitrate: _bitrate,
    );
    final loaded = <int, ui.Image>{};
    try {
      for (var i = 0; i < plan.length; i++) {
        checkCancelled();
        final f = plan[i];
        _keepOnly(loaded, f.from, f.to);
        for (final index in {f.from, f.to}) {
          loaded[index] ??= await _load(usable[index], pose);
        }
        final caption = usable[f.blend < 0.5 ? f.from : f.to];
        final frame = await _paintFrame(
          loaded[f.from]!,
          loaded[f.to]!,
          f.blend,
          caption,
        );
        final ByteData? data;
        try {
          data = await frame.toByteData(
            format: ui.ImageByteFormat.rawStraightRgba,
          );
        } finally {
          frame.dispose();
        }
        if (data == null) throw StateError('Frame video gagal dibaca.');
        await sink.addFrameRgba(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        onProgress?.call((i + 1) / plan.length);
        await Future<void>.delayed(Duration.zero);
      }
      checkCancelled();
      return await sink.finish();
    } catch (_) {
      await _discard(sink, outputPath);
      rethrow;
    } finally {
      _keepOnly(loaded, -1, -1);
    }
  }

  void _keepOnly(Map<int, ui.Image> images, int a, int b) {
    images.removeWhere((index, image) {
      if (index == a || index == b) return false;
      image.dispose();
      return true;
    });
  }

  Future<ui.Image> _load(BodyEntry entry, BodyPose pose) async {
    final image = await _decode(entry.shots[pose]!.path, width, height);
    if (image == null) throw StateError('Foto gagal dibaca saat membuat video.');
    return image;
  }

  Future<void> _discard(FrameSink sink, String outputPath) async {
    try {
      await sink.cancel();
    } catch (e) {
      debugPrint('Encoder gagal dibatalkan: $e');
    }
    try {
      final file = File(outputPath);
      if (file.existsSync()) await file.delete();
    } on FileSystemException catch (e) {
      debugPrint('Video sementara gagal dihapus: $e');
    }
  }

  /// Foto diperkecil saat dibuka hingga pas menutupi [minWidth]×[minHeight].
  /// Orientasi EXIF sudah diterapkan oleh dekoder. Null bila tidak terbaca.
  Future<ui.Image?> _decode(String path, int minWidth, int minHeight) async {
    ui.Codec? codec;
    try {
      final bytes = await File(path).readAsBytes();
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      codec = await ui.instantiateImageCodecWithSize(
        buffer,
        getTargetSize: (w, h) {
          final scale = math.max(minWidth / w, minHeight / h);
          if (scale >= 1) return const ui.TargetImageSize();
          return ui.TargetImageSize(
            width: (w * scale).ceil(),
            height: (h * scale).ceil(),
          );
        },
      );
      return (await codec.getNextFrame()).image;
    } catch (e) {
      debugPrint('Foto dilewati ($path): $e');
      return null;
    } finally {
      codec?.dispose();
    }
  }

  Future<ui.Image> _paintFrame(
    ui.Image from,
    ui.Image to,
    double blend,
    BodyEntry caption,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    _drawCover(canvas, from, 1);
    if (blend > 0) _drawCover(canvas, to, blend);
    _drawCaption(canvas, caption);
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(width, height);
    } finally {
      picture.dispose();
    }
  }

  void _drawCover(ui.Canvas canvas, ui.Image image, double opacity) {
    final iw = image.width.toDouble();
    final ih = image.height.toDouble();
    final scale = math.max(width / iw, height / ih);
    canvas.drawImageRect(
      image,
      ui.Rect.fromCenter(
        center: ui.Offset(iw / 2, ih / 2),
        width: width / scale,
        height: height / scale,
      ),
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()
        ..filterQuality = ui.FilterQuality.medium
        ..color = ui.Color.fromRGBO(255, 255, 255, opacity),
    );
  }

  void _drawCaption(ui.Canvas canvas, BodyEntry entry) {
    final top = height - _captionHeight;
    canvas.drawRect(
      ui.Rect.fromLTWH(0, top, width.toDouble(), _captionHeight),
      ui.Paint()..color = FNExport.night,
    );
    final kg = entry.weightKg;
    final date = Fmt.dateStamp(entry.day, withTime: false);
    final text = kg == null ? date : '$date · ${Fmt.number(kg, decimals: 1)} KG';
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(textAlign: ui.TextAlign.center, maxLines: 1),
          )
          ..pushStyle(
            ui.TextStyle(
              color: FNExport.paper,
              fontFamily: FNExport.mono,
              fontSize: 26,
              letterSpacing: 1.5,
            ),
          )
          ..addText(text);
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: width.toDouble()));
    canvas.drawParagraph(
      paragraph,
      ui.Offset(0, top + (_captionHeight - paragraph.height) / 2),
    );
    paragraph.dispose();
  }
}
