import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/sensors/ble_gateway.dart';
import 'package:virya/core/sensors/heart_rate_manager.dart';
import 'package:virya/core/sensors/heart_rate_state.dart';
import 'package:virya/core/sensors/hr_sensor_store.dart';

import 'fake_ble.dart';

const _sensor = HrSensorRef(id: 'AA:BB', name: 'Tali dada');
const _found = BleFoundDevice(id: 'CC:DD', name: 'Pita', rssi: -50);

Future<void> _until(bool Function() ready) async {
  for (var i = 0; i < 200 && !ready(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(ready(), isTrue, reason: 'condition not reached in time');
}

void main() {
  late FakeGateway gateway;
  late FakeStore store;
  late HeartRateManager manager;

  HeartRateManager build() => HeartRateManager(
    gateway: gateway,
    store: store,
    retryDelays: const [Duration(milliseconds: 10)],
    staleAfter: const Duration(milliseconds: 60),
  );

  setUp(() {
    gateway = FakeGateway();
    store = FakeStore(_sensor);
    manager = build();
  });

  tearDown(() {
    if (manager.mounted) manager.dispose();
  });

  Future<void> connected() async {
    await manager.acquire();
    expect(manager.state.link, HrLink.connected);
  }

  test('no saved sensor never touches Bluetooth', () async {
    store.saved = null;
    await manager.acquire();
    manager.release();
    expect(gateway.calls, 0);
    expect(manager.state.link, HrLink.none);
  });

  test('saved sensor connects and reports bpm', () async {
    await connected();
    expect(gateway.connectIds, ['AA:BB']);
    expect(manager.state.sensor?.name, 'Tali dada');
    gateway.lastLink.emit([0x00, 133]);
    await _until(() => manager.state.bpm == 133);
  });

  test('bpm goes null when notifications stop', () async {
    await connected();
    gateway.lastLink.emit([0x00, 120]);
    await _until(() => manager.state.bpm == 120);
    await _until(() => manager.state.bpm == null);
    expect(manager.state.link, HrLink.connected);
  });

  test('lost skin contact clears bpm and flags it', () async {
    await connected();
    gateway.lastLink.emit([0x06, 120]);
    await _until(() => manager.state.bpm == 120);
    gateway.lastLink.emit([0x04, 120]);
    await _until(() => manager.state.contactLost);
    expect(manager.state.bpm, isNull);
    gateway.lastLink.emit([0x06, 121]);
    await _until(() => manager.state.bpm == 121);
    expect(manager.state.contactLost, isFalse);
  });

  test('reconnects after the link drops', () async {
    await connected();
    gateway.lastLink.emit([0x00, 110]);
    await _until(() => manager.state.bpm == 110);
    final first = gateway.lastLink;
    first.drop();
    await _until(() => gateway.links.length == 2);
    await _until(() => manager.state.link == HrLink.connected);
    expect(first.closed, isTrue);
    expect(manager.state.bpm, isNull);
    gateway.lastLink.emit([0x00, 111]);
    await _until(() => manager.state.bpm == 111);
  });

  test('keeps retrying a failing connection', () async {
    gateway.connectError = Exception('timeout');
    await manager.acquire();
    await _until(() => gateway.connectIds.length >= 3);
    expect(manager.state.link, HrLink.reconnecting);
    gateway.connectError = null;
    await _until(() => manager.state.link == HrLink.connected);
  });

  test('adapter off stops, adapter on reconnects', () async {
    await connected();
    final first = gateway.lastLink;
    gateway.adapter.add(false);
    await _until(() => manager.state.issue == HrIssue.adapterOff);
    expect(manager.state.link, HrLink.none);
    expect(first.closed, isTrue);
    gateway.adapter.add(true);
    await _until(() => manager.state.link == HrLink.connected);
    expect(manager.state.issue, HrIssue.none);
    expect(gateway.links.length, 2);
  });

  test('adapter already off at start waits for it', () async {
    gateway.adapterOn = false;
    await manager.acquire();
    expect(manager.state.issue, HrIssue.adapterOff);
    expect(gateway.connectIds, isEmpty);
    gateway.adapterOn = true;
    gateway.adapter.add(true);
    await _until(() => manager.state.link == HrLink.connected);
  });

  test('unsupported phone reports it without connecting', () async {
    gateway.supported = false;
    await manager.acquire();
    expect(manager.state.issue, HrIssue.unsupported);
    expect(gateway.connectIds, isEmpty);
  });

  test('recording never prompts for permission', () async {
    gateway.granted = BlePermission.denied;
    await manager.acquire();
    expect(manager.state.issue, HrIssue.permissionDenied);
    expect(gateway.prompts, 0);
    expect(gateway.connectIds, isEmpty);
  });

  test('scan prompts and reports blocked permission', () async {
    gateway.granted = BlePermission.blocked;
    await manager.scan();
    expect(gateway.prompts, 1);
    expect(gateway.scans, 0);
    expect(manager.state.issue, HrIssue.permissionBlocked);
  });

  test('scan sorts by signal and ends', () async {
    gateway.scanResults = const [
      BleFoundDevice(id: '1', name: 'Jauh', rssi: -90),
      BleFoundDevice(id: '2', name: 'Dekat', rssi: -40),
    ];
    await manager.scan();
    expect(manager.state.found.map((d) => d.id), ['2', '1']);
    expect(manager.state.scanning, isFalse);
  });

  test('picking a device saves and connects it', () async {
    store.saved = null;
    await manager.acquire();
    await manager.connectTo(_found);
    expect(store.saved?.id, 'CC:DD');
    expect(gateway.connectIds, ['CC:DD']);
    expect(gateway.scanStops, 1);
    expect(manager.state.link, HrLink.connected);
  });

  test('a device without the service is not retried', () async {
    gateway.connectError = const BleNoHeartRateService();
    await manager.acquire();
    expect(manager.state.issue, HrIssue.notHeartRate);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(gateway.connectIds.length, 1);
  });

  test('forget clears the sensor and closes the link', () async {
    await connected();
    final link = gateway.lastLink;
    await manager.forget();
    expect(store.saved, isNull);
    expect(manager.state.sensor, isNull);
    expect(manager.state.link, HrLink.none);
    expect(link.closed, isTrue);
  });

  test('link stays until the last holder releases', () async {
    await connected();
    await manager.acquire();
    manager.release();
    expect(gateway.lastLink.closed, isFalse);
    manager.release();
    expect(gateway.lastLink.closed, isTrue);
    expect(manager.state.link, HrLink.none);
    expect(manager.state.sensor?.id, 'AA:BB');
  });

  test('release stops pending retries', () async {
    gateway.connectError = Exception('timeout');
    await manager.acquire();
    manager.release();
    final tries = gateway.connectIds.length;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(gateway.connectIds.length, tries);
  });

  test('a release during connect leaves nothing running', () async {
    final pending = manager.acquire();
    manager.release();
    await pending;
    expect(manager.state.link, HrLink.none);
    expect(gateway.links.where((l) => !l.closed), isEmpty);
  });
}
