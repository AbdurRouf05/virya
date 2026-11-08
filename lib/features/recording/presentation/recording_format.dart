/// Display formatting for the live recording screen (metric / imperial).
class RecFormat {
  final bool imperial;
  const RecFormat({this.imperial = false});

  static const double _mile = 1609.344;

  String get distanceUnit => imperial ? 'MI' : 'KM';
  String get speedUnit => imperial ? 'MI/J' : 'KM/J';
  String get paceUnit => imperial ? '/MI' : '/KM';
  String get elevationUnit => imperial ? 'FT' : 'M';

  String distance(double meters) {
    final v = imperial ? meters / _mile : meters / 1000;
    return v.toStringAsFixed(v >= 100 ? 1 : 2);
  }

  String speed(double kmh) {
    final v = imperial ? kmh / 1.609344 : kmh;
    return v.toStringAsFixed(1);
  }

  /// Pace "m:ss" per km/mile from km/h; "--:--" when (almost) stopped.
  String pace(double kmh) {
    if (kmh < 1.0) return '--:--';
    final secPerKm = 3600 / kmh;
    final s = (imperial ? secPerKm * 1.609344 : secPerKm).round();
    if (s >= 3600) return '--:--';
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  String elevation(double meters) =>
      (imperial ? meters * 3.28084 : meters).round().toString();

  static String duration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  static String grade(double pct) {
    final v = pct.abs() < 0.5 ? 0.0 : pct;
    return '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)}';
  }
}
