import 'dart:collection';

/// Road grade (%) over a trailing distance window (~50 m).
class GradeCalculator {
  final double windowM;
  final double minSpanM;
  final double maxAbsGradePct;

  final Queue<(double, double)> _points = Queue(); // (distance, elevation)
  double _grade = 0;

  GradeCalculator({
    this.windowM = 50,
    this.minSpanM = 20,
    this.maxAbsGradePct = 40,
  });

  double get gradePct => _grade;

  void reset() {
    _points.clear();
    _grade = 0;
  }

  double add(double cumulativeDistanceM, double elevationM) {
    if (_points.isNotEmpty && cumulativeDistanceM <= _points.last.$1) {
      return _grade; // not moving: keep last grade
    }
    _points.addLast((cumulativeDistanceM, elevationM));
    // Keep exactly one point at/before the window start.
    while (_points.length > 2 &&
        cumulativeDistanceM - _points.elementAt(1).$1 >= windowM) {
      _points.removeFirst();
    }
    final first = _points.first;
    final span = cumulativeDistanceM - first.$1;
    if (span >= minSpanM) {
      final g = (elevationM - first.$2) / span * 100;
      _grade = g.clamp(-maxAbsGradePct, maxAbsGradePct).toDouble();
    }
    return _grade;
  }
}
