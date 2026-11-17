import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:virya/features/routes/data/routing_client.dart';
import 'package:virya/features/routes/data/routing_parsers.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/domain/routing_profile.dart';

/// Routing lewat server publik BRouter (brouter.de); bila servernya gagal,
/// mencoba OSRM routing.openstreetmap.de. Hanya dipakai saat membuat rute.
class BrouterClient implements RoutingClient {
  BrouterClient({HttpClient? client})
      : _client = client ??
            (HttpClient()
              ..connectionTimeout = const Duration(seconds: 10)
              ..userAgent = userAgent);

  /// User-Agent generik, tanpa info pribadi.
  static const userAgent = 'Virya/1.0';
  static const brouterBase = 'https://brouter.de/brouter';
  static const osrmBase = 'https://routing.openstreetmap.de';
  static const _timeout = Duration(seconds: 30);
  static const _offline = RoutingException(
      'Tidak ada koneksi internet. Membuat rute butuh internet; '
      'rute yang sudah disimpan tetap bisa dipakai offline.',
      offline: true);

  final HttpClient _client;

  @override
  Future<RoutePath> route(
    List<LatLon> via, {
    required RouteSport sport,
    bool avoidMain = false,
    int alternative = 0,
  }) async {
    if (via.length < 2) {
      throw const RoutingException('Butuh minimal dua titik.');
    }
    final lonlats = via
        .map((p) => '${p.$2.toStringAsFixed(6)},${p.$1.toStringAsFixed(6)}')
        .join('|');
    final uri = Uri.parse('$brouterBase?lonlats=$lonlats'
        '&profile=${brouterProfile(sport, avoidMain: avoidMain)}'
        '&alternativeidx=${alternative.clamp(0, 3)}&format=geojson');
    try {
      final (status, body) = await _get(uri);
      if (status == 200) return parseBrouterGeoJson(body);
      final err = routingHttpError(status, body);
      if (status >= 500 && alternative == 0) return _osrm(via, sport, err);
      throw err;
    } on TimeoutException {
      if (alternative == 0) {
        return _osrm(via, sport,
            const RoutingException('Layanan rute terlalu lama menjawab.'));
      }
      throw const RoutingException('Layanan rute terlalu lama menjawab.');
    } on SocketException {
      throw _offline;
    } on HandshakeException {
      throw _offline;
    } on HttpException {
      throw _offline;
    }
  }

  Future<RoutePath> _osrm(
      List<LatLon> via, RouteSport sport, RoutingException original) async {
    final coords = via
        .map((p) => '${p.$2.toStringAsFixed(6)},${p.$1.toStringAsFixed(6)}')
        .join(';');
    final uri = Uri.parse('$osrmBase/${osrmProfile(sport)}/route/v1/driving/'
        '$coords?overview=full&geometries=geojson');
    try {
      final (status, body) = await _get(uri);
      if (status == 200) return parseOsrmJson(body);
    } catch (_) {
      // Abaikan; laporkan kesalahan aslinya.
    }
    throw original;
  }

  Future<(int, String)> _get(Uri uri) async {
    final req = await _client.getUrl(uri).timeout(_timeout);
    req.headers.set(HttpHeaders.userAgentHeader, userAgent);
    req.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final res = await req.close().timeout(_timeout);
    final body = await res.transform(utf8.decoder).join().timeout(_timeout);
    return (res.statusCode, body);
  }
}
