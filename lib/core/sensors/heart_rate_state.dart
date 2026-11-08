import 'package:virya/core/sensors/ble_gateway.dart';
import 'package:virya/core/sensors/hr_sensor_store.dart';

enum HrLink { none, connecting, connected, reconnecting }

enum HrIssue {
  none,
  unsupported,
  permissionDenied,
  permissionBlocked,
  adapterOff,
  notHeartRate,
  scanFailed,
}

class HeartRateState {
  final HrSensorRef? sensor;
  final HrLink link;
  final HrIssue issue;

  /// Latest usable pulse; null when off the skin, stale or disconnected.
  final int? bpm;
  final bool contactLost;
  final bool scanning;
  final List<BleFoundDevice> found;

  const HeartRateState({
    this.sensor,
    this.link = HrLink.none,
    this.issue = HrIssue.none,
    this.bpm,
    this.contactLost = false,
    this.scanning = false,
    this.found = const [],
  });

  HeartRateState copyWith({
    HrSensorRef? sensor,
    HrLink? link,
    HrIssue? issue,
    int? bpm,
    bool clearBpm = false,
    bool? contactLost,
    bool? scanning,
    List<BleFoundDevice>? found,
  }) => HeartRateState(
    sensor: sensor ?? this.sensor,
    link: link ?? this.link,
    issue: issue ?? this.issue,
    bpm: clearBpm ? null : (bpm ?? this.bpm),
    contactLost: clearBpm ? false : (contactLost ?? this.contactLost),
    scanning: scanning ?? this.scanning,
    found: found ?? this.found,
  );
}
