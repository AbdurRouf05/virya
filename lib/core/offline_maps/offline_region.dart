import 'package:virya/core/offline_maps/tile_math.dart';

/// Area downloaded for offline use (metadata only; tiles live in the
/// shared region tile store).
class OfflineRegion {
  final String id;
  final String name;
  final GeoBounds bounds;
  final int minZoom;
  final int maxZoom;
  final int tileCount;
  final int sizeBytes;
  final DateTime createdAt;

  /// False while downloading or after a cancelled/failed run.
  final bool complete;

  const OfflineRegion({
    required this.id,
    required this.name,
    required this.bounds,
    required this.minZoom,
    required this.maxZoom,
    required this.tileCount,
    required this.sizeBytes,
    required this.createdAt,
    this.complete = false,
  });

  List<TileRange> get ranges => tileRanges(bounds, minZoom, maxZoom);

  OfflineRegion copyWith({int? sizeBytes, bool? complete}) => OfflineRegion(
    id: id,
    name: name,
    bounds: bounds,
    minZoom: minZoom,
    maxZoom: maxZoom,
    tileCount: tileCount,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    createdAt: createdAt,
    complete: complete ?? this.complete,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'bounds': bounds.toJson(),
    'minZoom': minZoom,
    'maxZoom': maxZoom,
    'tileCount': tileCount,
    'sizeBytes': sizeBytes,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'complete': complete,
  };

  static OfflineRegion fromJson(Map<String, Object?> j) => OfflineRegion(
    id: j['id'] as String,
    name: j['name'] as String,
    bounds: GeoBounds.fromJson((j['bounds'] as Map).cast<String, Object?>()),
    minZoom: j['minZoom'] as int,
    maxZoom: j['maxZoom'] as int,
    tileCount: j['tileCount'] as int,
    sizeBytes: j['sizeBytes'] as int,
    createdAt: DateTime.parse(j['createdAt'] as String),
    complete: j['complete'] as bool? ?? false,
  );
}

/// Tiles of [removed] that no region in [remaining] still covers.
Iterable<(int, int, int)> orphanTiles(
  OfflineRegion removed,
  List<OfflineRegion> remaining,
) sync* {
  final others = [for (final r in remaining) ...r.ranges];
  for (final t in tilesIn(removed.ranges)) {
    final (z, x, y) = t;
    if (!others.any((r) => r.z == z && r.contains(x, y))) yield t;
  }
}
