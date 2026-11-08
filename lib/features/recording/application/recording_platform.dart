import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:stravo/core/location/location_source.dart';
import 'package:stravo/core/location/sources/geolocator_location_source.dart';
import 'package:stravo/core/location/sources/simulated_location_source.dart';
import 'package:stravo/core/sensors/sensor_sources.dart';

/// Plugin-touching factories used by the recording controller.
/// Override [recordingPlatformProvider] in tests.
class RecordingPlatform {
  const RecordingPlatform();

  LocationSource createLocationSource({
    required bool simulated,
    double speedUp = 10,
    String? notificationLabel,
  }) =>
      simulated
          ? SimulatedLocationSource(speedUp: speedUp)
          : GeolocatorLocationSource(notificationLabel: notificationLabel);

  VibrationSource createVibrationSource(LocationSource location) =>
      location is SimulatedLocationSource
          ? SimulatedVibrationSource(location)
          : AccelerometerVibrationSource();

  PressureSource createPressureSource({required bool simulated}) =>
      simulated ? NoPressureSource() : BarometerPressureSource();

  Future<void> setKeepAwake(bool on) async {
    try {
      on ? await WakelockPlus.enable() : await WakelockPlus.disable();
    } catch (_) {}
  }

  Future<Directory> photosDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'photos'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}

final recordingPlatformProvider =
    Provider<RecordingPlatform>((ref) => const RecordingPlatform());
