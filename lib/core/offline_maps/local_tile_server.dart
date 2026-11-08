import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:stravo/core/offline_maps/http_utils.dart';
import 'package:stravo/core/offline_maps/map_storage.dart';

/// Loads a bundled asset by full key, e.g. `assets/map/map.html`.
typedef AssetLoader = Future<Uint8List> Function(String assetKey);
typedef FrameSink = void Function(int frame, Uint8List bytes);

/// Tiny localhost HTTP server for the MapLibre WebView.
///
/// - `GET|HEAD /app/<file>`   bundled `assets/map/<file>`
/// - `GET|HEAD /fonts/<file>` bundled `assets/fonts/<file>` (HUD in frames)
/// - `GET|HEAD /packs/<file>` PMTiles from `<docs>/maps/` (Range → 206)
/// - `POST /capture/<token>/<frame>` JPEG frames during video export
///
/// http:// is used because pmtiles.js needs Range requests (file:// can't).
class LocalTileServer {
  LocalTileServer({
    Future<Directory> Function()? packsDir,
    AssetLoader? assetLoader,
  })  : _packsDir = packsDir ?? defaultMapsDir,
        _assetLoader = assetLoader ?? _bundleLoader;

  /// App-wide singleton, started lazily.
  static final LocalTileServer instance = LocalTileServer();

  final Future<Directory> Function() _packsDir;
  final AssetLoader _assetLoader;
  final Map<String, Uint8List> _assetCache = {};
  final Map<String, FrameSink> _sinks = {};
  HttpServer? _server;
  Future<Uri>? _starting;

