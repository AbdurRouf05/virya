import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/sensors/heart_rate_parser.dart';

void main() {
  test('uint8 format', () {
    final r = parseHeartRateMeasurement([0x00, 72])!;
    expect(r.bpm, 72);
    expect(r.contact, isNull);
    expect(r.usable, isTrue);
  });

  test('uint16 format is little-endian', () {
    expect(parseHeartRateMeasurement([0x01, 0x2C, 0x00])!.bpm, 44);
    expect(parseHeartRateMeasurement([0x01, 0x00, 0x01])!.bpm, 256);
  });

  test('contact supported and detected', () {
    final r = parseHeartRateMeasurement([0x06, 140])!;
    expect(r.contact, isTrue);
    expect(r.usable, isTrue);
  });

  test('contact supported but not detected is unusable', () {
    final r = parseHeartRateMeasurement([0x04, 140])!;
    expect(r.contact, isFalse);
    expect(r.usable, isFalse);
  });

  test('detected bit without the supported bit is ignored', () {
    expect(parseHeartRateMeasurement([0x02, 140])!.contact, isNull);
  });

  test('trailing energy and RR fields are ignored', () {
    final r = parseHeartRateMeasurement([0x18, 90, 0x10, 0x00, 0x20, 0x03])!;
    expect(r.bpm, 90);
  });

  test('empty or truncated data returns null', () {
    expect(parseHeartRateMeasurement([]), isNull);
    expect(parseHeartRateMeasurement([0x00]), isNull);
    expect(parseHeartRateMeasurement([0x01, 0x50]), isNull);
  });

  test('implausible values are unusable', () {
    expect(parseHeartRateMeasurement([0x00, 0])!.usable, isFalse);
    expect(parseHeartRateMeasurement([0x00, 24])!.usable, isFalse);
    expect(parseHeartRateMeasurement([0x00, 25])!.usable, isTrue);
    expect(parseHeartRateMeasurement([0x00, 250])!.usable, isTrue);
    expect(parseHeartRateMeasurement([0x01, 0xFB, 0x00])!.usable, isFalse);
  });
}
