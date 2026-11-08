import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/location/models/telemetry_snapshot.dart';

enum CueLanguage { indonesian, english }

/// One completed split (e.g. each km).
class SplitInfo {
  final int index; // 1-based
  final double unitM; // split length in meters (1000 or 1609.344 * n)
  final int splitMovingS;
  final double splitDistanceM;
  final double splitGainM;
  final int totalMovingS;

  const SplitInfo({
    required this.index,
    required this.unitM,
    required this.splitMovingS,
    required this.splitDistanceM,
    required this.splitGainM,
    required this.totalMovingS,
  });

  double get splitSpeedMps =>
      splitMovingS == 0 ? 0 : splitDistanceM / splitMovingS;
}

/// Detects split boundaries from cumulative snapshots.
class SplitTracker {
  final double splitM;
  int _done = 0;
  int _lastMovingS = 0;
  double _lastDistanceM = 0;
  double _lastGainM = 0;

  SplitTracker(this.splitM);

  /// Skip splits already covered (crash-recovery resume).
  void seed(LiveTelemetrySnapshot s) {
    _done = (s.totalDistanceMeters / splitM).floor();
    _lastMovingS = s.movingTimeSeconds;
    _lastDistanceM = s.totalDistanceMeters;
    _lastGainM = s.totalElevationGainMeters;
  }

  SplitInfo? update(LiveTelemetrySnapshot s) {
    if (splitM <= 0) return null;
    final n = (s.totalDistanceMeters / splitM).floor();
    if (n <= _done) return null;
    final info = SplitInfo(
      index: n,
      unitM: splitM,
      splitMovingS: s.movingTimeSeconds - _lastMovingS,
      splitDistanceM: s.totalDistanceMeters - _lastDistanceM,
      splitGainM: s.totalElevationGainMeters - _lastGainM,
      totalMovingS: s.movingTimeSeconds,
    );
    _done = n;
    _lastMovingS = s.movingTimeSeconds;
    _lastDistanceM = s.totalDistanceMeters;
    _lastGainM = s.totalElevationGainMeters;
    return info;
  }
}

/// Builds spoken sentences. Pure, unit-tested.
class CueFormatter {
  final CueLanguage lang;
  final bool imperial;

  const CueFormatter({this.lang = CueLanguage.indonesian, this.imperial = false});

  bool get _id => lang == CueLanguage.indonesian;

  static const double _mile = 1609.344;

  String split(SplitInfo s, SportType sport) {
    final unitDist = imperial ? _mile : 1000.0;
    final distUnits = s.index * s.unitM / unitDist;
    final distText = _num(distUnits, decimals: distUnits % 1 == 0 ? 0 : 1);
    final parts = <String>[];
    if (_id) {
      parts.add('${imperial ? 'Mil' : 'Kilometer'} $distText.');
    } else {
      parts.add('${imperial ? 'Mile' : 'Kilometer'} $distText.');
    }

    final usePace = !sport.isCycling;
    if (usePace) {
      final paceS = s.splitDistanceM <= 0
          ? 0
          : (s.splitMovingS / s.splitDistanceM * unitDist).round();
      parts.add(_id
          ? 'Pace ${_duration(paceS)} per ${imperial ? 'mil' : 'kilometer'}.'
          : 'Pace ${_duration(paceS)} per ${imperial ? 'mile' : 'kilometer'}.');
    } else {
      final speed = s.splitSpeedMps * 3.6 / (imperial ? 1.609344 : 1);
      parts.add(_id
          ? 'Waktu split ${_duration(s.splitMovingS)}, kecepatan rata-rata '
              '${_num(speed)} ${imperial ? 'mil' : 'kilometer'} per jam.'
          : 'Split time ${_duration(s.splitMovingS)}, average speed '
              '${_num(speed)} ${imperial ? 'miles' : 'kilometers'} per hour.');
    }
    parts.add(_id
        ? 'Total waktu ${_duration(s.totalMovingS)}.'
        : 'Total time ${_duration(s.totalMovingS)}.');

    final gain = imperial ? s.splitGainM * 3.28084 : s.splitGainM;
    if (gain >= 1) {
      final g = gain.round();
      parts.add(_id
          ? 'Naik $g ${imperial ? 'kaki' : 'meter'}.'
          : 'Climbed $g ${imperial ? 'feet' : 'meters'}.');
    }
    return parts.join(' ');
  }

  String autoPaused() => _id ? 'Jeda otomatis.' : 'Auto paused.';
  String autoResumed() => _id ? 'Melanjutkan.' : 'Resumed.';
  String manualPaused() => _id ? 'Rekaman dijeda.' : 'Recording paused.';
  String manualResumed() =>
      _id ? 'Rekaman dilanjutkan.' : 'Recording resumed.';
  String started() => _id ? 'Rekaman dimulai.' : 'Recording started.';

  String _duration(int totalS) {
    final h = totalS ~/ 3600;
    final m = (totalS % 3600) ~/ 60;
    final s = totalS % 60;
    final out = <String>[];
    if (_id) {
      if (h > 0) out.add('$h jam');
      if (m > 0) out.add('$m menit');
      if (s > 0 || out.isEmpty) out.add('$s detik');
    } else {
      if (h > 0) out.add('$h ${h == 1 ? 'hour' : 'hours'}');
      if (m > 0) out.add('$m ${m == 1 ? 'minute' : 'minutes'}');
      if (s > 0 || out.isEmpty) out.add('$s ${s == 1 ? 'second' : 'seconds'}');
    }
    return out.join(' ');
  }

  /// Number for speech: Indonesian uses "koma" as decimal separator.
  String _num(double v, {int decimals = 1}) {
    final t = v.toStringAsFixed(decimals);
    if (decimals == 0) return t;
    final parts = t.split('.');
    if (parts[1] == '0') return parts[0];
    return _id ? '${parts[0]} koma ${parts[1]}' : t;
  }
}
