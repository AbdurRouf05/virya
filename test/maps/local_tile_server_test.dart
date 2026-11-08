import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stravo/core/offline_maps/local_tile_server.dart';

void main() {
  late Directory tmp;
  late LocalTileServer server;
  late Uri base;
  late HttpClient client;
  final data = Uint8List.fromList(List.generate(4096, (i) => i % 251));

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('stravo_maps_');
    final packs = await Directory(p.join(tmp.path, 'maps')).create();
    await File(p.join(packs.path, 'jawa.pmtiles')).writeAsBytes(data);
    await File(p.join(tmp.path, 'outside.txt')).writeAsString('secret');
    server = LocalTileServer(
      packsDir: () async => packs,
      assetLoader: (key) async {
        if (key == 'assets/map/map.html') {
          return Uint8List.fromList(utf8.encode('<html>ok</html>'));
        }
        throw Exception('missing $key');
      },
    );
    base = await server.start();
    client = HttpClient();
  });

  tearDown(() async {
    client.close(force: true);
    await server.stop();
    await tmp.delete(recursive: true);
  });

  Future<(HttpClientResponse, List<int>)> get(String path,
      {String method = 'GET', String? range, List<int>? body}) async {
    final req = await client.openUrl(method, base.resolve(path));
    if (range != null) req.headers.set('Range', range);
    if (body != null) req.add(body);
    final res = await req.close();
    final bytes = <int>[];
    await for (final c in res) {
      bytes.addAll(c);
    }
    return (res, bytes);
  }

  test('starts on an ephemeral loopback port, idempotent', () async {
    expect(base.host, '127.0.0.1');
    expect(base.port, greaterThan(0));
    expect(await server.start(), base);
  });

  test('Range request → 206 with exact bytes', () async {
    final (res, bytes) = await get('/packs/jawa.pmtiles', range: 'bytes=100-227');
    expect(res.statusCode, 206);
    expect(res.headers.value('content-range'), 'bytes 100-227/4096');
    expect(res.headers.value('access-control-allow-origin'), '*');
    expect(res.headers.value('accept-ranges'), 'bytes');
    expect(res.headers.contentType?.mimeType, 'application/octet-stream');
    expect(bytes, data.sublist(100, 228));
  });

  test('full GET → 200', () async {
    final (res, bytes) = await get('/packs/jawa.pmtiles');
    expect(res.statusCode, 200);
    expect(bytes.length, 4096);
  });

  test('HEAD returns length without body', () async {
    final (res, bytes) = await get('/packs/jawa.pmtiles', method: 'HEAD');
    expect(res.statusCode, 200);
    expect(res.contentLength, 4096);
    expect(bytes, isEmpty);
  });

  test('unsatisfiable range → 416', () async {
    final (res, _) = await get('/packs/jawa.pmtiles', range: 'bytes=9000-9100');
    expect(res.statusCode, 416);
    expect(res.headers.value('content-range'), 'bytes */4096');
  });

  test('missing pack → 404, traversal blocked', () async {
    expect((await get('/packs/nope.pmtiles')).$1.statusCode, 404);
    final (res, bytes) = await get('/packs/..%2Foutside.txt');
    expect(res.statusCode, anyOf(403, 404));
    expect(utf8.decode(bytes, allowMalformed: true), isNot(contains('secret')));
  });

  test('serves bundled app assets', () async {
    final (res, bytes) = await get('/app/map.html');
    expect(res.statusCode, 200);
    expect(res.headers.contentType?.mimeType, 'text/html');
    expect(utf8.decode(bytes), '<html>ok</html>');
    expect((await get('/app/missing.js')).$1.statusCode, 404);
  });

  test('capture endpoint forwards frames only with valid token', () async {
    final got = <int, List<int>>{};
    final token = server.registerCaptureSink((i, b) => got[i] = b);
    final (ok, _) = await get('/capture/$token/7', method: 'POST', body: [1, 2, 3]);
    expect(ok.statusCode, 204);
    expect(got[7], [1, 2, 3]);
    final (bad, _) = await get('/capture/wrong/1', method: 'POST', body: [9]);
    expect(bad.statusCode, 403);
    server.unregisterCaptureSink(token);
  });
}
