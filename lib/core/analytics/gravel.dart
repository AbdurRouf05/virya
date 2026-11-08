import 'package:stravo/core/analytics/analysis_models.dart';
import 'package:stravo/core/analytics/geo.dart';
import 'package:stravo/core/analytics/prepared_track.dart';
import 'package:stravo/core/constants/enums.dart';

bool isUnpaved(SurfaceType s) =>
    s != SurfaceType.asphalt && s != SurfaceType.unknown;

/// Distance per surface (interval surface = surface of its end sample).
Map<SurfaceType, double> surfaceDistances(PreparedTrack p) {
  final out = <SurfaceType, double>{};
  for (var i = 1; i < p.n; i++) {
    if (p.dd[i] <= 0) continue;
    final s = p.s[i].surface;
    out[s] = (out[s] ?? 0) + p.dd[i];
  }
  return out;
}

double gravelPercent(Map<SurfaceType, double> dist, double total) {
  if (total <= 0) return 0;
  var g = 0.0;
  dist.forEach((k, v) {
    if (isUnpaved(k)) g += v;
  });
  return clampD(g / total * 100, 0, 100);
}

class _Run {
  SurfaceType surface;
  double start, end;
  _Run(this.surface, this.start, this.end);
  double get len => end - start;
}

/// Gravel sectors:
/// 1. runs of equal surface along distance;
/// 2. unpaved blocks = unpaved runs joined across paved/unknown gaps < [maxGap];
/// 3. inside a block, surface runs shorter than [minLen] fold into the
///    neighbouring run, so each sector has one dominant surface;
/// 4. sectors ≥ [minLen] are kept and numbered down to the finish (1 = last).
List<GravelSector> detectGravelSectors(PreparedTrack p,
    {double minLen = 300, double maxGap = 80}) {
  final runs = <_Run>[];
  for (var i = 1; i < p.n; i++) {
    if (p.dd[i] <= 0) continue;
    final s = p.s[i].surface;
    if (runs.isNotEmpty && runs.last.surface == s) {
      runs.last.end = p.cum[i];
    } else {
      runs.add(_Run(s, p.cum[i - 1], p.cum[i]));
    }
  }
  // Unpaved blocks.
  final blocks = <List<_Run>>[];
  List<_Run>? cur;
  for (var r = 0; r < runs.length; r++) {
    final run = runs[r];
    if (isUnpaved(run.surface)) {
      cur ??= <_Run>[];
      cur.add(_Run(run.surface, run.start, run.end));
    } else if (cur != null) {
      final bridge = run.len < maxGap &&
          r + 1 < runs.length &&
          isUnpaved(runs[r + 1].surface);
      if (bridge) {
        cur.last.end = run.end; // absorb gap into previous unpaved run
      } else {
        blocks.add(cur);
        cur = null;
      }
    }
  }
  if (cur != null) blocks.add(cur);

  final ranges = <({double start, double end})>[];
  for (final block in blocks) {
    // Merge same-surface neighbours, then fold short runs.
    final merged = <_Run>[];
    for (final r in block) {
      if (merged.isNotEmpty && merged.last.surface == r.surface) {
        merged.last.end = r.end;
      } else {
        merged.add(_Run(r.surface, r.start, r.end));
      }
    }
    final parts = <_Run>[];
    for (final r in merged) {
      if (parts.isNotEmpty && (r.len < minLen || parts.last.len < minLen)) {
        // Keep the longer run's surface label.
        final keep = parts.last.len >= r.len ? parts.last.surface : r.surface;
        parts.last
          ..end = r.end
          ..surface = keep;
      } else {
        parts.add(_Run(r.surface, r.start, r.end));
      }
    }
    for (final part in parts) {
      if (part.len >= minLen) {
        ranges.add((start: part.start, end: part.end));
      }
    }
  }

  final out = <GravelSector>[];
  final total = ranges.length;
  for (var k = 0; k < ranges.length; k++) {
    final r = ranges[k];
    final byS = <SurfaceType, double>{};
    var vibSum = 0.0, vibW = 0.0;
    for (var i = 1; i < p.n; i++) {
      if (p.cum[i] <= r.start) continue;
      if (p.cum[i - 1] >= r.end) break;
      final s = p.s[i];
      if (!isUnpaved(s.surface) || p.dd[i] <= 0) continue;
      byS[s.surface] = (byS[s.surface] ?? 0) + p.dd[i];
      if (!s.paused) {
        vibSum += s.vibration * p.dd[i];
        vibW += p.dd[i];
      }
    }
    var dom = SurfaceType.smoothGravel;
    var best = -1.0;
    byS.forEach((s, d) {
      if (d > best) {
        best = d;
        dom = s;
      }
    });
    final len = r.end - r.start;
    final grade = p.hasEle
        ? (interpOn(p.cum, p.ele, r.end) - interpOn(p.cum, p.ele, r.start)) /
            len *
            100
        : 0.0;
    final rough = vibW > 0 ? vibSum / vibW : 0.0;
    final number = total - k;
    out.add(GravelSector(
      number: number,
      name: sectorName(number, dom, grade),
      startDistanceM: r.start,
      endDistanceM: r.end,
      dominantSurface: dom,
      stars: sectorStars(len, rough, grade),
      avgGradePct: grade,
      roughness: rough,
    ));
  }
  return out;
}

