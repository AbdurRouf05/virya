import 'package:virya/core/database/app_database.dart';

/// The paired heart-rate sensor.
class HrSensorRef {
  final String id;
  final String name;
  const HrSensorRef({required this.id, required this.name});
}

abstract class HrSensorStore {
  Future<HrSensorRef?> load();
  Future<void> save(HrSensorRef sensor);
  Future<void> clear();
}

/// Keeps the paired sensor in the AppSettings table.
class DbHrSensorStore implements HrSensorStore {
  static const keyId = 'hr_sensor_id';
  static const keyName = 'hr_sensor_name';

  final AppDatabase db;
  const DbHrSensorStore(this.db);

  @override
  Future<HrSensorRef?> load() async {
    final id = await db.getSetting(keyId);
    if (id == null || id.isEmpty) return null;
    return HrSensorRef(id: id, name: await db.getSetting(keyName) ?? '');
  }

  @override
  Future<void> save(HrSensorRef sensor) async {
    await db.setSetting(keyId, sensor.id);
    await db.setSetting(keyName, sensor.name);
  }

  @override
  Future<void> clear() async {
    await db.setSetting(keyId, '');
    await db.setSetting(keyName, '');
  }
}
