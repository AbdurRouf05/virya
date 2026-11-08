import 'dart:typed_data';

import 'package:stravo/core/models/track_sample.dart';
import 'package:stravo/services/export_import/parsed_activity.dart';

/// Compact FIT (Flexible and Interoperable Data Transfer) decoder.
///
/// Handles file header, definition/data messages, compressed-timestamp
/// headers, both endiannesses, developer fields (skipped) and chained files.
/// Decodes `record` (20), `session` (18) and `sport` (12). CRCs are ignored.
class FitDecoder {
  static const int _fitEpochS = 631065600; // 1989-12-31T00:00:00Z

  static bool looksLikeFit(Uint8List b) =>
      b.length >= 12 &&
      b[8] == 0x2E && // .FIT
      b[9] == 0x46 &&
      b[10] == 0x49 &&
      b[11] == 0x54;

  List<ParsedActivity> decode(Uint8List bytes, {String? sourceName}) {
    final data = ByteData.sublistView(bytes);
    final samples = <TrackSample>[];
    int? sport, subSport;
    try {
      _decodeAll(bytes, data, samples, (s, ss) {
        sport = s ?? sport;
        subSport = ss ?? subSport;
      });
    } on RangeError {
      // Truncated file: keep what was decoded.
    }
    if (samples.isEmpty) return const [];
    samples.sort((a, b) => a.time.compareTo(b.time));
    return [
      ParsedActivity(
        sport: sportFromFit(sport, subSport),
        samples: samples,
        format: 'fit',
        sourceName: sourceName,
      )
    ];
  }

  void _decodeAll(Uint8List bytes, ByteData data, List<TrackSample> samples,
      void Function(int?, int?) setSport) {
    var pos = 0;
    while (pos + 12 <= bytes.length) {
      final headerSize = bytes[pos];
      if (headerSize < 12 || pos + headerSize > bytes.length) break;
      final dataSize = data.getUint32(pos + 4, Endian.little);
      if (!looksLikeFit(Uint8List.sublistView(bytes, pos))) {
        throw const FormatException('Not a FIT file');
      }
      var p = pos + headerSize;
      var end = p + dataSize;
      if (end > bytes.length) end = bytes.length; // truncated: best effort
      final defs = <int, _Def>{};
      var lastTs = 0;
      while (p < end) {
        final h = bytes[p++];
        if (h & 0x80 != 0) {
          // Compressed timestamp header.
          final local = (h >> 5) & 0x03;
          final offset = h & 0x1F;
          var ts = (lastTs & ~0x1F) + offset;
          if (offset < (lastTs & 0x1F)) ts += 0x20;
          lastTs = ts;
          final def = defs[local];
          if (def == null) throw const FormatException('FIT: undefined local');
          final v = _readFields(data, p, def);
          p += def.size;
          v[253] = ts;
          _handle(def.global, v, samples, setSport);
          continue;
        }
        final local = h & 0x0F;
        if (h & 0x40 != 0) {
          // Definition message.
          final hasDev = h & 0x20 != 0;
          final little = bytes[p + 1] == 0;
          final global = data.getUint16(
              p + 2, little ? Endian.little : Endian.big);
          final nFields = bytes[p + 4];
          p += 5;
          final fields = <_Field>[];
          for (var k = 0; k < nFields; k++) {
            fields.add(_Field(bytes[p], bytes[p + 1], bytes[p + 2]));
            p += 3;
          }
          var devSize = 0;
          if (hasDev) {
            final nDev = bytes[p++];
            for (var k = 0; k < nDev; k++) {
              devSize += bytes[p + 1];
              p += 3;
            }
          }
          defs[local] = _Def(global, little, fields, devSize);
        } else {
          final def = defs[local];
          if (def == null) throw const FormatException('FIT: undefined local');
          final v = _readFields(data, p, def);
          p += def.size;
          final ts = v[253];
          if (ts != null) lastTs = ts.toInt();
          _handle(def.global, v, samples, setSport);
        }
      }
      pos = pos + headerSize + dataSize + 2; // + file CRC
    }
  }