/// Stars 1..5 from points: length (1/km, ≤3), roughness ((rms−1.5)/1.2, ≤3),
/// grade (uphill %/2.5, downhill %/4, ≤2). stars = 1 + round(points/2).
int sectorStars(double lengthM, double roughness, double gradePct) {
  final lp = clampD(lengthM / 1000, 0, 3);
  final rp = clampD((roughness - 1.5) / 1.2, 0, 3);
  final gp = clampD(gradePct >= 0 ? gradePct / 2.5 : -gradePct / 4, 0, 2);
  return (1 + ((lp + rp + gp) / 2).round()).clamp(1, 5);
}

String sectorName(int number, SurfaceType dom, double gradePct) {
  final surface = switch (dom) {
    SurfaceType.roughGravel => 'Makadam',
    SurfaceType.dirt => 'Tanah',
    SurfaceType.cobblestone => 'Batu',
    _ => 'Gravel',
  };
  final slope = gradePct >= 3
      ? 'Menanjak'
      : (gradePct <= -3 ? 'Turunan' : 'Datar');
  return 'Sektor $number · $surface $slope';
}

/// Grit Score 0..100 =
///   35 × gravel share
/// + 25 × roughness   (distance-weighted unpaved vibration: (rms−1)/4, 0..1)
/// + 25 × climbing    (gain per km / 25 m, 0..1, scaled by gravel share)
/// + 15 × sectors     (sum of sector stars / 15, 0..1)
double gritScore({
  required double gravelPct,
  required double unpavedRoughness,
  required double gainM,
  required double distanceM,
  required List<GravelSector> sectors,
}) {
  if (distanceM <= 0) return 0;
  final g = clampD(gravelPct / 100, 0, 1);
  final r = clampD((unpavedRoughness - 1) / 4, 0, 1);
  final c = clampD(gainM / (distanceM / 1000) / 25, 0, 1);
  final stars = sectors.fold<int>(0, (a, s) => a + s.stars);
  final st = clampD(stars / 15, 0, 1);
  return clampD(35 * g + 25 * r + 25 * c * g + 15 * st, 0, 100);
}

/// Distance-weighted mean vibration over unpaved, non-paused intervals.
double unpavedRoughness(PreparedTrack p) {
  var sum = 0.0, w = 0.0;
  for (var i = 1; i < p.n; i++) {
    final s = p.s[i];
    if (!isUnpaved(s.surface) || s.paused || p.dd[i] <= 0) continue;
    sum += s.vibration * p.dd[i];
    w += p.dd[i];
  }
  return w > 0 ? sum / w : 0;
}
