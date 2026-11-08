import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/activity_history/data/journal_providers.dart';

class TodayTask {
  final String id;
  final String title;
  final bool isDone;
  const TodayTask({required this.id, required this.title, this.isDone = false});

  TodayTask copyWith({String? title, bool? isDone}) => TodayTask(
        id: id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'isDone': isDone};
  factory TodayTask.fromJson(Map<String, dynamic> json) => TodayTask(
        id: json['id'] as String,
        title: json['title'] as String,
        isDone: (json['isDone'] as bool?) ?? false,
      );
}

/// Activities recorded today (local calendar day).
final todayActivitiesProvider = Provider<List<Activity>>((ref) {
  final list = ref.watch(completedActivitiesProvider).valueOrNull ?? const [];
  if (list.isEmpty) return const [];
  final now = DateTime.now();
  final todayMidnight = DateTime(now.year, now.month, now.day);
  final tomorrowMidnight = todayMidnight.add(const Duration(days: 1));
  return list.where((a) {
    final t = a.startTime.toLocal();
    return !t.isBefore(todayMidnight) && t.isBefore(tomorrowMidnight);
  }).toList();
});

/// Current consecutive active training streak (days).
final currentStreakProvider = Provider<int>((ref) {
  final list = ref.watch(completedActivitiesProvider).valueOrNull ?? const [];
  if (list.isEmpty) return 0;
  final days = list
      .map((a) {
        final d = a.startTime.toLocal();
        return DateTime(d.year, d.month, d.day);
      })
      .toSet();

  final now = DateTime.now();
  var check = DateTime(now.year, now.month, now.day);
  // If not trained today yet, streak might still be intact from yesterday.
  if (!days.contains(check)) {
    check = check.subtract(const Duration(days: 1));
    if (!days.contains(check)) return 0;
  }

  var streak = 0;
  while (days.contains(check)) {
    streak++;
    check = check.subtract(const Duration(days: 1));
  }
  return streak;
});

class DayStatus {
  final DateTime date;
  final String dayName;
  final bool isToday;
  final bool hasActivity;
  final double distanceM;
  const DayStatus({
    required this.date,
    required this.dayName,
    required this.isToday,
    required this.hasActivity,
    required this.distanceM,
  });
}

/// The 7 days of the current week (Senin..Minggu) with activity status.
final currentWeekDaysProvider = Provider<List<DayStatus>>((ref) {
  final list = ref.watch(completedActivitiesProvider).valueOrNull ?? const [];
  final now = DateTime.now();
  final todayMidnight = DateTime(now.year, now.month, now.day);
  // Monday of the current week (weekday: 1 = Mon ... 7 = Sun)
  final monday = todayMidnight.subtract(Duration(days: todayMidnight.weekday - 1));

  const names = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
  final result = <DayStatus>[];

  for (var i = 0; i < 7; i++) {
    final d = monday.add(Duration(days: i));
    final next = d.add(const Duration(days: 1));
    final dayActs = list.where((a) {
      final t = a.startTime.toLocal();
      return !t.isBefore(d) && t.isBefore(next);
    });
    final hasAct = dayActs.isNotEmpty;
    final dist = dayActs.fold<double>(0, (sum, a) => sum + a.totalDistanceMeters);
    result.add(DayStatus(
      date: d,
      dayName: names[i],
      isToday: d == todayMidnight,
      hasActivity: hasAct,
      distanceM: dist,
    ));
  }
  return result;
});

/// Manage today's tasks persisted in AppSettings.
class TodayTasksNotifier extends StateNotifier<List<TodayTask>> {
  static const _key = 'today_tasks_json';
  final AppDatabase _db;

  TodayTasksNotifier(this._db) : super(const []) {
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await _db.getSetting(_key);
      if (raw == null || raw.isEmpty) {
        state = const [
          TodayTask(id: '1', title: 'Lakukan pemanasan & mobilitas 10 menit'),
          TodayTask(id: '2', title: 'Minum 2.5L air & cukupi elektrolit'),
        ];
        return;
      }
      final decoded = jsonDecode(raw) as List;
      state = [
        for (final item in decoded)
          TodayTask.fromJson(item as Map<String, dynamic>)
      ];
    } catch (_) {}
  }

  Future<void> addTask(String title) async {
    final t = title.trim();
    if (t.isEmpty) return;
    final newTask = TodayTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: t,
    );
    state = [...state, newTask];
    await _save();
  }

  Future<void> toggleTask(String id) async {
    state = [
      for (final task in state)
        if (task.id == id) task.copyWith(isDone: !task.isDone) else task
    ];
    await _save();
  }

  Future<void> deleteTask(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    try {
      final raw = jsonEncode(state.map((t) => t.toJson()).toList());
      await _db.setSetting(_key, raw);
    } catch (_) {}
  }
}

final todayTasksProvider =
    StateNotifierProvider<TodayTasksNotifier, List<TodayTask>>((ref) {
  final db = ref.watch(databaseProvider);
  return TodayTasksNotifier(db);
});

