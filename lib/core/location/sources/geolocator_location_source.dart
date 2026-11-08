import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:stravo/core/location/location_fix.dart';
import 'package:stravo/core/location/location_source.dart';
import 'package:stravo/services/background/tracking_location_settings.dart';

/// Real GNSS via geolocator (1 Hz, best accuracy, foreground service).
class GeolocatorLocationSource implements LocationSource {
  final String? notificationLabel;
  StreamSubscription<Position>? _sub;
  StreamController<LocationFix>? _out;

  GeolocatorLocationSource({this.notificationLabel});

  @override
  bool get isSimulated => false;

  @override
  Stream<LocationFix> start() {
    _out?.close();
    final out = StreamController<LocationFix>();
    _out = out;
    final stream = Geolocator.getPositionStream(
      locationSettings: trackingLocationSettings(sportLabel: notificationLabel),
    );
    _sub = stream.listen(
      (p) => out.add(fromPosition(p)),
      onError: out.addError,
    );
    return out.stream;
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _out?.close();
    _out = null;
  }

  static LocationFix fromPosition(Position p) => LocationFix(
        time: p.timestamp.toLocal(),
        lat: p.latitude,
        lon: p.longitude,
        altitude: p.altitude == 0 && p.altitudeAccuracy == 0 ? null : p.altitude,
        accuracy: p.accuracy,
        // Android reports 0/0 when the fix carries no speed: derive instead.
        speed: p.speed == 0 && p.speedAccuracy == 0 ? null : p.speed,
        heading: p.heading >= 0 ? p.heading : null,
      );
}
