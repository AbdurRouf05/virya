import 'package:geolocator/geolocator.dart';

/// Thrown with a user-facing Indonesian message.
class PositionUnavailable implements Exception {
  final String message;
  const PositionUnavailable(this.message);
  @override
  String toString() => message;
}

/// One-shot GPS position (falls back to the last known fix).
Future<(double lat, double lon)> currentLatLon() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const PositionUnavailable('GPS nonaktif. Aktifkan Lokasi dulu.');
  }
  var perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) {
    perm = await Geolocator.requestPermission();
  }
  if (perm == LocationPermission.denied ||
      perm == LocationPermission.deniedForever) {
    throw const PositionUnavailable('Izin lokasi dibutuhkan untuk memilih area.');
  }
  try {
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 20),
      ),
    );
    return (p.latitude, p.longitude);
  } catch (_) {
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) return (last.latitude, last.longitude);
    throw const PositionUnavailable('Posisi belum didapat. Coba di tempat terbuka.');
  }
}
