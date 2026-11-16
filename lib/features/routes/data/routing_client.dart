import 'package:virya/features/routes/domain/route_models.dart';

/// Kesalahan routing dengan pesan siap tampil (bahasa Indonesia).
class RoutingException implements Exception {
  final String message;

  /// `true` bila masalahnya koneksi (bukan data/rute).
  final bool offline;
  const RoutingException(this.message, {this.offline = false});

  @override
  String toString() => message;
}

/// Layanan pencari jalan. Diabstraksikan supaya test tidak butuh jaringan.
abstract class RoutingClient {
  /// Rute melewati [via] (minimal 2 titik) untuk [sport].
  /// [alternative] 0..3 meminta jalur alternatif bila layanan mendukung.
  Future<RoutePath> route(
    List<LatLon> via, {
    required RouteSport sport,
    bool avoidMain = false,
    int alternative = 0,
  });
}
