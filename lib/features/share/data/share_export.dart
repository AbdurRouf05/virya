import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Capture / save / share helpers for share cards and recap videos.
class ShareExport {
  ShareExport._();

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
    final f = File(p.join(d.path, 'stravo_${name}_${_stamp()}.png'));
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  /// New output path in documents/videos/.
  static Future<String> newVideoPath() async {
    final d = await docsSubdir('videos');
    return p.join(d.path, 'stravo_recap_${_stamp()}.mp4');
  }

  static Future<void> shareFile(String path, {String? text, String? mime}) =>
      SharePlus.instance.share(ShareParams(
        files: [XFile(path, mimeType: mime)],
        text: text,
      ));
}
