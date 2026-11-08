import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/current_day.dart';
import 'package:virya/features/today/data/today_providers.dart';
import 'package:virya/features/today/domain/today_math.dart';
import 'package:virya/features/today/domain/today_models.dart';

/// Jam untuk layar Hari Ini. Bisa di-override di test.
final todayClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Ringkasan Hari Ini, dihitung ulang saat aktivitas berubah atau hari berganti.
final todaySummaryProvider = Provider<AsyncValue<TodaySummary>>((ref) {
  ref.watch(currentDayProvider); // hitung ulang saat hari berganti
  final now = ref.watch(todayClockProvider)();
  return ref
      .watch(todayActivitiesProvider)
      .whenData((list) => buildTodaySummary(list, now));
});
