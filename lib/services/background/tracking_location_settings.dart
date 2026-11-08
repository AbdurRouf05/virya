import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stravo/app/theme/field_notes.dart';

/// Location settings for live recording.
///
/// On Android, geolocator's `foregroundNotificationConfig` starts its own
/// location foreground service (declared by the plugin manifest with
/// `foregroundServiceType="location"`), so tracking survives screen-off and
/// app backgrounding without a separate flutter_foreground_task isolate.
LocationSettings trackingLocationSettings({String? sportLabel}) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      intervalDuration: const Duration(seconds: 1),
      foregroundNotificationConfig: ForegroundNotificationConfig(
        notificationTitle: 'Stravo merekam${sportLabel == null ? '' : ' · $sportLabel'}',
        notificationText: 'GPS aktif. Ketuk untuk kembali ke rekaman.',
        notificationChannelName: 'Rekaman aktivitas',
        enableWakeLock: true,
        setOngoing: true,
        color: FN.signal,
      ),
    );
  }
  if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    return AppleSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      activityType: ActivityType.fitness,
      distanceFilter: 0,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
      allowBackgroundLocationUpdates: true,
    );
  }
  return const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
  );
}
