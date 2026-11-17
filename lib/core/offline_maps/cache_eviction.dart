/// Pure eviction planning for the on-disk tile cache. No I/O.
library;

class CacheEntry {
  final String path;
  final int sizeBytes;

  /// Last read or write (file mtime; hits refresh it → LRU).
  final DateTime lastUsed;
  const CacheEntry(this.path, this.sizeBytes, this.lastUsed);
}

/// Least-recently-used entries to delete so the total drops to
/// [targetBytes] or below. Empty when the total is already within it.
List<CacheEntry> pickEvictions(List<CacheEntry> entries, int targetBytes) {
  var total = entries.fold<int>(0, (s, e) => s + e.sizeBytes);
  if (total <= targetBytes) return const [];
  final sorted = [...entries]..sort((a, b) => a.lastUsed.compareTo(b.lastUsed));
  final out = <CacheEntry>[];
  for (final e in sorted) {
    if (total <= targetBytes) break;
    out.add(e);
    total -= e.sizeBytes;
  }
  return out;
}
