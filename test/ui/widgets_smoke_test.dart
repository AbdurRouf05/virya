import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stravo/app/format.dart';
import 'package:stravo/app/theme/app_theme.dart';
import 'package:stravo/core/analytics/analysis_models.dart';
import 'package:stravo/core/data/demo_data.dart';
import 'package:stravo/core/widgets/field_kit.dart';

Widget _host(Widget child) => MaterialApp(
      theme: FieldNotesTheme.paper,
      home: Scaffold(
          body: SingleChildScrollView(
              child: Padding(padding: const EdgeInsets.all(16), child: child))),
    );

double _hav(double la1, double lo1, double la2, double lo2) {
  const r = 6371000.0;
  final dLa = (la2 - la1) * math.pi / 180, dLo = (lo2 - lo1) * math.pi / 180;
  final a = math.pow(math.sin(dLa / 2), 2) +
      math.cos(la1 * math.pi / 180) *
          math.cos(la2 * math.pi / 180) *
          math.pow(math.sin(dLo / 2), 2);
  return 2 * r * math.asin(math.sqrt(a));
}

void main() {
  // Series built from the demo ride directly (independent of the analyzer).
  final ride = demoGravelRide(seconds: 1800);
  final dist = <double>[0];
  for (var i = 1; i < ride.length; i++) {
    dist.add(dist.last +
        _hav(ride[i - 1].lat, ride[i - 1].lon, ride[i].lat, ride[i].lon));
  }
  final ele = [for (final s in ride) s.ele ?? 0.0];
  final grade = [
    for (var i = 0; i < ride.length; i++)
      i == 0 || dist[i] == dist[i - 1]
          ? 0.0
          : (ele[i] - ele[i - 1]) / (dist[i] - dist[i - 1]) * 100
  ];
  final speed = [for (final s in ride) s.speedMps];
  const fmt = Fmt(Units.metric);

  testWidgets('StatBlock renders label, value & unit', (tester) async {
    await tester.pumpWidget(_host(const StatBlock(
        label: 'Jarak', value: '42,2', unit: 'km')));
    expect(find.text('42,2'), findsOneWidget);
    expect(find.textContaining('JARAK'), findsOneWidget);
  });

  testWidgets('Charts render demo series without errors', (tester) async {
    final today = DateTime(2026, 11, 7);
    final days = [
      for (var i = 0; i < 90; i++)
        FitnessDay(
          day: today.subtract(Duration(days: 89 - i)),
          load: i % 3 == 0 ? 80 : 0,
          fitness: 30 + i * 0.3,
          fatigue: 35 + 10 * math.sin(i / 5),
        ),
    ];
    await tester.pumpWidget(_host(Column(children: [
      ElevationProfile(
        distanceM: dist,
        ele: ele,
        gradePct: grade,
        marks: [ChartMark(dist.last * 0.2, dist.last * 0.4, 'T1')],
        formatX: (m) => fmt.distance(m),
        formatY: (m) => fmt.elevation(m),
      ),
      InkLineChart(
        x: dist,
        y: speed,
        formatX: (m) => fmt.distance(m),
        formatY: (v) => fmt.speed(v),
      ),
      FitnessChart(days: days),
      CalendarHeatStrip(
        dailyValue: {today: 42000, today.subtract(const Duration(days: 3)): 12000},
        endDay: today,
      ),
    ])));
    expect(tester.takeException(), isNull);
    expect(find.byType(FitnessChart), findsOneWidget);
    expect(formStatus(days.last.form).title, isNotEmpty);
  });

  test('Fmt respects units', () {
    expect(const Fmt(Units.metric).distUnit, 'KM');
    expect(const Fmt(Units.imperial).distUnit, isNot('KM'));
    expect(Fmt.duration(3725), '1:02:05');
  });
}
