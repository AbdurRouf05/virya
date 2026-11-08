import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/database/app_database.dart';

enum StatsPeriod {
  week('MINGGU INI'),
  month('BULAN INI'),
  year('TAHUN INI');

  final String label;
  const StatsPeriod(this.label);

  DateTime start(DateTime now) => switch (this) {
        StatsPeriod.week => DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1)),
        StatsPeriod.month => DateTime(now.year, now.month),
        StatsPeriod.year => DateTime(now.year),
      };
}

class Totals {
  final int count;
  final double distanceM;
  final int movingS;
  final double elevationM;
  const Totals(this.count, this.distanceM, this.movingS, this.elevationM);
  static const zero = Totals(0, 0, 0, 0);
  Totals add(Activity a) => Totals(
        count + 1,
        distanceM + a.totalDistanceMeters,
        movingS + a.movingTimeSeconds,
        elevationM + a.elevationGainMeters,
      );
}

DateTime dayKey(DateTime t) => DateTime(t.year, t.month, t.day);

Map<SportGroup, Totals> totalsByGroup(List<Activity> list, DateTime from) {
  final out = <SportGroup, Totals>{};
  for (final a in list) {
    if (a.startTime.isBefore(from)) continue;
    final g = sportFromName(a.sportType).group;
    out[g] = (out[g] ?? Totals.zero).add(a);
  }
  return out;
}

Map<DateTime, double> dailySum(
    List<Activity> list, double Function(Activity) value) {
  final out = <DateTime, double>{};
  for (final a in list) {
    final k = dayKey(a.startTime);
    out[k] = (out[k] ?? 0) + value(a);
  }
  return out;
}

class PersonalRecord {
  final String title;
  final String value;
  final String unit;
  final Activity activity;
  const PersonalRecord(this.title, this.value, this.unit, this.activity);
}

/// Pick the activity maximising [key] among [list] (null if none > 0).
Activity? best(Iterable<Activity> list, double Function(Activity) key) {
  Activity? top;
  for (final a in list) {
    if (key(a) <= 0) continue;
    if (top == null || key(a) > key(top)) top = a;
  }
  return top;
}