  static Future<Uint8List> _bundleLoader(String key) async {
    final data = await rootBundle.load(key);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Uri? get baseUri {
    final s = _server;
    return s == null ? null : Uri.parse('http://127.0.0.1:${s.port}');
  }

  /// Starts once (random port) and returns the base URI.
  Future<Uri> start() {
    final b = baseUri;
    if (b != null) return Future.value(b);
    return _starting ??= _bind();
  }

  Future<Uri> _bind() async {
    try {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.autoCompress = false;
      _server = server;
      server.listen(_handle, onError: (Object e) {
        debugPrint('LocalTileServer: $e');
      });
      return baseUri!;
    } finally {
      _starting = null;
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  /// Registers a sink for exported frames. Returns the URL token.
  String registerCaptureSink(FrameSink sink) {
    final r = math.Random.secure();
    final token = List.generate(16, (_) => r.nextInt(16).toRadixString(16))
        .join();
    _sinks[token] = sink;
    return token;
  }

  void unregisterCaptureSink(String token) => _sinks.remove(token);

  Future<void> _handle(HttpRequest req) async {
    final res = req.response;
    res.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Headers', 'Range, Content-Type')
      ..set('Access-Control-Expose-Headers',
          'Content-Length, Content-Range, Accept-Ranges, ETag');
    try {
      final segs = req.uri.pathSegments;
      if (req.method == 'OPTIONS') {
        res.statusCode = HttpStatus.noContent;
      } else if (segs.isEmpty) {
        res.statusCode = HttpStatus.notFound;
      } else if (segs.first == 'capture' && req.method == 'POST') {
        await _capture(req, segs);
      } else if (req.method != 'GET' && req.method != 'HEAD') {
        res.statusCode = HttpStatus.methodNotAllowed;
      } else if (segs.first == 'app') {
        await _serveAsset(req, 'assets/map/', _rest(req));
      } else if (segs.first == 'fonts') {
        await _serveAsset(req, 'assets/fonts/', _rest(req));
      } else if (segs.first == 'packs') {
        await _servePack(req, _rest(req));
      } else {
        res.statusCode = HttpStatus.notFound;
      }
    } catch (e) {
      debugPrint('LocalTileServer ${req.uri}: $e');
      try {
        res.statusCode = HttpStatus.internalServerError;
      } catch (_) {}
    }
    try {
      await res.close();
    } catch (_) {}
  }

  /// Raw (still percent-encoded) path after the first segment.
  String _rest(HttpRequest req) {
    final path = req.uri.path; // e.g. /packs/jawa.pmtiles
    final i = path.indexOf('/', 1);
    return i < 0 ? '' : path.substring(i + 1);
  }

  Future<void> _capture(HttpRequest req, List<String> segs) async {
    final res = req.response;
    final sink = segs.length == 3 ? _sinks[segs[1]] : null;
    final frame = segs.length == 3 ? int.tryParse(segs[2]) : null;
    if (sink == null || frame == null) {
      res.statusCode = HttpStatus.forbidden;
      return;
    }
    final b = BytesBuilder(copy: false);
    await for (final chunk in req) {
      b.add(chunk);
    }
    sink(frame, b.takeBytes());
    res.statusCode = HttpStatus.noContent;
  }

  Future<void> _serveAsset(HttpRequest req, String prefix, String raw) async {
    final rel = sanitizeRelativePath(raw);
    if (rel == null) {
      req.response.statusCode = HttpStatus.forbidden;
      return;
    }
    final key = '$prefix$rel';
    Uint8List? bytes = _assetCache[key];
    if (bytes == null) {
      try {
        bytes = await _assetLoader(key);
      } catch (_) {
        req.response.statusCode = HttpStatus.notFound;
        return;
      }
      _assetCache[key] = bytes;
    }
    final res = req.response;
    res.headers
      ..contentType = ContentType.parse(contentTypeFor(rel))
      ..set('Cache-Control', 'no-cache')
      ..set('Accept-Ranges', 'bytes');
    final range = parseRange(req.headers.value('range'), bytes.length);
    switch (range) {
      case UnsatisfiableRange():
        res.statusCode = HttpStatus.requestedRangeNotSatisfiable;
        res.headers.set('Content-Range', 'bytes */${bytes.length}');
      case PartialRange(:final start, :final end):
        res.statusCode = HttpStatus.partialContent;
        res.headers
          ..set('Content-Range', 'bytes $start-$end/${bytes.length}')
          ..contentLength = end - start + 1;
        if (req.method != 'HEAD') res.add(bytes.sublist(start, end + 1));
      case FullRange():
        res.statusCode = HttpStatus.ok;
        res.headers.contentLength = bytes.length;
        if (req.method != 'HEAD') res.add(bytes);
    }
  }

  Future<void> _servePack(HttpRequest req, String raw) async {
    final res = req.response;
    final rel = sanitizeRelativePath(raw);
    if (rel == null) {
      res.statusCode = HttpStatus.forbidden;
      return;
    }
    final root = await _packsDir();
    final file = File(p.joinAll([root.path, ...rel.split('/')]));
    // Belt and braces: resolved path must stay inside root.
    if (!p.isWithin(p.normalize(root.path), p.normalize(file.path)) ||
        !await file.exists()) {
      res.statusCode = HttpStatus.notFound;
      return;
    }
    final stat = await file.stat();
    final size = stat.size;
    res.headers
      ..contentType = ContentType.parse(contentTypeFor(rel))
      ..set('Accept-Ranges', 'bytes')
      ..set('ETag', '"$size-${stat.modified.millisecondsSinceEpoch}"')
      ..set('Cache-Control', 'no-cache');
    final range = parseRange(req.headers.value('range'), size);
    switch (range) {
      case UnsatisfiableRange():
        res.statusCode = HttpStatus.requestedRangeNotSatisfiable;
        res.headers.set('Content-Range', 'bytes */$size');
      case PartialRange(:final start, :final end):
        res.statusCode = HttpStatus.partialContent;
        res.headers
          ..set('Content-Range', 'bytes $start-$end/$size')
          ..contentLength = end - start + 1;
        if (req.method != 'HEAD') {
          await res.addStream(file.openRead(start, end + 1));
        }
      case FullRange():
        res.statusCode = HttpStatus.ok;
        res.headers.contentLength = size;
        if (req.method != 'HEAD') await res.addStream(file.openRead());
    }
  }
}
