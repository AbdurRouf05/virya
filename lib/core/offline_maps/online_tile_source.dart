import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Thrown when the upstream server cannot be reached or misbehaves.
class TileFetchException implements Exception {
  final String message;
  const TileFetchException(this.message);
  @override
  String toString() => 'TileFetchException: $message';
}

/// Free, key-less OpenFreeMap vector tiles (OpenMapTiles schema, z0–14).
///
/// The tile URL is versioned, so it is read from the TileJSON and kept in
/// memory for a few hours.
class OnlineTileSource {
  OnlineTileSource({HttpClient? client, this.tileJsonUrl = defaultTileJson})
    : _client =
          client ??
          (HttpClient()
            ..connectionTimeout = const Duration(seconds: 8)
            ..userAgent = userAgent);

  static const defaultTileJson = 'https://tiles.openfreemap.org/planet';
  static const userAgent = 'Virya/1.0 (personal app)';
  static const maxZoom = 14;
  static const attributionHost = 'tiles.openfreemap.org';

  final String tileJsonUrl;
  final HttpClient _client;
  String? _template;
  DateTime _templateAt = DateTime.fromMillisecondsSinceEpoch(0);
  Future<String>? _resolving;

  Future<String> _resolveTemplate() async {
    final t = _template;
    if (t != null && DateTime.now().difference(_templateAt).inHours < 6) {
      return t;
    }
    return _resolving ??= _fetchTemplate().whenComplete(
      () => _resolving = null,
    );
  }

  Future<String> _fetchTemplate() async {
    final body = await _get(Uri.parse(tileJsonUrl));
    if (body == null) throw const TileFetchException('TileJSON tidak ada');
    final json = jsonDecode(utf8.decode(body));
    final tiles = json is Map ? json['tiles'] : null;
    if (tiles is! List || tiles.isEmpty || tiles.first is! String) {
      throw const TileFetchException('TileJSON tidak valid');
    }
    _template = tiles.first as String;
    _templateAt = DateTime.now();
    return _template!;
  }

  /// Tile bytes, or null when the tile does not exist upstream (empty).
  /// Throws [TileFetchException] when offline / server error.
  Future<Uint8List?> fetch(int z, int x, int y) async {
    final tpl = await _resolveTemplate();
    final url = tpl
        .replaceAll('{z}', '$z')
        .replaceAll('{x}', '$x')
        .replaceAll('{y}', '$y');
    final data = await _get(Uri.parse(url));
    // Some servers send raw gzip without Content-Encoding; MapLibre needs
    // plain protobuf.
    if (data != null && data.length > 2 && data[0] == 0x1f && data[1] == 0x8b) {
      return Uint8List.fromList(gzip.decode(data));
    }
    return data;
  }

  Future<Uint8List?> _get(Uri uri) async {
    try {
      final req = await _client.getUrl(uri);
      req.headers.set(HttpHeaders.userAgentHeader, userAgent);
      final res = await req.close().timeout(const Duration(seconds: 15));
      if (res.statusCode == HttpStatus.notFound ||
          res.statusCode == HttpStatus.noContent) {
        await res.drain<void>();
        return null;
      }
      if (res.statusCode != HttpStatus.ok) {
        await res.drain<void>();
        throw TileFetchException('HTTP ${res.statusCode}');
      }
      final b = BytesBuilder(copy: false);
      await for (final c in res.timeout(const Duration(seconds: 20))) {
        b.add(c);
      }
      return b.takeBytes();
    } on TileFetchException {
      rethrow;
    } catch (e) {
      throw TileFetchException('$e');
    }
  }

  void close() => _client.close(force: true);
}
