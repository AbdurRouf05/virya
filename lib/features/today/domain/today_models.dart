import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/constants/sport_category.dart';

/// Ringkasan satu aktivitas selesai, cukup untuk layar Hari Ini.
class TodayActivity {
  final String id;
  final String title;
  final SportType sport;

  /// Waktu mulai (boleh UTC; selalu dibandingkan dalam waktu lokal).
  final DateTime start;
  final double distanceMeters;
  final int movingSeconds;

  const TodayActivity({
    required this.id,
    required this.title,
    required this.sport,
    required this.start,
    required this.distanceMeters,
    required this.movingSeconds,
  });

  SportCategory get category => categoryOf(sport);
}

/// Satu sel di strip "Minggu ini".
class WeekDayCell {
  /// Tanggal lokal (jam 00:00).
  final DateTime date;

  /// Kategori yang dilakukan hari itu, urut sesuai [SportCategory.index].
  final List<SportCategory> categories;
  final bool isToday;
  final bool isFuture;

  const WeekDayCell({
    required this.date,
    required this.categories,
    required this.isToday,
    required this.isFuture,
  });

  bool get active => categories.isNotEmpty;
}

/// Semua data yang dibutuhkan layar Hari Ini.
class TodaySummary {
  final DateTime now;

  /// Aktivitas hari ini, terbaru dulu.
  final List<TodayActivity> today;
  final int streakDays;
  final List<WeekDayCell> week;
  final TodayActivity? last;

  const TodaySummary({
    required this.now,
    required this.today,
    required this.streakDays,
    required this.week,
    required this.last,
  });

  bool get doneToday => today.isNotEmpty;
  int get activeDaysThisWeek => week.where((d) => d.active).length;
  double get todayDistance => today.fold(0, (s, a) => s + a.distanceMeters);
  int get todayMovingSeconds => today.fold(0, (s, a) => s + a.movingSeconds);
}
