import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/core/database/app_database.dart';

/// Every gear incl. retired, default first.
final allGearsProvider = StreamProvider<List<Gear>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.gears)
        ..orderBy([
          (t) => OrderingTerm.asc(t.isRetired),
          (t) => OrderingTerm.desc(t.isDefault),
          (t) => OrderingTerm.asc(t.createdAt),
        ]))
      .watch();
});

/// Distance per gear computed from completed activities (robust against
/// repeated finalize calls that bump the gear odometer column).
final gearDistanceProvider = StreamProvider<Map<String, double>>((ref) {
  final db = ref.watch(databaseProvider);
  final sum = db.activities.totalDistanceMeters.sum();
  final q = db.selectOnly(db.activities)
    ..addColumns([db.activities.gearId, sum])
    ..where(db.activities.status.equals('completed') &
        db.activities.gearId.isNotNull())
    ..groupBy([db.activities.gearId]);
  return q.watch().map((rows) => {
        for (final r in rows)
          r.read(db.activities.gearId)!: r.read(sum) ?? 0,
      });
});

const gearTypes = {
  'gravelBike': 'SEPEDA GRAVEL',
  'roadBike': 'SEPEDA JALAN',
  'mtb': 'MTB',
  'runningShoes': 'SEPATU LARI',
  'trailShoes': 'SEPATU TRAIL',
};

bool gearIsShoe(String type) => type.toLowerCase().contains('shoe');
