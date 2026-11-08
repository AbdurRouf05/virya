import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/today/domain/today_models.dart';

/// Tanggal lokal (00:00) dari sebuah waktu, UTC maupun lokal.
DateTime localDay(DateTime t) {
  final l = t.toLocal();
  return DateTime(l.year, l.month, l.day);
}

/// Senin (00:00 lokal) dari minggu yang memuat [t].
DateTime weekStart(DateTime t) {
  final d = localDay(t);
  return DateTime(d.year, d.month, d.day - (d.weekday - 1));
}

/// Nomor minggu ISO-8601 (1..53).
int isoWeekNumber(DateTime t) {
  final d = localDay(t);
  // Kamis di minggu yang sama menentukan tahun ISO.
  final thursday = DateTime(d.year, d.month, d.day + (4 - d.weekday));
  final jan1 = DateTime(thursday.year);
  final dayOfYear = DateTime.utc(
    thursday.year,
    thursday.month,
    thursday.day,
  ).difference(DateTime.utc(jan1.year)).inDays;
  return dayOfYear ~/ 7 + 1;
}

/// Kategori per hari lokal.
Map<DateTime, Set<SportCategory>> categoriesByDay(
  Iterable<TodayActivity> list,
) {
  final out = <DateTime, Set<SportCategory>>{};
  for (final a in list) {
    (out[localDay(a.start)] ??= <SportCategory>{}).add(a.category);
  }
  return out;
}

/// Hari berturut-turut yang berisi aktivitas, berakhir hari ini.
/// Bila hari ini belum ada aktivitas, streak dihitung sampai kemarin
/// (streak belum putus sebelum hari berakhir).
int currentStreak(Set<DateTime> activeDays, DateTime now) {
  var d = localDay(now);
  if (!activeDays.contains(d)) d = DateTime(d.year, d.month, d.day - 1);
  var n = 0;
  while (activeDays.contains(d)) {
    n++;
    d = DateTime(d.year, d.month, d.day - 1);
  }
  return n;
}

/// Tujuh sel Senin–Minggu untuk minggu yang memuat [now].
List<WeekDayCell> weekStrip(
  Map<DateTime, Set<SportCategory>> byDay,
  DateTime now,
) {
  final today = localDay(now);
  final mon = weekStart(now);
  return [
    for (var i = 0; i < 7; i++)
      () {
        final date = DateTime(mon.year, mon.month, mon.day + i);
        final cats = (byDay[date] ?? const <SportCategory>{}).toList()
          ..sort((a, b) => a.index.compareTo(b.index));
        return WeekDayCell(
          date: date,
          categories: cats,
          isToday: date == today,
          isFuture: date.isAfter(today),
        );
      }(),
  ];
}

/// Rangkuman lengkap untuk layar Hari Ini.
TodaySummary buildTodaySummary(List<TodayActivity> list, DateTime now) {
  final sorted = [...list]..sort((a, b) => b.start.compareTo(a.start));
  final today = localDay(now);
  final byDay = categoriesByDay(sorted);
  return TodaySummary(
    now: now,
    today: [
      for (final a in sorted)
        if (localDay(a.start) == today) a,
    ],
    streakDays: currentStreak(byDay.keys.toSet(), now),
    week: weekStrip(byDay, now),
    last: sorted.isEmpty ? null : sorted.first,
  );
}

/// "PAGI" / "SIANG" / "SORE" / "MALAM" menurut jam lokal.
String greetingPart(DateTime now) {
  final h = now.toLocal().hour;
  if (h >= 4 && h < 11) return 'PAGI';
  if (h >= 11 && h < 15) return 'SIANG';
  if (h >= 15 && h < 18) return 'SORE';
  return 'MALAM';
}
