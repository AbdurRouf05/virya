import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/calendar/data/calendar_providers.dart';
import 'package:virya/features/calendar/domain/calendar_grid.dart';

void main() {
  group('mondayOf', () {
    test('returns the Monday of the week', () {
      expect(mondayOf(DateTime(2026, 11, 8)), DateTime(2026, 11, 2)); // Sun
      expect(mondayOf(DateTime(2026, 11, 2)), DateTime(2026, 11, 2)); // Mon
      expect(mondayOf(DateTime(2026, 1, 1)), DateTime(2025, 12, 29)); // Thu
    });
  });

  group('YearGrid', () {
    test('2026 starts on the Monday before 1 Jan, 53 weeks', () {
      final g = YearGrid(2026);
      expect(g.start, DateTime(2025, 12, 29));
      expect(g.weeks, 53);
      expect(g.dateAt(0, 3), DateTime(2026, 1, 1));
      expect(g.contains(g.dateAt(0, 0)), isFalse);
      expect(g.weekOfMonthStart(1), 0);
      expect(g.weekOfMonthStart(2), 4); // 1 Feb 2026 is a Sunday
    });

    test('every day of the year has a cell', () {
      for (final y in [2024, 2026, 2028, 2033]) {
        final g = YearGrid(y);
        final seen = <DateTime>{};
        for (var w = 0; w < g.weeks; w++) {
          for (var d = 0; d < 7; d++) {
            final date = g.dateAt(w, d);
            expect(date.weekday, d + 1);
            if (g.contains(date)) seen.add(date);
          }
        }
        final leap = DateTime(y, 2, 29).month == 2;
        expect(seen.length, leap ? 366 : 365, reason: '$y');
        expect(g.weeks, inInclusiveRange(53, 54));
      }
    });

    test('54 weeks when a leap year starts on Sunday', () {
      // 2040 is leap, starts on Sunday and ends on Monday.
      expect(YearGrid(2040).weeks, 54);
    });
  });

  group('monthCells', () {
    test('November 2026 leads with Oct 26–31 and ends on 30 Nov', () {
      final cells = monthCells(2026, 11);
      expect(cells.first, DateTime(2026, 10, 26));
      expect(cells[6], DateTime(2026, 11, 1));
      expect(cells.last, DateTime(2026, 11, 30));
      expect(cells.length, 36);
    });

    test('month starting on Monday has no leading days', () {
      final cells = monthCells(2026, 6); // 1 Jun 2026 = Monday
      expect(cells.first, DateTime(2026, 6, 1));
      expect(cells.length, 30);
    });
  });

  group('categoryOfName', () {
    test('maps stored sport names', () {
      expect(categoryOfName('gravelCycling'), SportCategory.cycling);
      expect(categoryOfName('trailRunning'), SportCategory.running);
      expect(categoryOfName('hiking'), SportCategory.walking);
      expect(categoryOfName('strength'), SportCategory.strength);
    });
  });
}
