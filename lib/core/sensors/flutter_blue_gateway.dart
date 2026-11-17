import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:virya/core/permissions/bluetooth_permissions.dart';
import 'package:virya/core/sensors/ble_gateway.dart';

/// [BleGateway] on top of flutter_blue_plus. No plugin call happens until a
/// method runs, so users without a sensor never touch the Bluetooth stack.
class FlutterBlueGateway implements BleGateway {
  const FlutterBlueGateway();

  static final _service = Guid('180D');
  static final _measurement = Guid('2A37');
  static const _connectTimeout = Duration(seconds: 15);
  static const _closeTimeout = Duration(seconds: 5);
  static const _adapterTimeout = Duration(seconds: 3);

  @override
  Future<bool> isSupported() async {
    try {
      return await FlutterBluePlus.isSupported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isAdapterOn() async {
    try {
      final s = await FlutterBluePlus.adapterState
          .where((s) => s != BluetoothAdapterState.unknown)
          .first
          .timeout(_adapterTimeout);
      return s == BluetoothAdapterState.on;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<bool> get adapterChanges => FlutterBluePlus.adapterState
      .where((s) => s != BluetoothAdapterState.unknown)
      .map((s) => s == BluetoothAdapterState.on);

  @override
  Future<BlePermission> permission() => BluetoothPermissions.status();

  @override
  Future<BlePermission> requestPermission() => BluetoothPermissions.request();

  @override
  Future<void> openPermissionSettings() => BluetoothPermissions.openSettings();

  @override
  Future<void> scan({
    required Duration timeout,
    required void Function(List<BleFoundDevice>) onResults,
  }) async {
    final sub = FlutterBluePlus.onScanResults.listen(
      (results) => onResults([
        for (final r in results)
          BleFoundDevice(
            id: r.device.remoteId.str,
            name: r.advertisementData.advName.isNotEmpty
                ? r.advertisementData.advName
                : r.device.platformName,
            rssi: r.rssi,
          ),
      ]),
      onError: (Object _) {},
    );
    try {
      await FlutterBluePlus.startScan(
        withServices: [_service],
        timeout: timeout,
      );
      await FlutterBluePlus.isScanning.where((on) => !on).first;
    } finally {
      await sub.cancel();
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  @override
  Future<BleHeartRateLink> connect(String id) async {
    final device = BluetoothDevice.fromId(id);
    await device.connect(
      license: License.nonprofit,
      timeout: _connectTimeout,
      mtu: null,
    );
    try {
      final services = await device.discoverServices();
      final characteristic = _measurementOf(services);
      if (characteristic == null) throw const BleNoHeartRateService();
      final link = _FlutterBlueLink(device);
      link.listenTo(characteristic);
      try {
        await characteristic.setNotifyValue(true);
      } catch (_) {
        await link.detach();
        rethrow;
      }
      return link;
    } catch (_) {
      await _disconnectQuietly(device);
      rethrow;
    }
  }

  static BluetoothCharacteristic? _measurementOf(
    List<BluetoothService> services,
  ) {
    for (final s in services) {
      if (s.uuid != _service) continue;
      for (final c in s.characteristics) {
        if (c.uuid == _measurement) return c;
      }
    }
    return null;
  }

  static Future<void> _disconnectQuietly(BluetoothDevice device) async {
    try {
      await device.disconnect().timeout(_closeTimeout);
    } catch (_) {}
  }
}

class _FlutterBlueLink implements BleHeartRateLink {
  final BluetoothDevice _device;
  final _values = StreamController<List<int>>();
  final _lost = Completer<void>();
  StreamSubscription<List<int>>? _valueSub;
  StreamSubscription<BluetoothConnectionState>? _stateSub;
  bool _closed = false;

  _FlutterBlueLink(this._device) {
    _stateSub = _device.connectionState.listen(
      (s) {
        if (s == BluetoothConnectionState.disconnected) _markLost();
      },
      onError: (Object _) => _markLost(),
    );
  }

  void listenTo(BluetoothCharacteristic characteristic) {
    _valueSub = characteristic.onValueReceived.listen(
      _values.add,
      onError: (Object _) {},
    );
  }

  void _markLost() {
    if (!_lost.isCompleted) _lost.complete();
  }

  @override
  Stream<List<int>> get values => _values.stream;

  @override
  Future<void> get lost => _lost.future;

  /// Stops listening without touching the connection.
  Future<void> detach() async {
    if (_closed) return;
    _closed = true;
    await _valueSub?.cancel();
    await _stateSub?.cancel();
    await _values.close();
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    await detach();
    await FlutterBlueGateway._disconnectQuietly(_device);
  }
}
