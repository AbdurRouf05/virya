import 'dart:typed_data';

/// Minimal FIT writer for tests: record definition with a developer field,
/// [fullRecords] normal records then [compressed] compressed-timestamp
/// records (position only), and a big-endian session (cycling / gravel).
Uint8List buildTestFit({
  required DateTime start,
  int fullRecords = 3,
  int compressed = 0,
}) {
  final body = BytesBuilder();
  void u8(int v) => body.addByte(v & 0xFF);
  void u16(int v) => body.add((ByteData(2)..setUint16(0, v, Endian.little))
      .buffer
      .asUint8List());
  void u32(int v) => body.add((ByteData(4)..setUint32(0, v, Endian.little))
      .buffer
      .asUint8List());
  void s32(int v) => body.add((ByteData(4)..setInt32(0, v, Endian.little))
      .buffer
      .asUint8List());
  int semi(double deg) => (deg * 2147483648.0 / 180.0).round();

  final ts0 = start.millisecondsSinceEpoch ~/ 1000 - 631065600;

  // Local 0: record with timestamp, lat, lon, enhanced alt, hr, speed + dev.
  u8(0x40 | 0x20 | 0);
  u8(0); // reserved
  u8(0); // little endian
  u16(20);
  u8(6);
  for (final f in [
    [253, 4, 0x86],
    [0, 4, 0x85],
    [1, 4, 0x85],
    [78, 4, 0x86],
    [3, 1, 0x02],
    [6, 2, 0x84],
  ]) {
    f.forEach(u8);
  }
  u8(1); // one developer field
  u8(0); // field number
  u8(2); // size
  u8(0); // developer data index

  // Local 1: record without timestamp (for compressed headers).
  u8(0x40 | 1);
  u8(0);
  u8(0);
  u16(20);
  u8(3);
  for (final f in [
    [0, 4, 0x85],
    [1, 4, 0x85],
    [78, 4, 0x86],
  ]) {
    f.forEach(u8);
  }

  for (var i = 0; i < fullRecords; i++) {
    u8(0);
    u32(ts0 + i);
    s32(semi(-7.25 + i * 1e-4));
    s32(semi(112.75 + i * 1e-4));
    u32(((100 + i * 1.2 + 500) * 5).round());
    u8(130 + i);
    u16(7000 + i * 250);
    u16(0xBEEF); // developer payload (ignored)
  }
  for (var j = 0; j < compressed; j++) {
    final i = fullRecords + j;
    final ts = ts0 + i;
    u8(0x80 | (1 << 5) | (ts & 0x1F));
    s32(semi(-7.25 + i * 1e-4));
    s32(semi(112.75 + i * 1e-4));
    u32(0xFFFFFFFF); // invalid altitude
  }

  // Local 2: session, big endian, sport=2 (cycling), sub_sport=46 (gravel).
  u8(0x40 | 2);
  u8(0);
  u8(1);
  body.add([0, 18]);
  u8(2);
  [5, 1, 0x00].forEach(u8);
  [6, 1, 0x00].forEach(u8);
  u8(2);
  u8(2);
  u8(46);

  final data = body.toBytes();
  final out = BytesBuilder()
    ..add([14, 0x10])
    ..add((ByteData(2)..setUint16(0, 2093, Endian.little)).buffer.asUint8List())
    ..add((ByteData(4)..setUint32(0, data.length, Endian.little))
        .buffer
        .asUint8List())
    ..add('.FIT'.codeUnits)
    ..add([0, 0]) // header CRC (ignored)
    ..add(data)
    ..add([0, 0]); // file CRC
  return out.toBytes();
}
