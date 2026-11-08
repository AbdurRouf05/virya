/// A sensor found while scanning.
class BleFoundDevice {
  final String id;
  final String name;
  final int rssi;
  const BleFoundDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });
}

enum BlePermission { granted, denied, blocked }

/// The connected device does not expose the Heart Rate service.
class BleNoHeartRateService implements Exception {
  const BleNoHeartRateService();
}

/// A live connection with Heart Rate notifications enabled.
abstract class BleHeartRateLink {
  /// Raw 0x2A37 notifications.
  Stream<List<int>> get values;

  /// Completes when the connection drops.
  Future<void> get lost;

  Future<void> close();
}

/// Everything the heart-rate manager needs from the Bluetooth stack.
/// Keeps the plugin out of the state machine so it can be tested.
abstract class BleGateway {
  Future<bool> isSupported();
  Future<bool> isAdapterOn();

  /// Adapter on/off changes; may repeat the current value on listen.
  Stream<bool> get adapterChanges;

  /// Current permission, never prompts.
  Future<BlePermission> permission();

  /// Prompts when needed.
  Future<BlePermission> requestPermission();

  Future<void> openPermissionSettings();

  /// Scans for Heart Rate sensors; completes when the scan has ended.
  Future<void> scan({
    required Duration timeout,
    required void Function(List<BleFoundDevice>) onResults,
  });

  Future<void> stopScan();

  /// Connects and subscribes. Throws [BleNoHeartRateService] when the device
  /// has no Heart Rate service, anything else for a retryable failure.
  Future<BleHeartRateLink> connect(String id);
}