  void _handle(int global, Map<int, num> v, List<TrackSample> out,
      void Function(int?, int?) setSport) {
    switch (global) {
      case 20: // record
        final ts = v[253], la = v[0], lo = v[1];
        if (ts == null || la == null || lo == null) return;
        const k = 180.0 / 2147483648.0;
        final alt = v[78] ?? v[2];
        final spd = v[73] ?? v[6];
        out.add(TrackSample(
          time: DateTime.fromMillisecondsSinceEpoch(
              (ts.toInt() + _fitEpochS) * 1000,
              isUtc: true),
          lat: la * k,
          lon: lo * k,
          ele: alt == null ? null : alt / 5 - 500,
          speedMps: spd == null ? null : spd / 1000,
          heartRate: v[3]?.toInt(),
          cadence: v[4]?.toInt(),
        ));
      case 18: // session
        setSport(v[5]?.toInt(), v[6]?.toInt());
      case 12: // sport
        setSport(v[0]?.toInt(), v[1]?.toInt());
    }
  }

  /// Read numeric fields; invalid values are omitted. Arrays → first item.
  Map<int, num> _readFields(ByteData d, int p, _Def def) {
    final out = <int, num>{};
    final e = def.little ? Endian.little : Endian.big;
    for (final f in def.fields) {
      final v = _read(d, p, f, e);
      if (v != null) out[f.num] = v;
      p += f.size;
    }
    return out;
  }

  num? _read(ByteData d, int p, _Field f, Endian e) {
    final base = f.type & 0x1F;
    final w = _width[base];
    if (w == null || f.size < w) return null;
    switch (base) {
      case 0x00: // enum
      case 0x02: // uint8
      case 0x0D: // byte
        final v = d.getUint8(p);
        return v == 0xFF ? null : v;
      case 0x0A: // uint8z
        final v = d.getUint8(p);
        return v == 0 ? null : v;
      case 0x01:
        final v = d.getInt8(p);
        return v == 0x7F ? null : v;
      case 0x03:
        final v = d.getInt16(p, e);
        return v == 0x7FFF ? null : v;
      case 0x04:
        final v = d.getUint16(p, e);
        return v == 0xFFFF ? null : v;
      case 0x0B:
        final v = d.getUint16(p, e);
        return v == 0 ? null : v;
      case 0x05:
        final v = d.getInt32(p, e);
        return v == 0x7FFFFFFF ? null : v;
      case 0x06:
        final v = d.getUint32(p, e);
        return v == 0xFFFFFFFF ? null : v;
      case 0x0C:
        final v = d.getUint32(p, e);
        return v == 0 ? null : v;
      case 0x08:
        final v = d.getFloat32(p, e);
        return v.isNaN ? null : v;
      case 0x09:
        final v = d.getFloat64(p, e);
        return v.isNaN ? null : v;
      case 0x0E:
        final v = d.getInt64(p, e);
        return v == 0x7FFFFFFFFFFFFFFF ? null : v;
      case 0x0F:
      case 0x10:
        final v = d.getUint64(p, e);
        return (v == -1 || (base == 0x10 && v == 0)) ? null : v;
    }
    return null; // strings etc.
  }

  static const Map<int, int> _width = {
    0x00: 1, 0x01: 1, 0x02: 1, 0x03: 2, 0x04: 2, 0x05: 4, 0x06: 4, //
    0x08: 4, 0x09: 8, 0x0A: 1, 0x0B: 2, 0x0C: 4, 0x0D: 1, 0x0E: 8, //
    0x0F: 8, 0x10: 8,
  };
}

class _Field {
  final int num, size, type;
  const _Field(this.num, this.size, this.type);
}

class _Def {
  final int global;
  final bool little;
  final List<_Field> fields;
  final int size;
  _Def(this.global, this.little, this.fields, int devSize)
      : size = fields.fold<int>(0, (a, f) => a + f.size) + devSize;
}
