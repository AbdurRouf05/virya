import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:virya/core/data/activity_repository.dart';
import 'package:virya/core/offline_maps/local_tile_server.dart';
import 'package:virya/features/maps/widgets/virya_map_controller.dart';
import 'package:virya/core/video/video_encoder.dart';

/// Subtitle burned into the exported flyover ("date · km · +gain").
/// [fallbackDistM] is used when the analysis has no distance.
String flyoverSubtitle(ActivityBundle b, double fallbackDistM) {
  final a = b.analysis;
  final km = (a.distanceM > 0 ? a.distanceM : fallbackDistM) / 1000;
  final gain =
      a.elevationGainM > 0 ? a.elevationGainM : b.activity.elevationGainMeters;
  final date = DateFormat('d MMM yyyy').format(b.activity.startTime);
  return '$date · ${km.toStringAsFixed(1)} KM · +${gain.round()} M';
}

/// Deterministic frame-by-frame MP4 export of a loaded flyover.
///
/// The WebView renders each frame (`renderFrame`) and posts the PNG either
/// to the local tile server capture sink or as base64 chunks over the JS
/// channel; frames are piped into [VideoEncoder]. Returns the MP4 path, or
/// null when cancelled. Throws on failure (encoder already cancelled).
Future<String?> exportFlyoverVideo({
  required ViryaMapController map,
  required Uri base,
  required int width,
  required int height,
  required int fps,
  required double seconds,
  required String title,
  required String subtitle,
  required bool pace,
  required bool Function() isCancelled,
  required void Function(String stage) onStage,
  required void Function(int done, int total) onFrame,
}) async {
  final waiters = <int, Completer<Uint8List>>{};
  final chunks = <int, List<String?>>{};
  final token = LocalTileServer.instance.registerCaptureSink((i, bytes) {
    final c = waiters[i];
    if (c != null && !c.isCompleted) c.complete(bytes);
  });
  final readyC = Completer<void>();
  final warmupC = Completer<void>();
  final sub = map.events.listen((e) {
    switch (e['type']) {
      case 'exportReady':
        if (!readyC.isCompleted) readyC.complete();
      case 'warmupDone':
        if (!warmupC.isCompleted) warmupC.complete();
      case 'frameChunk':
        final i = (e['i'] as num).toInt();
        final n = (e['n'] as num).toInt();
        final buf = chunks.putIfAbsent(i, () => List<String?>.filled(n, null));
        buf[(e['seq'] as num).toInt()] = e['data'] as String;
        if (buf.every((s) => s != null)) {
          chunks.remove(i);
          final c = waiters[i];
          if (c != null && !c.isCompleted) {
            c.complete(base64Decode(buf.join()));
          }
        }
      case 'frameError':
        final c = waiters[(e['i'] as num).toInt()];
        if (c != null && !c.isCompleted) {
          c.completeError(StateError('${e['msg']}'));
        }
    }
  });

  VideoEncoder? enc;
  try {
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = p.join(dir.path, 'virya_flyover_$stamp.mp4');
    enc = await VideoEncoder.start(
      outputPath: path,
      width: width,
      height: height,
      fps: fps,
    );
    await map.call('exportBegin', [
      {
        'w': width,
        'h': height,
        'quality': 0.85,
        'captureUrl': '$base/capture/$token',
        'title': title,
        'subtitle': subtitle,
        'pace': pace,
      },
    ]);
    await readyC.future.timeout(const Duration(seconds: 15));
    onStage('MEMUAT PETA');
    await map.call('exportWarmup', [24]);
    await warmupC.future.timeout(const Duration(seconds: 60));

    final total = (fps * seconds).round();
    final swTotal = Stopwatch()..start();
    var waitMs = 0, encMs = 0;

    waiters[0] = Completer<Uint8List>();
    await map.call('renderFrame', [0.0, 0]);

    for (var i = 0; i < total; i++) {
      if (isCancelled()) break;
      final swWait = Stopwatch()..start();
      final bytes =
          await waiters[i]!.future.timeout(const Duration(seconds: 30));
      waiters.remove(i);
      waitMs += swWait.elapsedMilliseconds;

      if (i + 1 < total && !isCancelled()) {
        waiters[i + 1] = Completer<Uint8List>();
        final nextT = (i + 1) / (total - 1);
        await map.call('renderFrame', [nextT, i + 1]);
      }

      final swEnc = Stopwatch()..start();
      await enc.addFramePng(bytes);
      encMs += swEnc.elapsedMilliseconds;

      onFrame(i + 1, total);

      if ((i + 1) % 60 == 0 || i == total - 1) {
        final count = (i % 60) + 1;
        debugPrint(
            '[flyover-perf] frame ${i + 1}/$total wait=${(waitMs / count).round()}ms encode=${(encMs / count).round()}ms');
        waitMs = 0;
        encMs = 0;
      }
    }
    debugPrint(
        '[flyover-perf] TOTAL ${swTotal.elapsedMilliseconds} ms untuk $total frame ($width×$height)');
    if (isCancelled()) {
      await enc.cancel();
      enc = null;
      return null;
    }
    onStage('MENYIMPAN MP4');
    final out = await enc.finish();
    enc = null;
    return out;
  } catch (_) {
    try {
      await enc?.cancel();
    } catch (_) {}
    rethrow;
  } finally {
    await sub.cancel();
    LocalTileServer.instance.unregisterCaptureSink(token);
    await map.call('exportEnd');
  }
}
