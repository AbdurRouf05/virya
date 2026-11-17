import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/constants/sport_category.dart';
import 'package:virya/features/calendar/data/calendar_providers.dart';
import 'package:virya/features/calendar/presentation/calendar_screen.dart';

void main() {
  testWidgets('renders header, filters, stats and selected day', (t) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 7);
    final days = bucketByDay([
      CalendarEntry(
        id: 'x1',
        title: 'Gravel pagi',
        sportName: 'gravelCycling',
        category: SportCategory.cycling,
        start: today,
        durationSeconds: 3600,
        distanceMeters: 30000,
      ),
    ]);
    await t.binding.setSurfaceSize(const Size(420, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          calendarDaysProvider.overrideWithValue(AsyncValue.data(days)),
        ],
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );
    await t.pump();
    expect(find.text('KALENDER'), findsOneWidget);
    expect(find.text('SEMUA'), findsOneWidget);
    expect(find.text('TERPANJANG'), findsOneWidget);
    expect(find.text('Gravel pagi'), findsOneWidget);
    expect(find.text('1 AKTIVITAS'), findsOneWidget);

    await t.tap(find.text('LARI').first);
    await t.pump();
    expect(find.text('Gravel pagi'), findsNothing);

    await t.tap(find.text('TAHUN'));
    await t.pump();
    expect(find.text('${now.year}'), findsOneWidget);
  });
}
