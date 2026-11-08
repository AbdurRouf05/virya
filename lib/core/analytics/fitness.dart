import 'dart:math' as math;

import 'package:virya/core/analytics/analysis_models.dart';

/// Daily CTL/ATL as exponentially weighted moving averages of load:
///   CTL_d = CTL_{d−1} + (load_d − CTL_{d−1})·(1 − e^(−1/42))
///   ATL_d = ATL_{d−1} + (load_d − ATL_{d−1})·(1 − e^(−1/7))
/// starting at 0 before the first day with a load; missing days load 0.
List<FitnessDay> computeFitnessTimeline(Map<DateTime, double> dailyLoad,
    {DateTime? until}) {
  if (dailyLoad.isEmpty) return const [];
  DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
  final loads = <DateTime, double>{};
  dailyLoad.forEach((d, v) {
    final k = day(d);
    loads[k] = (loads[k] ?? 0) + v;
  });
  final first = loads.keys.reduce((a, b) => a.isBefore(b) ? a : b);
  final last = day(until ?? DateTime.now());
  if (last.isBefore(first)) return const [];
  final kc = 1 - math.exp(-1 / 42), ka = 1 - math.exp(-1 / 7);
  var ctl = 0.0, atl = 0.0;
  final out = <FitnessDay>[];
  for (var d = first;
      !d.isAfter(last);
      d = DateTime(d.year, d.month, d.day + 1)) {
    final load = loads[d] ?? 0;
    ctl += (load - ctl) * kc;
    atl += (load - atl) * ka;
    out.add(FitnessDay(day: d, load: load, fitness: ctl, fatigue: atl));
  }
  return out;
}
