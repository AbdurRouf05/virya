import 'package:stravo/core/constants/enums.dart';

/// SHARED CONTRACT — output of `ActivityAnalyzer.analyze()`.
///
/// Produced by the analytics module, consumed by activity detail UI, share
/// cards, video renderer and 3D flyover. Add fields freely; never rename or
/// remove existing ones.
class ActivityAnalysis {
  final SportType sport;

  final double distanceM;
  final int movingTimeS;
  final int elapsedTimeS;
  final double elevationGainM;
  final double elevationLossM;
  final double maxEleM;
  final double minEleM;
  final double avgSpeedMps; // moving average
  final double maxSpeedMps;

  /// Grade Adjusted Pace expressed as equivalent flat speed (m/s). Runs only.
  final double? avgGapMps;
  final int? avgHeartRate;
  final int? maxHeartRate;
  final int? avgCadence;

  /// Estimated average power (W) for cycling from physics model.
  final double? avgPowerW;
  final double? energyKj;

  /// Normalized power (W) of the estimated power curve (cycling).
  final double? normalizedPowerW;

  /// Training load (TRIMP-like "Relative Effort").
  final double relativeEffort;

  /// Gravel-specific.
  final Map<SurfaceType, double> surfaceDistanceM;
  final double gravelPct; // 0..100 (smooth+rough gravel+dirt+cobble)
  final double gritScore; // 0..100 custom difficulty score
  final List<GravelSector> gravelSectors;

  final List<Climb> climbs;
  final List<Split> splits; // per km
  final List<BestEffort> bestEfforts;
  final Map<int, int> hrZoneSeconds; // zone 1..5 -> seconds

  /// Down-sampled series for charts / animation (<= ~600 points).
  /// Index aligned across all lists in [series].
  final ActivitySeries series;

  /// Bounding box of the track.
  final double minLat, minLon, maxLat, maxLon;

  const ActivityAnalysis({
    required this.sport,
    required this.distanceM,
    required this.movingTimeS,
    required this.elapsedTimeS,
    required this.elevationGainM,
    required this.elevationLossM,
    required this.maxEleM,
    required this.minEleM,
    required this.avgSpeedMps,
    required this.maxSpeedMps,
    this.avgGapMps,
    this.avgHeartRate,
    this.maxHeartRate,
    this.avgCadence,
    this.avgPowerW,
    this.energyKj,
    this.normalizedPowerW,
    this.relativeEffort = 0,
    this.surfaceDistanceM = const {},
    this.gravelPct = 0,
    this.gritScore = 0,
    this.gravelSectors = const [],
    this.climbs = const [],
    this.splits = const [],
    this.bestEfforts = const [],
    this.hrZoneSeconds = const {},
    required this.series,
    required this.minLat,
    required this.minLon,
    required this.maxLat,
    required this.maxLon,
  });
}

/// Aligned, down-sampled series. All lists have identical length.
class ActivitySeries {
  final List<double> distanceM; // cumulative
  final List<int> elapsedS; // seconds since start
  final List<double> lat;
  final List<double> lon;
  final List<double> ele; // smoothed, meters
  final List<double> speedMps; // smoothed
  final List<double> gradePct; // smoothed
  final List<int?> heartRate;
  final List<SurfaceType> surface;

  const ActivitySeries({
    required this.distanceM,
    required this.elapsedS,
    required this.lat,
    required this.lon,
    required this.ele,
    required this.speedMps,
    required this.gradePct,
    required this.heartRate,
    required this.surface,
  });

  int get length => distanceM.length;

  static const empty = ActivitySeries(
    distanceM: [],
    elapsedS: [],
    lat: [],
    lon: [],
    ele: [],
    speedMps: [],
    gradePct: [],
    heartRate: [],
    surface: [],
  );
}

class Split {
  final int index; // 1-based km number
  final double distanceM; // usually 1000, last may be shorter
  final int movingTimeS;
  final double elevationDeltaM;
  final double? gapMps;
  final int? avgHeartRate;
  const Split({
    required this.index,
    required this.distanceM,
    required this.movingTimeS,
    required this.elevationDeltaM,
    this.gapMps,
    this.avgHeartRate,
  });
  double get speedMps => movingTimeS == 0 ? 0 : distanceM / movingTimeS;
}

class Climb {
  final double startDistanceM;
  final double endDistanceM;
  final double gainM;
  final double avgGradePct;
  final double maxGradePct;
  final ClimbCategory category;
  final int durationS;

  /// VAM — vertical meters per hour.
  final double vam;
  const Climb({
    required this.startDistanceM,
    required this.endDistanceM,
    required this.gainM,
    required this.avgGradePct,
    required this.maxGradePct,
    required this.category,
    required this.durationS,
    required this.vam,
  });
  double get lengthM => endDistanceM - startDistanceM;
}

/// Auto-detected unpaved stretch, rated like classic-race cobbled sectors.
class GravelSector {
  final int number; // counted from finish like classic races (1 = last)
  final String name; // generated, e.g. "Sektor 3 · Tanjakan Batu"
  final double startDistanceM;
  final double endDistanceM;
  final SurfaceType dominantSurface;
  final int stars; // 1..5 difficulty
  final double avgGradePct;
  final double roughness; // mean vibration RMS
  const GravelSector({
    required this.number,
    required this.name,
    required this.startDistanceM,
    required this.endDistanceM,
    required this.dominantSurface,
    required this.stars,
    required this.avgGradePct,
    required this.roughness,
  });
  double get lengthM => endDistanceM - startDistanceM;
}

class BestEffort {
  final String label; // "1K", "5K", "10K", "Half", "20 min", ...
  final double distanceM;
  final int timeS;
  final double startDistanceM;
  const BestEffort({
    required this.label,
    required this.distanceM,
    required this.timeS,
    required this.startDistanceM,
  });
}

/// Daily fitness/fatigue/form (CTL/ATL/TSB) point.
class FitnessDay {
  final DateTime day;
  final double load; // relative effort that day
  final double fitness; // CTL (42d)
  final double fatigue; // ATL (7d)
  double get form => fitness - fatigue; // TSB
  const FitnessDay({
    required this.day,
    required this.load,
    required this.fitness,
    required this.fatigue,
  });
}

/// Athlete parameters used by analysis.
class AthleteParams {
  final double weightKg;
  final double bikeWeightKg;
  final int maxHr;
  final int restHr;

  /// Functional threshold power; null = estimate 2.8 W/kg.
  final double? ftpW;
  const AthleteParams({
    this.weightKg = 70,
    this.bikeWeightKg = 10,
    this.maxHr = 190,
    this.restHr = 55,
    this.ftpW,
  });
}
