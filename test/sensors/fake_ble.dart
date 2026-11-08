import 'dart:async';

import 'package:virya/core/sensors/ble_gateway.dart';
import 'package:virya/core/sensors/hr_sensor_store.dart';

class FakeLink implements BleHeartRateLink {
  final _values = StreamController<List<int>>.broadcast();
  final _lost = Completer<void>();
  bool closed = false;

  void emit(List<int> bytes) => _values.add(bytes);
  void drop() {
    if (!_lost.isCompleted) _lost.complete();
  }

  @override
  Stream<List<int>> get values => _values.stream;
  @override
  Future<void> get lost => _lost.future;
  @override
  Future<void> close() async => closed = true;
}

class FakeGateway implements BleGateway {
  bool supported = true;
  bool adapterOn = true;
  BlePermission granted = BlePermission.granted;
  Object? connectError;
  List<BleFoundDevice> scanResults = const [];

  int calls = 0;
  int prompts = 0;
  int scans = 0;
  int scanStops = 0;
  final List<String> connectIds = [];
  final List<FakeLink> links = [];
  final adapter = StreamController<bool>.broadcast();

  FakeLink get lastLink => links.last;

  @override
  Future<bool> isSupported() async {
    calls++;
    return supported;
  }

  @override
  Future<bool> isAdapterOn() async {
    calls++;
    return adapterOn;
  }

  @override
  Stream<bool> get adapterChanges {
    calls++;
    return adapter.stream;
  }

  @override
  Future<BlePermission> permission() async {
    calls++;
    return granted;
  }

  @override
  Future<BlePermission> requestPermission() async {
    calls++;
    prompts++;
    return granted;
  }

  @override
  Future<void> openPermissionSettings() async {}

  @override
  Future<void> scan({
    required Duration timeout,
    required void Function(List<BleFoundDevice>) onResults,
  }) async {
    calls++;
    scans++;
    onResults(scanResults);
  }

  @override
  Future<void> stopScan() async => scanStops++;

  @override
  Future<BleHeartRateLink> connect(String id) async {
    calls++;
    connectIds.add(id);
    final error = connectError;
    if (error != null) throw error;
    final link = FakeLink();
    links.add(link);
    return link;
  }
}

class FakeStore implements HrSensorStore {
  HrSensorRef? saved;
  FakeStore([this.saved]);

  @override
  Future<HrSensorRef?> load() async => saved;
  @override
  Future<void> save(HrSensorRef sensor) async => saved = sensor;
  @override
  Future<void> clear() async => saved = null;
}
