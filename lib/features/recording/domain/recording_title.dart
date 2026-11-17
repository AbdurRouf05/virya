import 'package:virya/core/constants/enums.dart';

/// Default activity title, e.g. "Gravel Pagi", from sport and start time.
String defaultRecordingTitle(SportType sport, DateTime t) {
  final part = t.hour < 11
      ? 'Pagi'
      : t.hour < 15
          ? 'Siang'
          : t.hour < 18
              ? 'Sore'
              : 'Malam';
  final name = switch (sport) {
    SportType.gravelCycling => 'Gravel',
    SportType.roadCycling => 'Gowes',
    SportType.mountainBiking => 'MTB',
    SportType.roadRunning => 'Lari',
    SportType.trailRunning => 'Trail Run',
    SportType.hiking => 'Hiking',
    SportType.walking => 'Jalan',
    SportType.strength => 'Gym',
  };
  return '$name $part';
}
