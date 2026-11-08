import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/today/domain/today_math.dart';
import 'package:virya/features/today/domain/today_models.dart';

TodayActivity _act(String id, DateTime start, SportType sport) => TodayActivity(
  id: id,
  title: 'Aktivitas $id',
  sport: sport,
  start: start,
  distanceMeters: 1000,
  movingSeconds: 600,
);

void main() {
  // Minggu, 8 Nov 2026, 09:41 lokal.
  final now = DateTime(2026, 11, 8, 9, 41);

  group('localDay / weekStart / isoWeekNumber', () {
    test('localDay drops time and converts UTC to local', () {
      final utc = DateTime(2026, 11, 8, 23, 30).toUtc();
      expect(localDay(utc), DateTime(2026, 11, 8));
    });

    test('weekStart is Monday', () {
      expect(weekStart(now), DateTime(2026, 11, 2));
      expect(weekStart(DateTime(2026, 11, 2, 0, 1)), DateTime(2026, 11, 2));
    });

    test('ISO week numbers', () {
      expect(isoWeekNumber(now), 45);
      expect(isoWeekNumber(DateTime(2026, 1, 1)), 1);
      expect(isoWeekNumber(DateTime(2027, 1, 1)), 53);
      expect(isoWeekNumber(DateTime(2024, 12, 30)), 1);
    });
  });

  group('currentStreak', () {
    Set<DateTime> days(List<int> d) => {
      for (final x in d) DateTime(2026, 11, x),
    };

    test('counts back from today', () {
      expect(currentStreak(days([6, 7, 8]), now), 3);
    });

    test('today not done yet keeps streak up to yesterday', () {
      expect(currentStreak(days([5, 6, 7]), now), 3);
    });

    test('gap breaks streak', () {
      expect(currentStreak(days([4, 5, 7, 8]), now), 2);
      expect(currentStreak(days([5, 6]), now), 0);
      expect(currentStreak({}, now), 0);
    });

    test('crosses month boundary', () {
      final s = {
        DateTime(2026, 10, 31),
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 2),
      };
      expect(currentStreak(s, DateTime(2026, 11, 2, 20)), 3);
    });
  });

  group('weekStrip', () {
    test('Mon..Sun with categories, today and future flags', () {
      final byDay = categoriesByDay([
        _act('a', DateTime(2026, 11, 3, 7), SportType.roadRunning),
        _act('b', DateTime(2026, 11, 3, 18), SportType.gravelCycling),
        _act('c', DateTime(2026, 11, 5, 7), SportType.hiking),
      ]);
      final w = weekStrip(byDay, DateTime(2026, 11, 5, 12));
      expect(w.length, 7);
      expect(w.first.date, DateTime(2026, 11, 2));
      expect(w.last.date, DateTime(2026, 11, 8));
      expect(w[1].categories, [SportCategory.cycling, SportCategory.running]);
      expect(w[3].categories, [SportCategory.walking]);
      expect(w[3].isToday, isTrue);
      expect(w[4].isFuture, isTrue);
      expect(w[0].active, isFalse);
    });
  });

  group('buildTodaySummary', () {
    test('today list, last and streak', () {
      final list = [
        _act('old', DateTime(2026, 11, 6, 7), SportType.walking),
        _act('y', DateTime(2026, 11, 7, 7), SportType.roadCycling),
        _act('t1', DateTime(2026, 11, 8, 6), SportType.roadRunning),
        _act('t2', DateTime(2026, 11, 8, 8), SportType.roadRunning),
      ];
      final s = buildTodaySummary(list, now);
      expect(s.doneToday, isTrue);
      expect(s.today.map((a) => a.id), ['t2', 't1']);
      expect(s.last?.id, 't2');
      expect(s.streakDays, 3);
      expect(s.activeDaysThisWeek, 3);
      expect(s.todayDistance, 2000);
      expect(s.todayMovingSeconds, 1200);
    });

    test('empty list', () {
      final s = buildTodaySummary(const [], now);
      expect(s.doneToday, isFalse);
      expect(s.last, isNull);
      expect(s.streakDays, 0);
      expect(s.week.where((d) => d.active), isEmpty);
    });
  });

  test('greetingPart', () {
    expect(greetingPart(DateTime(2026, 11, 8, 6)), 'PAGI');
    expect(greetingPart(DateTime(2026, 11, 8, 12)), 'SIANG');
    expect(greetingPart(DateTime(2026, 11, 8, 16)), 'SORE');
    expect(greetingPart(DateTime(2026, 11, 8, 21)), 'MALAM');
    expect(greetingPart(DateTime(2026, 11, 8, 2)), 'MALAM');
  });
}
