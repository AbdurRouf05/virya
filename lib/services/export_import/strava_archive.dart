import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// RFC-4180-ish CSV parser (quoted fields, "" escapes, newlines in quotes).
List<List<String>> parseCsv(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;
  var i = 0;
  if (text.startsWith('﻿')) i = 1;
  for (; i < text.length; i++) {
    final c = text[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"') {
      inQuotes = true;
    } else if (c == ',') {
      row.add(field.toString());
      field.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(field.toString());
      field.clear();
      if (row.length > 1 || row.first.isNotEmpty) rows.add(row);
      row = <String>[];
    } else {
      field.write(c);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  return rows;
}

/// Metadata from Strava's `activities.csv`, keyed by archive file name.
class StravaCsvEntry {
  final String? name;
  final String? type;
  const StravaCsvEntry(this.name, this.type);
}

Map<String, StravaCsvEntry> parseStravaActivitiesCsv(String text) {
  final rows = parseCsv(text);
  if (rows.isEmpty) return const {};
  final header = rows.first.map((h) => h.trim().toLowerCase()).toList();
  int col(String name) => header.indexOf(name); // first occurrence
  final fi = col('filename'), ni = col('activity name'), ti = col('activity type');
  if (fi < 0) return const {};
  final out = <String, StravaCsvEntry>{};
  for (final r in rows.skip(1)) {
    if (fi >= r.length) continue;
    final file = r[fi].trim();
    if (file.isEmpty) continue;
    String? at(int k) => (k >= 0 && k < r.length && r[k].trim().isNotEmpty)
        ? r[k].trim()
        : null;
    out[normalizeArchivePath(file)] = StravaCsvEntry(at(ni), at(ti));
  }
  return out;
}

String normalizeArchivePath(String p) {
  var s = p.replaceAll('\\', '/');
  while (s.startsWith('./') || s.startsWith('/')) {
    s = s.startsWith('./') ? s.substring(2) : s.substring(1);
  }
  return s.toLowerCase();
}

/// Activity files in an archive, with `activities.csv` metadata attached.
/// Lazily yields (name, bytes, csvEntry) so huge exports stream.
Iterable<({String name, Uint8List bytes, StravaCsvEntry? meta})>
    stravaArchiveEntries(Archive archive) sync* {
  Map<String, StravaCsvEntry> csv = const {};
  for (final f in archive.files) {
    if (!f.isFile) continue;
    final n = normalizeArchivePath(f.name);
    if (n == 'activities.csv' || n.endsWith('/activities.csv')) {
      final bytes = f.readBytes();
      if (bytes != null) {
        csv = parseStravaActivitiesCsv(utf8.decode(bytes, allowMalformed: true));
      }
      break;
    }
  }
  for (final f in archive.files) {
    if (!f.isFile) continue;
    final n = normalizeArchivePath(f.name);
    if (!isActivityFileName(n)) continue;
    final bytes = f.readBytes();
    if (bytes == null) continue;
    // CSV paths are relative to the export root ("activities/123.gpx.gz").
    StravaCsvEntry? meta = csv[n];
    if (meta == null) {
      for (final e in csv.entries) {
        if (n.endsWith('/${e.key}')) {
          meta = e.value;
          break;
        }
      }
    }
    yield (name: f.name, bytes: bytes, meta: meta);
  }
}

bool isActivityFileName(String lower) {
  final s = lower.endsWith('.gz') ? lower.substring(0, lower.length - 3) : lower;
  return s.endsWith('.gpx') || s.endsWith('.tcx') || s.endsWith('.fit');
}
