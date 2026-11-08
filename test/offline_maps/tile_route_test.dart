import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/offline_maps/local_tile_server.dart';
import 'package:virya/core/offline_maps/online_tile_source.dart';
import 'package:virya/core/offline_maps/tile_proxy.dart';
import 'package:virya/core/offline_maps/tile_store.dart';

class _Source extends OnlineTileSource {
  @override
  Future<Uint8List?> fetch(int z, int x, int y) async {
    if (x == 0) throw const TileFetchException('offline');
    return Uint8List.fromList([1, 2, 3]);
  }
}

void main() {
  test('/tiles route: 200 with bytes, 204 when unavailable, 404 malformed',
      () async {
    final tmp = await Directory.systemTemp.createTemp('virya_route_');
    final source = _Source();
    final proxy = TileProxy(
      regions: TileStore(() async => Directory('${tmp.path}/r')),
      cache: TileStore(() async => Directory('${tmp.path}/c'), maxBytes: 1 << 20),
      source: source,
    );
    final server = LocalTileServer(packsDir: () async => tmp, tiles: proxy);
    final base = await server.start();
    final client = HttpClient();
    Future<HttpClientResponse> get(String path) async =>
        (await client.getUrl(base.resolve(path))).close();
    try {
      final ok = await get('/tiles/3/1/1.pbf');
      expect(ok.statusCode, 200);
      expect(ok.headers.contentType?.mimeType, 'application/x-protobuf');
      expect(await ok.expand((c) => c).toList(), [1, 2, 3]);

      final miss = await get('/tiles/3/0/1.pbf');
      expect(miss.statusCode, 204);
      await miss.drain<void>();

      final bad = await get('/tiles/3/1/x.pbf');
      expect(bad.statusCode, 404);
      await bad.drain<void>();
    } finally {
      client.close(force: true);
      source.close();
      await server.stop();
      await tmp.delete(recursive: true);
    }
  });
}
