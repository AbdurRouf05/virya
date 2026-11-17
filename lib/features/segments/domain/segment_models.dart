import 'package:virya/core/constants/enums.dart';

/// Satu segmen di daftar, dengan rekor dan jumlah upayanya.
class SegmentSummary {
  final String id;
  final String name;
  final List<(double lat, double lon)> polyline;
  final double distanceM;
  final int? bestS;
  final int effortCount;
  final DateTime? lastEffortAt;

  const SegmentSummary({
    required this.id,
    required this.name,
    required this.polyline,
    required this.distanceM,
    this.bestS,
    this.effortCount = 0,
    this.lastEffortAt,
  });
}

/// Satu upaya di riwayat segmen.
class SegmentEffortRow {
  final String activityId;
  final String activityTitle;
  final DateTime startedAt;
  final int elapsedS;
  final bool isBest;

  const SegmentEffortRow({
    required this.activityId,
    required this.activityTitle,
    required this.startedAt,
    required this.elapsedS,
    required this.isBest,
  });
}

/// Satu segmen yang dilewati dalam sebuah aktivitas.
class ActivitySegmentRow {
  final String segmentId;
  final String segmentName;
  final double distanceM;
  final int elapsedS;
  final bool isBest;

  const ActivitySegmentRow({
    required this.segmentId,
    required this.segmentName,
    required this.distanceM,
    required this.elapsedS,
    required this.isBest,
  });
}

/// Bahan satu segmen untuk dipantau saat merekam.
class LiveSegmentSeed {
  final String id;
  final String name;
  final List<(double lat, double lon)> polyline;

  /// Detik pada tiap 50 m dari upaya tercepat; `null` bila belum ada upaya.
  final List<int>? ghostMarksS;
  final int? ghostTimeS;

  const LiveSegmentSeed({
    required this.id,
    required this.name,
    required this.polyline,
    this.ghostMarksS,
    this.ghostTimeS,
  });
}

int _family(SportType s) => s.isCycling ? 0 : (s.isRunning ? 1 : 2);

/// Segmen hanya berlaku untuk keluarga olahraganya: sepeda, lari, atau jalan.
/// [segmentSport] `null` berarti berlaku untuk semua olahraga GPS.
bool segmentAllowsSport(String? segmentSport, SportType sport) {
  if (!sport.isGps) return false;
  if (segmentSport == null) return true;
  final own = SportType.values.asNameMap()[segmentSport];
  return own == null || _family(own) == _family(sport);
}
