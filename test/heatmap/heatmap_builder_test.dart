import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/heatmap/domain/heatmap_builder.dart';

/// Garis lurus ke timur, sekitar 11 m per titik.
HeatmapTrack line(
  SportCategory c, {
  double lat = -6.9,
  double lon = 107.6,
  int n = 100,
}) {
  final out = Float64List(n * 2);
  for (var i = 0; i < n; i++) {
    out[i * 2] = lat;
    out[i * 2 + 1] = lon + i * 0.0001;
  }
  return HeatmapTrack(c, out);
}

void main() {
  test('tanpa jalur hasilnya kosong', () {
    final r = buildHeatmap(const HeatmapJob([], HeatmapFilter.all));
    expect(r.isEmpty, isTrue);
    expect(r.trackCount, 0);
    expect(r.maxCount, 0);
  });

  test('filter hanya memakai kategorinya', () {
    final tracks = [
      line(SportCategory.cycling),
      line(SportCategory.running, lat: -6.8),
      line(SportCategory.walking, lat: -6.7),
    ];
    int count(HeatmapFilter f) =>
        buildHeatmap(HeatmapJob(tracks, f)).trackCount;
    expect(count(HeatmapFilter.all), 3);
    expect(count(HeatmapFilter.cycling), 1);
    expect(count(HeatmapFilter.running), 1);
    expect(count(HeatmapFilter.walking), 1);

    final run = buildHeatmap(HeatmapJob(tracks, HeatmapFilter.running));
    expect(run.points.every((p) => (p.$1 + 6.8).abs() < 0.01), isTrue);
  });

  test('jalur yang sama dihitung per aktivitas dan bobotnya naik', () {
    final tracks = [
      line(SportCategory.cycling),
      line(SportCategory.cycling),
      line(SportCategory.cycling),
      line(SportCategory.cycling, lat: -6.5),
    ];
    final r = buildHeatmap(HeatmapJob(tracks, HeatmapFilter.all));
    expect(r.trackCount, 4);
    expect(r.maxCount, 3);
    final often = r.points.where((p) => (p.$1 + 6.9).abs() < 0.01);
    final once = r.points.where((p) => (p.$1 + 6.5).abs() < 0.01);
    expect(often.first.$3, 1.0);
    expect(once.first.$3, lessThan(1.0));
    expect(r.points.every((p) => p.$3 >= 0.15 && p.$3 <= 1.0), isTrue);
  });

  test('lubang GPS panjang tidak disambung garis lurus', () {
    final gap = Float64List.fromList([-6.9, 107.6, -6.9, 107.7]);
    final r = buildHeatmap(
      HeatmapJob([HeatmapTrack(SportCategory.running, gap)], HeatmapFilter.all),
    );
    expect(r.points.length, 2);
  });

  test('jumlah titik dibatasi tanpa menurunkan rekor lintasan', () {
    final tracks = [
      line(SportCategory.cycling, n: 3000),
      line(SportCategory.cycling, n: 3000),
    ];
    final full = buildHeatmap(HeatmapJob(tracks, HeatmapFilter.all));
    final capped = buildHeatmap(
      HeatmapJob(tracks, HeatmapFilter.all, maxPoints: 100),
    );
    expect(full.points.length, greaterThan(100));
    expect(capped.points.length, lessThanOrEqualTo(100));
    expect(capped.maxCount, 2);
    expect(capped.points.map((p) => p.$3).reduce((a, b) => a > b ? a : b), 1.0);
    expect(capped.points.every((p) => (p.$1 + 6.9).abs() < 0.2), isTrue);
    expect(
      capped.points.every((p) => p.$2 > 107.5 && p.$2 < 108.1),
      isTrue,
    );
  });
}
