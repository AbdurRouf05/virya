import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/analytics/activity_analyzer.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/features/activity_history/data/journal_providers.dart';
import 'package:virya/features/dashboard/domain/stats_math.dart';

/// Fitness timeline (last 90 days) from activities' relative effort.
final fitnessTimelineProvider = Provider<List<FitnessDay>>((ref) {
  final list = ref.watch(completedActivitiesProvider).valueOrNull ?? const [];
  if (list.isEmpty) return const [];
  final today = dayKey(DateTime.now());
  final load = Map<DateTime, double>.of(
    dailySum(list, (a) => a.relativeEffort),
  );
  if (load.isEmpty) return const [];
  final first = load.keys.reduce((a, b) => a.isBefore(b) ? a : b);
  load.putIfAbsent(dayKey(first.subtract(const Duration(days: 7))), () => 0);
  final all = const ActivityAnalyzer().fitnessTimeline(load, until: today);
  final from = today.subtract(const Duration(days: 89));
  return all.where((d) => !d.day.isBefore(from)).toList();
});
