import 'package:stravo/core/constants/enums.dart';

enum Units { metric, imperial }

/// Unit-aware formatting. Numbers and units are returned separately so the UI
/// can render the number in Anton and the unit in PlexMono.
class Fmt {
  final Units units;
  const Fmt([this.units = Units.metric]);

  static const _mPerMi = 1609.344;
  static const _ftPerM = 3.28084;

  bool get imperial => units == Units.imperial;

  // Distance
  String get distUnit => imperial ? 'MI' : 'KM';
  double distanceValue(double m) => imperial ? m / _mPerMi : m / 1000;
  String distance(double m, {int? decimals}) {
    final v = distanceValue(m);
    final d = decimals ?? (v >= 100 ? 1 : 2);
    return _group(v.toStringAsFixed(d));
  }

  String distanceFull(double m, {int? decimals}) =>
      '${distance(m, decimals: decimals)} ${distUnit.toLowerCase()}';

  // Duration
  static String duration(int seconds) {
    final s = seconds.abs();
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = sec.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$m:$ss';
  }

  /// "2j 14m" style compact duration for totals.
  static String durationShort(int seconds) {
    final h = seconds ~/ 3600, m = (seconds % 3600) ~/ 60;
    if (h == 0) return '${m}m';
    return '${h}j ${m.toString().padLeft(2, '0')}m';
  }

  // Pace (min per km/mi)
  String get paceUnit => imperial ? '/MI' : '/KM';
  String pace(double mps) {
    if (mps < 0.3 || mps.isNaN) return '--:--';
    final secPer = (imperial ? _mPerMi : 1000) / mps;
    if (secPer > 5999) return '--:--';
    final m = secPer ~/ 60, s = (secPer % 60).round();
    return s == 60 ? '${m + 1}:00' : '$m:${s.toString().padLeft(2, '0')}';
  }

  // Speed
  String get speedUnit => imperial ? 'MPH' : 'KM/J';
  double speedValue(double mps) => imperial ? mps * 2.236936 : mps * 3.6;
  String speed(double mps, {int decimals = 1}) =>
      speedValue(mps).toStringAsFixed(decimals);

  // Elevation
  String get eleUnit => imperial ? 'FT' : 'M';
  double eleValue(double m) => imperial ? m * _ftPerM : m;
  String elevation(double m) => _group(eleValue(m).round().toString());

  /// Pace for runs/walks, speed for rides.
  (String value, String unit) speedOrPace(double mps, SportType sport) =>
      sport.isCycling ? (speed(mps), speedUnit) : (pace(mps), paceUnit);

  static String _group(String s) {
    final neg = s.startsWith('-');
    if (neg) s = s.substring(1);
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    // Indonesian style: thousands '.', decimals ','.
    final res = parts.length > 1 ? '$buf,${parts[1]}' : buf.toString();
    return neg ? '-$res' : res;
  }

  static String number(num v, {int decimals = 0}) =>
      _group(v.toStringAsFixed(decimals));

  // Dates (Indonesian, no intl init needed)
  static const monthsShort = [
    'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN',
    'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'
  ];
  static const monthsLong = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  static const daysShort = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
  static const daysLong = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  static String time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// "SAB 01 NOV 2026 · 06:00"
  static String dateStamp(DateTime d, {bool withTime = true}) {
    final base =
        '${daysShort[d.weekday - 1]} ${d.day.toString().padLeft(2, '0')} ${monthsShort[d.month - 1]} ${d.year}';
    return withTime ? '$base · ${time(d)}' : base;
  }

  static String monthYear(DateTime d) =>
      '${monthsLong[d.month - 1].toUpperCase()} ${d.year}';
}
