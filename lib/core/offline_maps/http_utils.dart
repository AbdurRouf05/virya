/// Pure helpers for [LocalTileServer]: Range parsing, path sanitising,
/// content types. No I/O so they are unit-testable.
library;

/// Result of parsing an HTTP `Range` header against a resource of [size].
sealed class RangeResult {
  const RangeResult();
}

/// No (usable) Range header → send the whole body with 200.
class FullRange extends RangeResult {
  const FullRange();
}

/// Inclusive byte range → 206.
class PartialRange extends RangeResult {
  final int start;
  final int end; // inclusive
  const PartialRange(this.start, this.end);
  int get length => end - start + 1;

  @override
  bool operator ==(Object other) =>
      other is PartialRange && other.start == start && other.end == end;
  @override
  int get hashCode => Object.hash(start, end);
  @override
  String toString() => 'PartialRange($start-$end)';
}

/// Range cannot be satisfied → 416.
class UnsatisfiableRange extends RangeResult {
  const UnsatisfiableRange();
}

/// Parses `bytes=a-b`, `bytes=a-`, `bytes=-n`. Multi-range requests are
/// answered with the first range only. Malformed headers are ignored (200),
/// per RFC 9110.
RangeResult parseRange(String? header, int size) {
  if (header == null) return const FullRange();
  final h = header.trim();
  if (!h.toLowerCase().startsWith('bytes=')) return const FullRange();
  final spec = h.substring(6).split(',').first.trim();
  final dash = spec.indexOf('-');
  if (dash < 0) return const FullRange();
  final a = spec.substring(0, dash).trim();
  final b = spec.substring(dash + 1).trim();
  if (a.isEmpty) {
    // Suffix range: last n bytes.
    final n = int.tryParse(b);
    if (n == null || n < 0) return const FullRange();
    if (n == 0 || size == 0) return const UnsatisfiableRange();
    final start = n >= size ? 0 : size - n;
    return PartialRange(start, size - 1);
  }
  final start = int.tryParse(a);
  if (start == null || start < 0) return const FullRange();
  int end;
  if (b.isEmpty) {
    end = size - 1;
  } else {
    final e = int.tryParse(b);
    if (e == null || e < start) return const FullRange();
    end = e;
  }
  if (start >= size) return const UnsatisfiableRange();
  if (end >= size) end = size - 1;
  return PartialRange(start, end);
}

/// Turns a URL path remainder (e.g. `jawa.pmtiles`, `sub/a.js`) into a safe
/// relative POSIX path, or null when it tries to escape the root.
String? sanitizeRelativePath(String raw) {
  String decoded;
  try {
    decoded = Uri.decodeComponent(raw);
  } catch (_) {
    return null;
  }
  if (decoded.isEmpty) return null;
  if (decoded.contains('\u0000') || decoded.contains('\\')) return null;
  if (decoded.startsWith('/') || decoded.contains(':')) return null;
  final parts = <String>[];
  for (final seg in decoded.split('/')) {
    if (seg.isEmpty || seg == '.') continue;
    if (seg == '..') return null;
    if (seg.startsWith('.')) return null; // no hidden files
    parts.add(seg);
  }
  if (parts.isEmpty) return null;
  return parts.join('/');
}

String contentTypeFor(String path) {
  final dot = path.lastIndexOf('.');
  final ext = dot < 0 ? '' : path.substring(dot + 1).toLowerCase();
  switch (ext) {
    case 'html':
    case 'htm':
      return 'text/html; charset=utf-8';
    case 'js':
    case 'mjs':
      return 'application/javascript; charset=utf-8';
    case 'css':
      return 'text/css; charset=utf-8';
    case 'json':
      return 'application/json; charset=utf-8';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'svg':
      return 'image/svg+xml';
    case 'webp':
      return 'image/webp';
    case 'pmtiles':
    default:
      return 'application/octet-stream';
  }
}
