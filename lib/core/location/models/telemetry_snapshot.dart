import 'package:stravo/core/constants/enums.dart';

/// Model Snapshot Telemetri Realtime (Frekuensi 1 Hz / 1 detik)
/// Diproduksi oleh Live Tracking Engine.
/// dan dikonsumsi oleh Live Telemetry HUD, Peta Live, dan Live Segment Matcher (Rekan).
class LiveTelemetrySnapshot {
  /// Kecepatan saat ini dalam km/jam (misal: 28.4 km/h)
  final double currentSpeedKmh;

  /// Kecepatan rata-rata aktivitas dalam km/jam
  final double averageSpeedKmh;

  /// Total jarak kumulatif yang telah ditempuh dalam meter
  final double totalDistanceMeters;

  /// Durasi waktu bergerak (dikurangi waktu jeda/auto-pause) dalam detik
  final int movingTimeSeconds;

  /// Durasi waktu total sejak start dalam detik
  final int elapsedTimeSeconds;

  /// Ketinggian saat ini dari atas permukaan laut (meter)
  final double currentAltitudeMeters;

  /// Total akumulasi elevasi naik (elevation gain) dalam meter
  final double totalElevationGainMeters;

  /// Kemiringan tanjakan/turunan saat ini dalam persen (misal: 7.5% atau -3.2%)
  final double currentGradePct;

  /// Estimasi jenis permukaan jalan berdasarkan sensor getaran accelerometer
  final SurfaceType currentSurface;

  /// Koordinat lintang saat ini (WGS84)
  final double latitude;

  /// Koordinat bujur saat ini (WGS84)
  final double longitude;

  /// Akurasi sinyal GPS dalam radius meter
  final double accuracyMeters;

  /// Arah hadap kompas (0 - 360 derajat)
  final double bearingDegrees;

  /// Waktu titik dicatat
  final DateTime timestamp;

  /// Status apakah sistem sedang dalam mode jeda otomatis (Auto-Pause)
  final bool isAutoPaused;

  // v2 additions (optional, backwards compatible)

  /// Status jeda manual oleh pengguna.
  final bool isManuallyPaused;

  /// Total penurunan elevasi (meter).
  final double totalElevationLossMeters;

  /// Kecepatan maksimum (km/jam).
  final double maxSpeedKmh;

  /// Detak jantung terakhir (bpm), null jika tidak ada sensor.
  final int? heartRate;

  /// Kadens terakhir (rpm / spm), null jika tidak ada sensor.
  final int? cadence;

  /// RMS getaran detik terakhir (m/s^2, tanpa gravitasi).
  final double vibrationRms;

  /// True bila belum ada fix GPS yang lolos filter.
  final bool hasFix;

  const LiveTelemetrySnapshot({
    required this.currentSpeedKmh,
    required this.averageSpeedKmh,
    required this.totalDistanceMeters,
    required this.movingTimeSeconds,
    required this.elapsedTimeSeconds,
    required this.currentAltitudeMeters,
    required this.totalElevationGainMeters,
    required this.currentGradePct,
    required this.currentSurface,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.bearingDegrees,
    required this.timestamp,
    required this.isAutoPaused,
    this.isManuallyPaused = false,
    this.totalElevationLossMeters = 0,
    this.maxSpeedKmh = 0,
    this.heartRate,
    this.cadence,
    this.vibrationRms = 0,
    this.hasFix = true,
  });

  bool get isPaused => isAutoPaused || isManuallyPaused;

  /// Pace saat ini (detik per km); null jika hampir diam.
  double? get currentPaceSecPerKm =>
      currentSpeedKmh < 1.0 ? null : 3600 / currentSpeedKmh;

  /// Pace rata-rata (detik per km); null jika belum bergerak.
  double? get averagePaceSecPerKm =>
      averageSpeedKmh < 1.0 ? null : 3600 / averageSpeedKmh;

  /// Factory helper untuk inisialisasi state awal sebelum GPS lock
  factory LiveTelemetrySnapshot.initial() {
    return LiveTelemetrySnapshot(
      currentSpeedKmh: 0.0,
      averageSpeedKmh: 0.0,
      totalDistanceMeters: 0.0,
      movingTimeSeconds: 0,
      elapsedTimeSeconds: 0,
      currentAltitudeMeters: 0.0,
      totalElevationGainMeters: 0.0,
      currentGradePct: 0.0,
      currentSurface: SurfaceType.unknown,
      latitude: 0.0,
      longitude: 0.0,
      accuracyMeters: 0.0,
      bearingDegrees: 0.0,
      timestamp: DateTime.now(),
      isAutoPaused: false,
      hasFix: false,
    );
  }
}
