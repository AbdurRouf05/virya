import 'package:virya/core/constants/enums.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/domain/share_options.dart';

/// Text formatting for share cards (Indonesian, uppercase poster style).
class SF {
  SF._();

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', //
    'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES',
  ];

  static String km(double m, {int digits = 1}) =>
      (m / 1000).toStringAsFixed(digits);

  static String duration(int s) {
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(sec)}' : '$m:${two(sec)}';
  }

  static String kmh(double mps) => (mps * 3.6).toStringAsFixed(1);

  /// Pace mm'ss" per km.
  static String pace(double mps) {
    if (mps <= 0.1) return "--'--\"";
    final s = (1000 / mps).round();
    return "${s ~/ 60}'${(s % 60).toString().padLeft(2, '0')}\"";
  }

  static String meters(double m) => m.round().toString();

  static String date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

  static String time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String _dm(double v, String pos, String neg) {
    final a = v.abs();
    final deg = a.floor();
    final min = ((a - deg) * 60).floor();
    return "$deg°${min.toString().padLeft(2, '0')}'${v >= 0 ? pos : neg}";
  }

  /// e.g. `6°50'S 107°37'E`
  static String coord(double lat, double lon) =>
      '${_dm(lat, 'N', 'S')} ${_dm(lon, 'E', 'W')}';

  static String sport(SportType s) => switch (s) {
        SportType.gravelCycling => 'GRAVEL',
        SportType.roadCycling => 'ROAD',
        SportType.mountainBiking => 'MTB',
        SportType.roadRunning => 'LARI',
        SportType.trailRunning => 'TRAIL RUN',
        SportType.hiking => 'HIKING',
        SportType.walking => 'JALAN',
      };

  static String stars(int n) {
    final k = n.clamp(0, 5);
    return '${'★' * k}${'☆' * (5 - k)}';
  }

  static String surface(SurfaceType s) => switch (s) {
        SurfaceType.asphalt => 'ASPAL',
        SurfaceType.smoothGravel => 'GRAVEL HALUS',
        SurfaceType.roughGravel => 'GRAVEL KASAR',
        SurfaceType.dirt => 'TANAH',
        SurfaceType.cobblestone => 'PAVING',
        SurfaceType.unknown => '—',
      };

  static String climbCat(ClimbCategory c) => switch (c) {
        ClimbCategory.flat => 'DATAR',
        ClimbCategory.cat4 => 'CAT 4',
        ClimbCategory.cat3 => 'CAT 3',
        ClimbCategory.cat2 => 'CAT 2',
        ClimbCategory.cat1 => 'CAT 1',
        ClimbCategory.hc => 'HC',
      };

  /// Notebook entry number derived from the id (cosmetic).
  static String entryNo(ShareData d) =>
      '№ ${(d.seed % 900 + 100).toString()}';
}

/// One rendered stat (label, value, unit).
class StatValue {
  final String label;
  final String value;
  final String unit;
  const StatValue(this.label, this.value, this.unit);
}

List<StatValue> statValues(ShareData d, Set<ShareStat> stats) {
  final out = <StatValue>[];
  for (final s in ShareStat.values) {
    if (!stats.contains(s)) continue;
    switch (s) {
      case ShareStat.time:
        out.add(StatValue('WAKTU', SF.duration(d.movingTimeS), ''));
      case ShareStat.elevation:
        out.add(StatValue('ELEV', '+${SF.meters(d.elevationGainM)}', 'M'));
      case ShareStat.speed:
        if (d.sport.isRunning) {
          out.add(StatValue('PACE', SF.pace(d.avgSpeedMps), '/KM'));
        } else {
          out.add(StatValue('RATA2', SF.kmh(d.avgSpeedMps), 'KM/J'));
        }
      case ShareStat.grit:
        out.add(StatValue(
          'GRIT',
          d.gritScore > 0 ? d.gritScore.round().toString() : '—',
          d.gritScore > 0 ? '/100' : '',
        ));
      case ShareStat.heartRate:
        if (d.avgHeartRate != null) {
          out.add(StatValue('HR', '${d.avgHeartRate}', 'BPM'));
        }
    }
  }
  return out;
}
