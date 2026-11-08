import 'dart:math' as math;
import 'dart:typed_data';

import 'package:virya/core/analytics/geo.dart';

/// Result of projecting a point onto a [SegmentPath].
class PathProjection {
  final double progressM; // distance along the path
  final double deviationM; // perpendicular distance to the path
  final int legIndex; // polyline leg index
  const PathProjection(this.progressM, this.deviationM, this.legIndex);
}

/// A segment polyline in local meters with cumulative distance, used by the
/// offline matcher and the live tracker.
class SegmentPath {
  static const double markSpacingM = 50;

  final List<(double, double)> points;
  final LocalProjector _proj;
  final Float64List _x, _y, _cum;

  SegmentPath._(this.points, this._proj, this._x, this._y, this._cum);

  factory SegmentPath(List<(double lat, double lon)> polyline) {
    if (polyline.length < 2) {
      throw ArgumentError('Segment needs at least 2 points');
    }
    final proj = LocalProjector(polyline.first.$1, polyline.first.$2);
    final n = polyline.length;
    final x = Float64List(n), y = Float64List(n), cum = Float64List(n);
    for (var i = 0; i < n; i++) {
      x[i] = proj.x(polyline[i].$2);
      y[i] = proj.y(polyline[i].$1);
      if (i > 0) {
        final dx = x[i] - x[i - 1], dy = y[i] - y[i - 1];
        cum[i] = cum[i - 1] + math.sqrt(dx * dx + dy * dy);
      }
    }
    return SegmentPath._(List.unmodifiable(polyline), proj, x, y, cum);
  }

  double get lengthM => _cum[_cum.length - 1];
  int get legCount => points.length - 1;

  /// Number of ghost marks (index k = time at k × 50 m, mark 0 = start).
  int get markCount => ((lengthM + 0.5) / markSpacingM).floor() + 1;

  double distanceToStart(double lat, double lon) =>
      _dist(lat, lon, _x[0], _y[0]);
  double distanceToEnd(double lat, double lon) =>
      _dist(lat, lon, _x[_x.length - 1], _y[_y.length - 1]);

  double _dist(double lat, double lon, double px, double py) {
    final dx = _proj.x(lon) - px, dy = _proj.y(lat) - py;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Project onto legs [fromLeg, fromLeg + window) — keeps matching
  /// forward-only so loops/out-and-backs don't jump ahead.
  PathProjection project(double lat, double lon,
      {int fromLeg = 0, double lookAheadM = 250}) {
    final px = _proj.x(lon), py = _proj.y(lat);
    final start = fromLeg.clamp(0, legCount - 1);
    var best = double.infinity;
    var bestProg = 0.0;
    var bestLeg = start;
    for (var k = start; k < legCount; k++) {
      if (k > start && _cum[k] - _cum[start] > lookAheadM) break;
      final ax = _x[k], ay = _y[k];
      final bx = _x[k + 1] - ax, by = _y[k + 1] - ay;
      final len2 = bx * bx + by * by;
      var f = len2 > 0 ? ((px - ax) * bx + (py - ay) * by) / len2 : 0.0;
      f = f < 0 ? 0 : (f > 1 ? 1 : f);
      final qx = ax + f * bx - px, qy = ay + f * by - py;
      final d = math.sqrt(qx * qx + qy * qy);
      if (d < best) {
        best = d;
        bestLeg = k;
        bestProg = _cum[k] + f * (_cum[k + 1] - _cum[k]);
      }
    }
    return PathProjection(bestProg, best, bestLeg);
  }
}

/// Records the time (s since segment start) at which progress first passes
/// each 50 m mark, interpolating between fixes.
class MarkRecorder {
  final SegmentPath path;
  final List<int> marks = [0];
  double _lastProg = 0, _lastT = 0;

  MarkRecorder(this.path);

  void add(double progressM, double tS) {
    if (progressM <= _lastProg) {
      _lastT = tS;
      return;
    }
    while (marks.length < path.markCount) {
      final target = marks.length * SegmentPath.markSpacingM;
      if (progressM < target) break;
      final f = (target - _lastProg) / (progressM - _lastProg);
      marks.add((_lastT + (tS - _lastT) * f).round());
    }
    _lastProg = progressM;
    _lastT = tS;
  }

  /// Fill any marks not reached (e.g. finishing within the end radius).
  List<int> finish(double totalS) {
    while (marks.length < path.markCount) {
      marks.add(totalS.round());
    }
    return List.unmodifiable(marks);
  }
}

/// Seconds at [progressM] interpolated from a 50 m mark list.
double timeAtProgress(List<int> marks, double progressM) {
  if (marks.isEmpty) return 0;
  final x = progressM / SegmentPath.markSpacingM;
  if (x <= 0) return marks.first.toDouble();
  final i = x.floor();
  if (i >= marks.length - 1) return marks.last.toDouble();
  return marks[i] + (marks[i + 1] - marks[i]) * (x - i);
}
