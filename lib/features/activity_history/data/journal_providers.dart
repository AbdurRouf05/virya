import 'dart:async';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';

/// All completed activities, newest first.
final completedActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  return ref.watch(databaseProvider).activitiesDao.watchCompletedActivities();
});

/// Down-sampled (~90 pts) lat/lon for list thumbnails. Cached with autoDispose
/// (kept alive for 3 minutes) so memory stays lean during heavy journal browsing.
final routeThumbProvider =
    FutureProvider.autoDispose.family<List<(double, double)>, String>((ref, id) async {
      final link = ref.keepAlive();
      final timer = Timer(const Duration(minutes: 3), link.close);
      ref.onDispose(timer.cancel);

      final db = ref.watch(databaseProvider);
      final count = await db.trackPointsDao.countPointsForActivity(id);
      if (count == 0) return const [];
      final step = (count / 90).ceil().clamp(1, 1 << 20);
      final rows = await db
          .customSelect(
            'SELECT latitude, longitude FROM track_points '
            'WHERE activity_id = ? AND (sequence_idx % ?) = 0 '
            'ORDER BY sequence_idx',
            variables: [Variable.withString(id), Variable.withInt(step)],
            readsFrom: {db.trackPoints},
          )
          .get();
      return [
        for (final r in rows)
          (r.read<double>('latitude'), r.read<double>('longitude')),
      ];
    });
