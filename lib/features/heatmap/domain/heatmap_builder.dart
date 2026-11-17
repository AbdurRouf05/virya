import 'dart:math' as math;
import 'dart:typed_data';

import 'package:virya/core/analytics/heatmap_grid.dart';
import 'package:virya/core/constants/sport_category.dart';

/// Filter layar heatmap. Gym tidak punya jalur GPS, jadi tidak ada di sini.
enum HeatmapFilter {
  all('SEMUA', null),
  cycling('SEPEDA', SportCategory.cycling),
  running('LARI', SportCategory.running),
  walking('JALAN', SportCategory.walking);

  final String label;
  final SportCategory? category;
  const HeatmapFilter(this.label, this.category);

  bool includes(SportCategory c) => category == null || category == c;
}

typedef HeatPoint = (double lat, double lon, double weight);

/// Satu jalur aktivitas. [latLon] berisi lat, lon, lat, lon, ...
class HeatmapTrack {
  final SportCategory category;
  final Float64List latLon;
  const HeatmapTrack(this.category, this.latLon);

  Iterable<(double, double)> get points sync* {
    for (var i = 0; i + 1 < latLon.length; i += 2) {
      yield (latLon[i], latLon[i + 1]);
    }
  }
}

/// Masukan [buildHeatmap]. Dikirim utuh ke isolate.
class HeatmapJob {
  final List<HeatmapTrack> tracks;
  final HeatmapFilter filter;
  final int zoom;
  final int maxPoints;

  const HeatmapJob(
    this.tracks,
    this.filter, {
    this.zoom = 14,
    this.maxPoints = 40000,
  }) : assert(maxPoints > 0);
}

class HeatmapResult {
  final List<HeatPoint> points;
  final int trackCount;

  /// Jumlah aktivitas terbanyak yang melewati satu titik.
  final int maxCount;

  const HeatmapResult({
    required this.points,
    required this.trackCount,
    required this.maxCount,
  });

  bool get isEmpty => points.isEmpty;
}

/// Lubang GPS lebih panjang dari ini (sekitar 600 m di zoom 14) tidak
/// disambung, supaya tidak muncul garis lurus yang tidak pernah dilalui.
const _maxJumpPx = 64.0;

/// Bobot terendah, supaya jalur yang baru sekali dilalui tetap terlihat.
const _minWeight = 0.15;

/// Fungsi murni dan level atas, supaya bisa dijalankan lewat `compute`.
HeatmapResult buildHeatmap(HeatmapJob job) {
  final grid = HeatmapGrid(zoom: job.zoom);
  for (final track in job.tracks) {
    if (job.filter.includes(track.category)) {
      grid.addTrack(track.points, maxJumpPx: _maxJumpPx);
    }
  }
  return HeatmapResult(
    points: _pointsOf(grid, job.maxPoints),
    trackCount: grid.trackCount,
    maxCount: grid.maxCount,
  );
}

List<HeatPoint> _pointsOf(HeatmapGrid grid, int maxPoints) {
  if (grid.cellCount == 0) return const [];
  var shift = 0;
  var cells = _merged(grid, shift);
  while (cells.length > maxPoints) {
    cells = _merged(grid, ++shift);
  }
  final side = 1 << shift;
  final scale = math.log(1 + grid.maxCount);
  return [
    for (final MapEntry(:key, :value) in cells.entries)
      _point(grid, key ~/ _keyBase, key % _keyBase, side, value, scale),
  ];
}

const _keyBase = 1 << 29;

/// Sel digabung per 2^[shift] piksel. Nilainya maksimum, bukan jumlah, karena
/// artinya "berapa aktivitas lewat sini".
Map<int, int> _merged(HeatmapGrid grid, int shift) {
  final out = <int, int>{};
  for (final c in grid.cells) {
    final key = (c.x >> shift) * _keyBase + (c.y >> shift);
    final seen = out[key];
    if (seen == null || c.count > seen) out[key] = c.count;
  }
  return out;
}

HeatPoint _point(
  HeatmapGrid grid,
  int x,
  int y,
  int side,
  int count,
  double scale,
) {
  final (lat, lon) = grid.pixelToLatLon((x + 0.5) * side, (y + 0.5) * side);
  final weight = math.max(_minWeight, math.log(1 + count) / scale);
  return (_round(lat, 1e5), _round(lon, 1e5), _round(weight, 1e2));
}

/// Angka pendek memperkecil JSON yang dikirim ke WebView.
double _round(double v, double factor) => (v * factor).round() / factor;
