import 'package:drift/drift.dart';

/// v2: user-defined segments for live segment matching & ghost pacer.
class Segments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sportType => text().nullable()(); // null = any sport

  /// JSON array of [lat, lon] pairs, simplified (~every 10-20 m).
  TextColumn get polylineJson => text()();
  RealColumn get distanceM => real()();
  RealColumn get startLat => real()();
  RealColumn get startLon => real()();
  RealColumn get endLat => real()();
  RealColumn get endLon => real()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SegmentEfforts extends Table {
  TextColumn get id => text()();
  TextColumn get segmentId =>
      text().references(Segments, #id, onDelete: KeyAction.cascade)();
  TextColumn get activityId => text()();
  IntColumn get elapsedS => integer()();
  DateTimeColumn get startedAt => dateTime()();

  /// JSON array of seconds-since-segment-start at each 50 m (ghost replay).
  TextColumn get progressJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// v2: simple key/value app settings (units, TTS, auto-pause, theme...).
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
