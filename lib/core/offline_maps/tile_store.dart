import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:virya/core/offline_maps/cache_eviction.dart';

/// Vector tiles on disk as `<dir>/<z>/<x>/<y>.pbf`.
///
/// With [maxBytes] set it acts as an LRU cache: hits refresh the file mtime
/// and writes evict the least recently used tiles down to 90% of the cap.
class TileStore {
  TileStore(this._dir, {this.maxBytes});

  final Future<Directory> Function() _dir;
  final int? maxBytes;
  int? _total; // lazily scanned
  bool _evicting = false;

  Future<File> _file(int z, int x, int y) async =>
      File(p.join((await _dir()).path, '$z', '$x', '$y.pbf'));

  /// Size of a stored tile, or null when absent.
  Future<int?> length(int z, int x, int y) async {
    try {
      return await (await _file(z, x, y)).length();
    } on FileSystemException {
      return null;
    }
  }

  Future<Uint8List?> read(int z, int x, int y) async {
    final f = await _file(z, x, y);
    try {
      final bytes = await f.readAsBytes();
      if (maxBytes != null) {
        unawaited(f.setLastModified(DateTime.now()).catchError((_) {}));
      }
      return bytes;
    } on FileSystemException {
      return null;
    }
  }

  Future<void> write(int z, int x, int y, List<int> bytes) async {
    final f = await _file(z, x, y);
    var old = 0;
    if (await f.exists()) old = await f.length();
    await f.parent.create(recursive: true);
    final tmp = File('${f.path}.part');
    await tmp.writeAsBytes(bytes, flush: false);
    await tmp.rename(f.path);
    if (_total != null) _total = _total! + bytes.length - old;
    final cap = maxBytes;
    if (cap != null && await sizeBytes() > cap) unawaited(_evict(cap));
  }

  Future<void> delete(int z, int x, int y) async {
    final f = await _file(z, x, y);
    try {
      final len = await f.length();
      await f.delete();
      if (_total != null) _total = _total! - len;
    } on FileSystemException {
      // already gone
    }
  }

  Future<int> sizeBytes() async =>
      _total ??= (await _entries()).fold<int>(0, (s, e) => s + e.sizeBytes);

  Future<void> clear() async {
    final dir = await _dir();
    if (await dir.exists()) {
      await for (final e in dir.list(followLinks: false)) {
        await e.delete(recursive: true);
      }
    }
    _total = 0;
  }

  Future<List<CacheEntry>> _entries() async {
    final dir = await _dir();
    final out = <CacheEntry>[];
    if (!await dir.exists()) return out;
    await for (final e in dir.list(recursive: true, followLinks: false)) {
      if (e is! File || !e.path.endsWith('.pbf')) continue;
      try {
        final st = await e.stat();
        out.add(CacheEntry(e.path, st.size, st.modified));
      } on FileSystemException {
        // raced with a delete
      }
    }
    return out;
  }

  Future<void> _evict(int cap) async {
    if (_evicting) return;
    _evicting = true;
    try {
      final entries = await _entries();
      _total = entries.fold<int>(0, (s, e) => s + e.sizeBytes);
      for (final e in pickEvictions(entries, cap * 9 ~/ 10)) {
        try {
          await File(e.path).delete();
          _total = _total! - e.sizeBytes;
        } on FileSystemException {
          // ignore
        }
      }
    } catch (e) {
      debugPrint('TileStore evict: $e');
    } finally {
      _evicting = false;
    }
  }
}
