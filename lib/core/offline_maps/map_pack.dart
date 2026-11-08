import 'dart:typed_data';

enum MapPackType { basemap, dem, unknown }

/// PMTiles v3 tile_type values.
enum PmTileType { unknown, mvt, png, jpeg, webp, avif }

/// The fixed 127-byte PMTiles v3 header (only fields we use).
class PmtilesHeader {
  final int version;
  final PmTileType tileType;
  final int minZoom;
  final int maxZoom;
  final double minLon, minLat, maxLon, maxLat;

  const PmtilesHeader({
    required this.version,
    required this.tileType,
    required this.minZoom,
    required this.maxZoom,
    required this.minLon,
    required this.minLat,
    required this.maxLon,
    required this.maxLat,
  });

  static const length = 127;

  /// Returns null when [bytes] is not a PMTiles v3 header.
  static PmtilesHeader? parse(Uint8List bytes) {
    if (bytes.length < length) return null;
    const magic = 'PMTiles';
    for (var i = 0; i < magic.length; i++) {
      if (bytes[i] != magic.codeUnitAt(i)) return null;
    }
    final bd = ByteData.sublistView(bytes);
    final version = bytes[7];
    if (version != 3) return null;
    final tt = bytes[99];
    double e7(int off) => bd.getInt32(off, Endian.little) / 1e7;
    return PmtilesHeader(
      version: version,
      tileType:
          tt < PmTileType.values.length ? PmTileType.values[tt] : PmTileType.unknown,
      minZoom: bytes[100],
      maxZoom: bytes[101],
      minLon: e7(102),
      minLat: e7(106),
      maxLon: e7(110),
      maxLat: e7(114),
    );
  }
}

/// Basemap vs DEM: `*.dem.pmtiles` (or "terrain"/"dem" in the name) wins,
/// else vector tiles → basemap, raster PNG/WebP → DEM (Terrarium).
MapPackType detectPackType(String fileName, PmtilesHeader? header) {
  final n = fileName.toLowerCase();
  if (!n.endsWith('.pmtiles')) return MapPackType.unknown;
  if (n.endsWith('.dem.pmtiles') ||
      RegExp(r'(^|[._-])(dem|terrain|terrarium)([._-]|$)').hasMatch(n)) {
    return MapPackType.dem;
  }
  if (header == null) return MapPackType.unknown;
  switch (header.tileType) {
    case PmTileType.mvt:
      return MapPackType.basemap;
    case PmTileType.png:
    case PmTileType.webp:
      return MapPackType.dem;
    default:
      return MapPackType.unknown;
  }
}

class MapPack {
  final String fileName;
  final String path;
  final int sizeBytes;
  final MapPackType type;
  final PmtilesHeader? header;

  const MapPack({
    required this.fileName,
    required this.path,
    required this.sizeBytes,
    required this.type,
    this.header,
  });
}

String formatBytes(int b) {
  if (b < 1024) return '$b B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var v = b / 1024;
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  return '${v.toStringAsFixed(v >= 100 ? 0 : 1)} ${units[i]}';
}
