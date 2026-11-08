import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';

/// The single local athlete profile (or null before first edit).
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.userProfiles)..limit(1)).watchSingleOrNull();
});
