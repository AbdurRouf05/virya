import 'dart:typed_data';

import 'package:stravo/core/analytics/analysis_models.dart';
import 'package:stravo/core/analytics/best_efforts.dart';
import 'package:stravo/core/analytics/climbs.dart';
import 'package:stravo/core/analytics/effort.dart';
import 'package:stravo/core/analytics/elevation.dart';
import 'package:stravo/core/analytics/fitness.dart';
import 'package:stravo/core/analytics/gap.dart';
import 'package:stravo/core/analytics/gravel.dart';
import 'package:stravo/core/analytics/power.dart';
import 'package:stravo/core/analytics/prepared_track.dart';
import 'package:stravo/core/analytics/series_sampler.dart';
import 'package:stravo/core/analytics/splits.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/models/track_sample.dart';

/// SHARED CONTRACT — entry point for all activity analysis.
///
/// Signature is frozen; the analytics module owns the implementation.
/// Pure Dart, synchronous, deterministic (safe to run in `Isolate.run`).
class ActivityAnalyzer {
  const ActivityAnalyzer();

  /// Threshold speeds (m/s, grade adjusted) for HR-free relative effort.
  static const double runThresholdMps = 3.5;
  static const double walkThresholdMps = 1.6;

  ActivityAnalysis analyze(
    List<TrackSample> samples,
    SportType sport, {
    AthleteParams athlete = const AthleteParams(),
  }) {
    final p = PreparedTrack.build(samples, sport);
    if (p.n == 0) {
      return ActivityAnalysis(
        sport: sport,
        distanceM: 0,
        movingTimeS: 0,
        elapsedTimeS: 0,
        elevationGainM: 0,
        elevationLossM: 0,
        maxEleM: 0,
        minEleM: 0,
        avgSpeedMps: 0,
        maxSpeedMps: 0,
        series: ActivitySeries.empty,
        minLat: 0,
        minLon: 0,
        maxLat: 0,
        maxLon: 0,
      );
    }
    final n = p.n;
    final s = p.s;

    // Bounding box.
    var minLat = s[0].lat, maxLat = s[0].lat;
    var minLon = s[0].lon, maxLon = s[0].lon;
    for (final x in s) {
      if (x.lat < minLat) minLat = x.lat;
      if (x.lat > maxLat) maxLat = x.lat;
      if (x.lon < minLon) minLon = x.lon;
      if (x.lon > maxLon) maxLon = x.lon;
    }

    // Elevation.
    var maxEle = 0.0, minEle = 0.0, gain = 0.0, loss = 0.0;
    if (p.hasEle) {
      maxEle = p.ele[0];
      minEle = p.ele[0];
      for (var i = 1; i < n; i++) {
        if (p.ele[i] > maxEle) maxEle = p.ele[i];
        if (p.ele[i] < minEle) minEle = p.ele[i];
      }
      final gl = gainLoss(p.ele);
      gain = gl.gain;
      loss = gl.loss;
    }

    // Speed.
    final distance = p.distance;
    final movingS = p.movingTime;
    final avgSpeed = movingS > 0 ? distance / movingS : 0.0;
    final cap = maxPlausibleSpeed(sport);
    var maxSpeed = 0.0;
    for (var i = 0; i < n; i++) {
      final v = p.speed3[i];
      if ((i == 0 || p.moving[i] == 1) && v <= cap && v > maxSpeed) {
        maxSpeed = v;
      }
    }
    if (maxSpeed < avgSpeed) maxSpeed = avgSpeed;

    // HR / cadence.
    var hrSum = 0, hrN = 0, hrMax = 0, cadSum = 0, cadN = 0;
    for (final x in s) {
      if (x.paused) continue;
      final hr = x.heartRate;
      if (hr != null && hr > 0) {
        hrSum += hr;
        hrN++;
        if (hr > hrMax) hrMax = hr;
      }
      final c = x.cadence;
      if (c != null && c > 0) {
        cadSum += c;
        cadN++;
      }
    }

    // GAP (foot sports).
    final foot = !sport.isCycling;
    Float64List? gapCum;
    double? avgGap;
    if (foot) {
      gapCum = Float64List(n);
      for (var i = 1; i < n; i++) {
        gapCum[i] = gapCum[i - 1] +
            (p.moving[i] == 1 ? p.dd[i] * gapFactor(p.grade[i]) : 0);
      }
      avgGap = movingS > 0 ? gapCum[n - 1] / movingS : null;
    }

    // Power (cycling).
    double? avgPower, energyKj, np;
    if (sport.isCycling) {
      final mass = athlete.weightKg + athlete.bikeWeightKg;
      final pw = <double>[], pdt = <double>[];
      var joules = 0.0;
      for (var i = 1; i < n; i++) {
        if (p.moving[i] != 1) continue;
        final v = p.dt[i] > 5 ? p.speed[i] : p.speed3[i];
        final w = cyclingPowerW(
          speed: v,
          grade: p.grade[i],
          massKg: mass,
          surface: s[i].surface,
        );
        joules += w * p.dt[i];
        pw.add(w);
        pdt.add(p.dt[i]);
      }
      if (movingS > 0) {
        avgPower = joules / movingS;
        energyKj = joules / 1000;
        np = normalizedPower(pw, pdt);
      }
    }

    // Relative effort.
    var effort = banisterTrimp(p, athlete);
    if (effort == null) {
      double intensity;
      if (sport.isCycling) {
        final ftp = athlete.ftpW ?? athlete.weightKg * 2.8;
        intensity = ftp > 0 ? (np ?? 0) / ftp : 0;
      } else {
        final thr = sport.isRunning ? runThresholdMps : walkThresholdMps;
        intensity = (avgGap ?? avgSpeed) / thr;
      }
      effort = intensityLoad(movingS, intensity);
    }

    // Gravel.
    final surfDist = surfaceDistances(p);
    final gravelPct = gravelPercent(surfDist, distance);
    final sectors = detectGravelSectors(p);
    final grit = gritScore(
      gravelPct: gravelPct,
      unpavedRoughness: unpavedRoughness(p),
      gainM: gain,
      distanceM: distance,
      sectors: sectors,
    );

    return ActivityAnalysis(
      sport: sport,
      distanceM: distance,
      movingTimeS: movingS.round(),
      elapsedTimeS: p.t[n - 1].round(),
      elevationGainM: gain,
      elevationLossM: loss,
      maxEleM: maxEle,
      minEleM: minEle,
      avgSpeedMps: avgSpeed,
      maxSpeedMps: maxSpeed,
      avgGapMps: avgGap,
      avgHeartRate: hrN > 0 ? (hrSum / hrN).round() : null,
      maxHeartRate: hrN > 0 ? hrMax : null,
      avgCadence: cadN > 0 ? (cadSum / cadN).round() : null,
      avgPowerW: avgPower,
      energyKj: energyKj,
      normalizedPowerW: np,
      relativeEffort: effort,
      surfaceDistanceM: surfDist,
      gravelPct: gravelPct,
      gritScore: grit,
      gravelSectors: sectors,
      climbs: detectClimbs(p),
      splits: computeSplits(p, gapCum: gapCum),
      bestEfforts: computeBestEfforts(p, sport),
      hrZoneSeconds: hrZoneSeconds(p, athlete),
      series: buildSeries(p),
      minLat: minLat,
      minLon: minLon,
      maxLat: maxLat,
      maxLon: maxLon,
    );
  }

  /// CTL/ATL/TSB over consecutive days given (day, load) pairs.
  List<FitnessDay> fitnessTimeline(Map<DateTime, double> dailyLoad,
          {DateTime? until}) =>
      computeFitnessTimeline(dailyLoad, until: until);
}
