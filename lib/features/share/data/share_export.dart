import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Capture / save / share helpers for share cards and recap videos.
class ShareExport {
  ShareExport._();

  static const _mediaChannel = MethodChannel('virya/media_saver');

  static Future<Directory> docsSubdir(String name) async {
    final docs = await getApplicationDocumentsDirectory();
    final d = Directory(p.join(docs.path, name));
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  /// Renders the RepaintBoundary under [key] to PNG at [pixelRatio].
  static Future<Uint8List> capturePng(GlobalKey key, double pixelRatio) async {
    final ro = key.currentContext?.findRenderObject();
    if (ro is! RenderRepaintBoundary) {
      throw StateError('Kartu belum siap dirender');
    }
    final img = await ro.toImage(pixelRatio: pixelRatio);
    try {
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) throw StateError('Gagal meng-encode PNG');
      return bd.buffer.asUint8List();
    } finally {
      img.dispose();
    }
  }

  static String _stamp() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${two(n.month)}${two(n.day)}_${two(n.hour)}${two(n.minute)}${two(n.second)}';
  }

  /// Saves PNG bytes into documents/shares/.
  static Future<File> savePng(Uint8List bytes, String name) async {
    final d = await docsSubdir('shares');
    await _pruneOldFiles(d, 20);
    final f = File(p.join(d.path, 'virya_${name}_${_stamp()}.png'));
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  /// Exports a local PNG file to the public Gallery (Pictures/Virya).
  static Future<String> exportImageToGallery(File file, String name) async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final res = await _mediaChannel.invokeMethod<String>('saveImageToGallery', {
          'path': file.path,
          'name': 'virya_${name}_${_stamp()}.png',
        });
        if (res != null && res.isNotEmpty) return res;
      } catch (e) {
        debugPrint('MediaSaver saveImage error: $e');
      }
    }
    return file.path;
  }

  /// Exports a local MP4 video file to the public Gallery (Movies/Virya).
  static Future<String> exportVideoToGallery(String videoPath) async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final res = await _mediaChannel.invokeMethod<String>('saveVideoToGallery', {
          'path': videoPath,
          'name': 'virya_recap_${_stamp()}.mp4',
        });
        if (res != null && res.isNotEmpty) return res;
      } catch (e) {
        debugPrint('MediaSaver saveVideo error: $e');
      }
    }
    return videoPath;
  }

  /// New output path in documents/videos/.
  static Future<String> newVideoPath() async {
    final d = await docsSubdir('videos');
    await _pruneOldFiles(d, 10);
    return p.join(d.path, 'virya_recap_${_stamp()}.mp4');
  }

  static Future<void> _pruneOldFiles(Directory dir, int keepMax) async {
    try {
      final files = await dir.list().where((e) => e is File).cast<File>().toList();
      if (files.length <= keepMax) return;
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      for (final f in files.skip(keepMax)) {
        try {
          await f.delete();
        } catch (_) {}
      }
    } catch (_) {}
  }

  static Future<void> shareFile(String path, {String? text, String? mime}) =>
      SharePlus.instance.share(ShareParams(
        files: [XFile(path, mimeType: mime)],
        text: text,
      ));
}
