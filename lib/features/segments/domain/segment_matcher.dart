import 'package:stravo/core/analytics/geo.dart';
import 'package:stravo/core/models/track_sample.dart';
import 'package:stravo/features/segments/domain/segment_path.dart';

/// One effort of a segment found inside an activity.
class SegmentEffortMatch {
  final int startIndex;
  final int endIndex;
  final DateTime startedAt;
  final int elapsedS;

  /// Seconds since segment start at every 50 m (index 0 = 0 s); stored as
  /// `SegmentEfforts.progressJson` for ghost replay.
  final List<int> progressS;

  const SegmentEffortMatch({
    required this.startIndex,
    required this.endIndex,
    required this.startedAt,
    required this.elapsedS,
    required this.progressS,
  });
}

/// Finds efforts of a segment polyline in recorded samples:
/// - start: closest sample within [endpointRadiusM] of the segment start;
/// - path: each fix projects (forward-only) within [corridorM] of the
///   polyline; up to [maxOffFixes] consecutive outliers are tolerated;
/// - end: progress ≥ 90% and within [endpointRadiusM] of the end, taking the
///   closest fix; distance ridden must stay ≤ 1.5 × length + 100 m.
class SegmentMatcher {
  final double endpointRadiusM;
  final double corridorM;
  final int maxOffFixes;

  const SegmentMatcher({
    this.endpointRadiusM = 25,
    this.corridorM = 30,
    this.maxOffFixes = 5,
  });

  List<SegmentEffortMatch> findEfforts(
      List<(double lat, double lon)> polyline, List<TrackSample> samples) {
    if (polyline.length < 2 || samples.length < 2) return const [];
    final path = SegmentPath(polyline);
    final out = <SegmentEffortMatch>[];
    final n = samples.length;
    var i = 0;
    while (i < n) {
      final s = samples[i];
      if (path.distanceToStart(s.lat, s.lon) > endpointRadiusM) {
        i++;
        continue;
      }
      var j = i, best = i;
      var bestD = double.infinity;
      while (j < n) {
        final d = path.distanceToStart(samples[j].lat, samples[j].lon);
        if (d > endpointRadiusM) break;
        if (d < bestD) {
          bestD = d;
          best = j;
        }
        j++;
      }
      final m = _follow(path, samples, best);
      if (m != null) {
        out.add(m);
        i = m.endIndex + 1;
      } else {
        i = j > i ? j : i + 1;
      }
    }
    return out;
  }

  SegmentEffortMatch? _follow(
      SegmentPath path, List<TrackSample> s, int start) {
    final len = path.lengthM;
    final t0 = s[start].time;
    final rec = MarkRecorder(path);
    var leg = 0, off = 0;
    var prog = 0.0, traveled = 0.0;
    var endBest = -1;
    var endBestD = double.infinity;
    for (var k = start + 1; k < s.length; k++) {
      final p = s[k];
      traveled += haversineM(s[k - 1].lat, s[k - 1].lon, p.lat, p.lon);
      if (traveled > 1.5 * len + 100) break;
      final pr = path.project(p.lat, p.lon, fromLeg: leg);
      final tS = p.time.difference(t0).inMilliseconds / 1000;
      if (pr.deviationM > corridorM) {
        if (++off > maxOffFixes) return null;
      } else {
        off = 0;
        leg = pr.legIndex;
        if (pr.progressM > prog) {
          prog = pr.progressM;
          rec.add(prog, tS);
        }
      }
      final dEnd = path.distanceToEnd(p.lat, p.lon);
      if (prog >= 0.9 * len && dEnd <= endpointRadiusM) {
        if (dEnd < endBestD) {
          endBestD = dEnd;
          endBest = k;
        } else {
          break; // moving away from the finish
        }
        if (prog >= len - 0.5) break; // at/past the end
      } else if (endBest >= 0) {
        break;
      }
    }
    if (endBest < 0) return null;
    final elapsed = s[endBest].time.difference(t0).inMilliseconds / 1000;
    final marks = [
      for (final m in rec.finish(elapsed)) m > elapsed ? elapsed.round() : m
    ];
    return SegmentEffortMatch(
      startIndex: start,
      endIndex: endBest,
      startedAt: t0,
      elapsedS: elapsed.round(),
      progressS: List.unmodifiable(marks),
    );
  }
}
