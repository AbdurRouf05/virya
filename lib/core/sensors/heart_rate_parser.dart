/// One decoded Heart Rate Measurement (GATT characteristic 0x2A37).
class HeartRateReading {
  static const minPlausibleBpm = 25;
  static const maxPlausibleBpm = 250;

  final int bpm;

  /// Skin contact: null when the sensor does not report it.
  final bool? contact;

  const HeartRateReading(this.bpm, {this.contact});

  /// False when the strap is off the skin or the value cannot be a pulse.
  bool get usable =>
      contact != false && bpm >= minPlausibleBpm && bpm <= maxPlausibleBpm;
}

/// Decodes a 0x2A37 notification. Bit 0 of the flags selects uint8 or
/// little-endian uint16; bits 1–2 carry the sensor contact status. Trailing
/// fields (energy, RR intervals) are ignored. Returns null when truncated.
HeartRateReading? parseHeartRateMeasurement(List<int> data) {
  if (data.isEmpty) return null;
  final flags = data[0];
  final wide = flags & 0x01 != 0;
  if (data.length < (wide ? 3 : 2)) return null;
  final bpm = wide ? data[1] | (data[2] << 8) : data[1];
  final contactSupported = flags & 0x04 != 0;
  final contactDetected = flags & 0x02 != 0;
  return HeartRateReading(
    bpm,
    contact: contactSupported ? contactDetected : null,
  );
}
