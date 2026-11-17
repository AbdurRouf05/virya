import 'dart:math' as math;

import 'package:virya/core/analytics/geo.dart';
import 'package:virya/core/models/track_sample.dart';

const double minSegmentLengthM = 100;
const double _metersPerDegree = 111320;

/// Pesan kesalahan draf segmen, atau `null` bila boleh disimpan.
String? segmentDraftError(String name, double lengthM) {
  if (name.trim().isEmpty) return 'Beri nama segmennya.';
  if (lengthM < minSegmentLengthM) {
    return 'Segmen minimal ${minSegmentLengthM.round()} meter.';
  }
  return null;
}

/// Kotak pembatas segmen, untuk menyaring segmen yang jauh dari posisi.
class SegmentBounds {
  final double minLat, maxLat, minLon, maxLon;

  const SegmentBounds(this.minLat, this.maxLat, this.minLon, this.maxLon);

  factory SegmentBounds.of(Iterable<(double lat, double lon)> points) {
    var a = double.infinity, b = -double.infinity;
    var c = double.infinity, d = -double.infinity;
    for (final (lat, lon) in points) {
      a = math.min(a, lat);
      b = math.max(b, lat);
      c = math.min(c, lon);
      d = math.max(d, lon);
    }
    return SegmentBounds(a, b, c, d);
  }

  static double latMargin(double marginM) => marginM / _metersPerDegree;

  double _lonMargin(double marginM) {
    final mid = (minLat + maxLat) / 2;
    final c = math.cos(mid * math.pi / 180).abs();
    return marginM / (_metersPerDegree * math.max(c, 0.01));
  }

  bool contains(double lat, double lon, double marginM) {
    final dLat = latMargin(marginM), dLon = _lonMargin(marginM);
    return lat >= minLat - dLat &&
        lat <= maxLat + dLat &&
        lon >= minLon - dLon &&
        lon <= maxLon + dLon;
  }

  bool overlaps(SegmentBounds o, double marginM) {
    final dLat = latMargin(marginM), dLon = _lonMargin(marginM);
    return o.maxLat >= minLat - dLat &&
        o.minLat <= maxLat + dLat &&
        o.maxLon >= minLon - dLon &&
        o.minLon <= maxLon + dLon;
  }
}

/// Rute aktivitas dengan jarak kumulatif, untuk memotong segmen dari rute.
class RouteMeasure {
  final List<(double lat, double lon)> points;
  final List<double> cumM;

  RouteMeasure._(this.points, this.cumM);

  factory RouteMeasure.fromSamples(List<TrackSample> samples) {
    final pts = <(double, double)>[];
    final cum = <double>[];
    for (final s in samples) {
      if (s.lat.isNaN || s.lon.isNaN) continue;
      if (pts.isEmpty) {
        cum.add(0);
      } else {
        final (lat, lon) = pts.last;
        cum.add(cum.last + haversineM(lat, lon, s.lat, s.lon));
      }
      pts.add((s.lat, s.lon));
    }
    return RouteMeasure._(pts, cum);
  }

  double get lengthM => cumM.isEmpty ? 0 : cumM.last;

  /// Indeks titik pertama yang jaraknya minimal [m].
  int indexAt(double m) {
    var lo = 0, hi = cumM.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (cumM[mid] < m) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  /// Potongan rute `[fromM, toM]`, ditipiskan sekitar tiap [stepM] meter.
  List<(double lat, double lon)> slice(
    double fromM,
    double toM, {
    double stepM = 15,
  }) {
    if (points.length < 2 || toM <= fromM) return const [];
    final first = indexAt(fromM), last = indexAt(toM);
    final out = [points[first]];
    var keptAt = cumM[first];
    for (var i = first + 1; i < last; i++) {
      if (cumM[i] - keptAt >= stepM) {
        out.add(points[i]);
        keptAt = cumM[i];
      }
    }
    if (last > first) out.add(points[last]);
    return out;
  }
}
