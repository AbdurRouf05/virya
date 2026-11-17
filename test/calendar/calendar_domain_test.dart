import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/calendar/domain/calendar_cell.dart';
import 'package:virya/features/calendar/domain/calendar_day.dart';
import 'package:virya/features/calendar/domain/calendar_stats.dart';

const _cyc = SportCategory.cycling;
const _run = SportCategory.running;
const _walk = SportCategory.walking;
const _gym = SportCategory.strength;

var _n = 0;
CalendarEntry e(DateTime start, SportCategory c, {int sec = 3600}) =>
    CalendarEntry(
      id: 'a${_n++}',
      title: 't',
      sportName: c.name,
      category: c,
      start: start,
      durationSeconds: sec,
    );

Map<DateTime, CalendarDay> daysOf(List<CalendarEntry> list) =>
    bucketByDay(list);

void main() {
  group('bucketByDay', () {
    test('groups by local calendar day and sorts entries', () {
      final days = daysOf([
        e(DateTime(2026, 3, 1, 18), _run),
        e(DateTime(2026, 3, 1, 6), _cyc),
        e(DateTime(2026, 3, 2, 0, 5), _walk),
        e(DateTime(2026, 3, 1, 23, 59), _gym),
      ]);
      expect(days.keys.toSet(), {DateTime(2026, 3, 1), DateTime(2026, 3, 2)});
      final d1 = days[DateTime(2026, 3, 1)]!;
      expect(d1.entries.map((x) => x.category), [_cyc, _run, _gym]);
      expect(d1.categories(), [_cyc, _run, _gym]);
      expect(d1.categories(_run), [_run]);
    });

    test('UTC instants are bucketed by their local date', () {
      final utc = DateTime.utc(2026, 6, 30, 23, 30);
      final days = daysOf([e(utc, _cyc)]);
      final local = utc.toLocal();
      expect(days.keys.single, DateTime(local.year, local.month, local.day));
      expect(dayOf(utc), DateTime(local.year, local.month, local.day));
    });

    test('seconds and isActive honour the filter', () {
      final d = daysOf([
        e(DateTime(2026, 1, 5, 7), _cyc, sec: 1000),
        e(DateTime(2026, 1, 5, 9), _gym, sec: 500),
      ]).values.single;
      expect(d.seconds(), 1500);
      expect(d.seconds(_gym), 500);
      expect(d.isActive(_run), isFalse);
      expect(d.isActive(_gym), isTrue);
    });
  });

  group('cellParts', () {
    CalendarDay day(List<(SportCategory, int)> spec) => daysOf([
      for (final (c, s) in spec) e(DateTime(2026, 2, 2, 8), c, sec: s),
    ]).values.single;

    test('one and two categories', () {
      expect(cellParts(day([(_walk, 10)])), [_walk]);
      expect(cellParts(day([(_gym, 10), (_cyc, 10)])), [_cyc, _gym]);
    });

    test('three categories → quadrants, fourth = dominant', () {
      final d = day([(_cyc, 100), (_run, 900), (_gym, 50)]);
      expect(cellParts(d), [_cyc, _run, _gym, _run]);
    });

    test('four categories → quadrants as is', () {
      final d = day([(_cyc, 1), (_run, 1), (_walk, 1), (_gym, 1)]);
      expect(cellParts(d), [_cyc, _run, _walk, _gym]);
    });

    test('filter narrows to one', () {
      final d = day([(_cyc, 1), (_run, 1), (_walk, 1)]);
      expect(cellParts(d, _walk), [_walk]);
    });
  });

  group('intensity', () {
    test('scales between floor and 1', () {
      expect(intensity(3600, 3600), 1);
      expect(intensity(0, 3600), closeTo(0.35, 1e-9));
      expect(intensity(1800, 3600), closeTo(0.675, 1e-9));
      expect(intensity(9999, 3600), 1);
      expect(intensity(10, 0), 1);
    });
  });

  group('streaks', () {
    final today = DateTime(2026, 11, 8);
    List<CalendarEntry> run(DateTime from, int n, SportCategory c) => [
      for (var i = 0; i < n; i++)
        e(DateTime(from.year, from.month, from.day + i, 7), c),
    ];

    test('current streak includes today', () {
      final days = daysOf(run(DateTime(2026, 11, 4), 5, _cyc));
      expect(streakEndingToday(days, today), 5);
    });

    test('streak survives when today is still empty', () {
      final days = daysOf(run(DateTime(2026, 11, 4), 4, _cyc));
      expect(streakEndingToday(days, today), 4);
    });

    test('streak broken when yesterday is empty', () {
      final days = daysOf(run(DateTime(2026, 11, 1), 3, _cyc));
      expect(streakEndingToday(days, today), 0);
    });

    test('filter changes streak', () {
      final days = daysOf([
        ...run(DateTime(2026, 11, 5), 4, _cyc),
        e(DateTime(2026, 11, 7, 9), _gym),
        e(DateTime(2026, 11, 8, 9), _gym),
      ]);
      expect(streakEndingToday(days, today), 4);
      expect(streakEndingToday(days, today, filter: _gym), 2);
      expect(streakEndingToday(days, today, filter: _run), 0);
    });

    test('longest streak across month/year boundaries', () {
      final days = daysOf([
        ...run(DateTime(2025, 12, 29), 6, _run), // 29 Dec → 3 Jan
        ...run(DateTime(2026, 2, 27), 3, _cyc), // 27 Feb → 1 Mar
        ...run(DateTime(2026, 5, 1), 2, _cyc),
      ]);
      expect(longestStreakOf(days), 6);
      expect(longestStreakOf(days, filter: _cyc), 3);
      expect(longestStreakOf(days, filter: _gym), 0);
    });

    test('several activities on one day count once', () {
      final days = daysOf([
        e(DateTime(2026, 11, 7, 6), _cyc),
        e(DateTime(2026, 11, 7, 18), _run),
        e(DateTime(2026, 11, 8, 6), _walk),
      ]);
      expect(streakEndingToday(days, today), 2);
      expect(longestStreakOf(days), 2);
    });
  });

  group('CalendarStats.compute', () {
    test('active percent from 1 Jan to today', () {
      final days = daysOf([
        e(DateTime(2026, 1, 1, 7), _cyc),
        e(DateTime(2026, 1, 3, 7), _run),
        e(DateTime(2026, 1, 10, 7), _cyc), // tomorrow: not counted
        e(DateTime(2025, 12, 31, 7), _cyc), // last year: not counted
      ]);
      final s = CalendarStats.compute(days, DateTime(2026, 1, 4, 15));
      expect(s.elapsedDaysThisYear, 4);
      expect(s.activeDaysThisYear, 2);
      expect(s.activePercent, 50);
      expect(s.activeToday, isFalse);
      expect(s.currentStreak, 1);
      final c = CalendarStats.compute(days, DateTime(2026, 1, 4), filter: _cyc);
      expect(c.activeDaysThisYear, 1);
      expect(c.activePercent, 25);
      expect(c.currentStreak, 0);
    });

    test('empty data', () {
      final s = CalendarStats.compute(const {}, DateTime(2026, 11, 8));
      expect(s.currentStreak, 0);
      expect(s.longestStreak, 0);
      expect(s.activePercent, 0);
      expect(s.elapsedDaysThisYear, 312);
    });
  });

  group('cellLook', () {
    final today = DateTime(2026, 11, 8);
    final days = daysOf([
      e(DateTime(2026, 11, 3, 7), _gym, sec: 1800),
      e(DateTime(2026, 11, 3, 15), _cyc, sec: 1800),
    ]);
    CellLook look(DateTime d, {SportCategory? f, bool inRange = true}) =>
        cellLook(
          d,
          days: days,
          today: today,
          maxSeconds: 3600,
          filter: f,
          inRange: inRange,
        );

    test('active day with split and intensity', () {
      final l = look(DateTime(2026, 11, 3));
      expect(l.kind, CellKind.active);
      expect(l.parts, [_cyc, _gym]);
      expect(l.alpha, 1);
      expect(look(DateTime(2026, 11, 3), f: _gym).parts, [_gym]);
      expect(look(DateTime(2026, 11, 3), f: _run).kind, CellKind.rest);
    });

    test('rest, today, future, outside', () {
      expect(look(DateTime(2026, 11, 4)).kind, CellKind.rest);
      final t = look(today);
      expect(t.kind, CellKind.rest);
      expect(t.isToday, isTrue);
      expect(look(DateTime(2026, 11, 9)).kind, CellKind.future);
      expect(look(today, inRange: false).kind, CellKind.outside);
    });
  });
}
