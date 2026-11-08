import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/core/database/app_database.dart';

/// All completed activities, newest first.
final completedActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  return ref.watch(databaseProvider).activitiesDao.watchCompletedActivities();
});

/// Down-sampled (~90 pts) lat/lon for list thumbnails. Cached per id for the
/// app lifetime (family providers are kept alive).
final routeThumbProvider =
    FutureProvider.family<List<(double, double)>, String>((ref, id) async {
  final db = ref.watch(databaseProvider);
  final count = await db.trackPointsDao.countPointsForActivity(id);
  if (count == 0) return const [];
  final step = (count / 90).ceil().clamp(1, 1 << 20);
  final rows = await db.customSelect(
    'SELECT latitude, longitude FROM track_points '
    'WHERE activity_id = ? AND (sequence_idx % ?) = 0 '
    'ORDER BY sequence_idx',
    variables: [Variable.withString(id), Variable.withInt(step)],
    readsFrom: {db.trackPoints},
  ).get();
  return [
    for (final r in rows)
      (r.read<double>('latitude'), r.read<double>('longitude')),
  ];
});
