import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/models/track_sample.dart';

/// Activity decoded from a file, before it touches the database.
class ParsedActivity {
  final String? title;
  final SportType? sport; // null = unknown
  final List<TrackSample> samples;
  final String format; // gpx | tcx | fit
  final String? sourceName; // file name inside the import

  const ParsedActivity({
    this.title,
    this.sport,
    required this.samples,
    required this.format,
    this.sourceName,
  });

  DateTime get startTime => samples.first.time;

  ParsedActivity copyWith({String? title, SportType? sport}) => ParsedActivity(
    title: title ?? this.title,
    sport: sport ?? this.sport,
    samples: samples,
    format: format,
    sourceName: sourceName,
  );
}

/// Map free-form type strings (Strava types, GPX `type`, TCX Sport) to a
/// sport. Returns null when unknown.
SportType? sportFromString(String? raw) {
  if (raw == null) return null;
  final s = raw.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');
  if (s.isEmpty) return null;
  if (s.contains('gravel') || s.contains('cyclocross')) {
    return SportType.gravelCycling;
  }
  if (s.contains('mountain') || s.contains('mtb') || s.contains('downhill')) {
    return SportType.mountainBiking;
  }
  if (s.contains('trail') && s.contains('run')) return SportType.trailRunning;
  if (s.contains('run') || s == 'jog' || s.contains('jogging')) {
    return SportType.roadRunning;
  }
  if (s.contains('weight') || s.contains('strength') || s == 'gym') {
    return SportType.strength;
  }
  if (s.contains('hik')) return SportType.hiking;
  if (s.contains('walk')) return SportType.walking;
  if (s.contains('ride') ||
      s.contains('bik') ||
      s.contains('cycl') ||
      s.contains('velo')) {
    return SportType.roadCycling;
  }
  // Strava numeric GPX types: 1 = ride, 9 = run, 4 = hike, 10 = walk.
  switch (s) {
    case '1':
      return SportType.roadCycling;
    case '9':
      return SportType.roadRunning;
    case '4':
      return SportType.hiking;
    case '10':
      return SportType.walking;
  }
  return null;
}

/// Strava-style type name used when exporting.
String stravaTypeName(SportType s) => switch (s) {
  SportType.gravelCycling => 'GravelRide',
  SportType.roadCycling => 'Ride',
  SportType.mountainBiking => 'MountainBikeRide',
  SportType.roadRunning => 'Run',
  SportType.trailRunning => 'TrailRun',
  SportType.hiking => 'Hike',
  SportType.walking => 'Walk',
  SportType.strength => 'WeightTraining',
};

/// FIT `sport` / `sub_sport` codes → sport.
SportType? sportFromFit(int? sport, int? subSport) {
  switch (sport) {
    case 1: // running
      return subSport == 3 ? SportType.trailRunning : SportType.roadRunning;
    case 2: // cycling
      if (subSport == 46 || subSport == 11 || subSport == 49) {
        return SportType.gravelCycling; // gravel, cyclocross, mixed surface
      }
      if (subSport == 8 || subSport == 9 || subSport == 47) {
        return SportType.mountainBiking;
      }
      return SportType.roadCycling;
    case 11:
      return SportType.walking;
    case 17:
      return SportType.hiking;
    case 21: // e-biking
      return SportType.roadCycling;
  }
  return null;
}
