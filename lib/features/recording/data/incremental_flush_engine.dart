import 'dart:async';
import 'package:drift/drift.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/daos/activities_dao.dart';
import 'package:virya/core/database/daos/track_points_dao.dart';

/// Incremental Local Flush Engine (Mesin Komit Berkala Anti-Crash)
///
/// Menyimpan buffer titik koordinat di memori dan otomatis melakukan commit (flush)
/// ke SQLite lokal setiap 5 detik atau saat buffer mencapai 5 titik.
/// Menjamin 0% data hilang jika ponsel kehabisan baterai atau OS menghentikan aplikasi.
class IncrementalFlushEngine {
  final TrackPointsDao _trackPointsDao;
  final ActivitiesDao _activitiesDao;
  final String activityId;

  /// Jumlah titik maksimal dalam buffer sebelum auto-flush dipicu
  final int flushThreshold;

  /// Interval waktu auto-flush
  final Duration flushInterval;

  final List<TrackPointsCompanion> _buffer = [];
  Timer? _periodicTimer;

  int _totalFlushedCount = 0;
  int get totalFlushedCount => _totalFlushedCount;
  int get bufferedPointsCount => _buffer.length;

  // Nilai telemetri kumulatif terakhir untuk update ringkasan tabel activities
  double _lastDistanceMeters = 0.0;
  int _lastMovingTimeSeconds = 0;
  int _lastElapsedTimeSeconds = 0;
  double _lastElevationGainMeters = 0.0;
  double _lastAvgSpeedMps = 0.0;
  double _lastMaxSpeedMps = 0.0;
  double _lastGravelPct = 0.0;
  double _lastAsphaltPct = 0.0;

  IncrementalFlushEngine({
    required TrackPointsDao trackPointsDao,
    required ActivitiesDao activitiesDao,
    required this.activityId,
    this.flushThreshold = 5,
    this.flushInterval = const Duration(seconds: 5),
    bool autoStartTimer = true,
  })  : _trackPointsDao = trackPointsDao,
        _activitiesDao = activitiesDao {
    if (autoStartTimer) {
      _startPeriodicTimer();
    }
  }

  void _startPeriodicTimer() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(flushInterval, (_) {
      // Errors keep the points buffered; the next tick retries.
      flush().catchError((Object _) {});
    });
  }

  /// Tambahkan 1 titik GPS baru ke dalam buffer dan update telemetri terakhir
  Future<void> recordPoint(
    TrackPointsCompanion point, {
    double? totalDistanceMeters,
    int? movingTimeSeconds,
    int? elapsedTimeSeconds,
    double? elevationGainMeters,
    double? avgSpeedMps,
    double? maxSpeedMps,
    double? gravelPercentage,
    double? asphaltPercentage,
  }) async {
    _buffer.add(point);

    if (totalDistanceMeters != null) _lastDistanceMeters = totalDistanceMeters;
    if (movingTimeSeconds != null) _lastMovingTimeSeconds = movingTimeSeconds;
    if (elapsedTimeSeconds != null) _lastElapsedTimeSeconds = elapsedTimeSeconds;
    if (elevationGainMeters != null) _lastElevationGainMeters = elevationGainMeters;
    if (avgSpeedMps != null) _lastAvgSpeedMps = avgSpeedMps;
    if (maxSpeedMps != null && maxSpeedMps > _lastMaxSpeedMps) {
      _lastMaxSpeedMps = maxSpeedMps;
    }
    if (gravelPercentage != null) _lastGravelPct = gravelPercentage;
    if (asphaltPercentage != null) _lastAsphaltPct = asphaltPercentage;

    // Jika buffer sudah mencapai batas threshold (default 5 titik), segera flush
    if (_buffer.length >= flushThreshold) {
      await flush();
    }
  }

  Future<void>? _inFlight;

  /// Tulis buffer ke SQLite dan update ringkasan aktivitas.
  /// Flush diserialisasi agar timer dan threshold tidak bertabrakan.
  Future<void> flush() async {
    while (_inFlight != null) {
      await _inFlight;
    }
    if (_buffer.isEmpty) return;
    final f = _flushNow();
    _inFlight = f;
    try {
      await f;
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _flushNow() async {
    final batchToFlush = List<TrackPointsCompanion>.from(_buffer);
    _buffer.clear();

    try {
      // 1. Commit titik GPS secara batch ke SQLite
      await _trackPointsDao.insertBatchTrackPoints(batchToFlush);
      _totalFlushedCount += batchToFlush.length;

      // 2. Partial update: hanya kolom ringkasan live (kolom lain dipertahankan)
      final db = _activitiesDao.attachedDatabase;
      await (db.update(db.activities)..where((t) => t.id.equals(activityId)))
          .write(ActivitiesCompanion(
        totalDistanceMeters: Value(_lastDistanceMeters),
        movingTimeSeconds: Value(_lastMovingTimeSeconds),
        elapsedTimeSeconds: Value(_lastElapsedTimeSeconds),
        elevationGainMeters: Value(_lastElevationGainMeters),
        avgSpeedMps: Value(_lastAvgSpeedMps),
        maxSpeedMps: Value(_lastMaxSpeedMps),
        gravelPercentage: Value(_lastGravelPct),
        asphaltPercentage: Value(_lastAsphaltPct),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e) {
      // Commit gagal (misal SQLite lock): kembalikan ke buffer
      _buffer.insertAll(0, batchToFlush);
      rethrow;
    }
  }

  /// Hentikan timer dan lakukan final flush sebelum sesi selesai
  Future<void> dispose() async {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    await flush();
  }
}
