import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:virya/core/sensors/ble_gateway.dart';

/// Android 12+ "Nearby devices" permissions. On Android 11 and lower these
/// report granted, and the Bluetooth plugin asks for location when scanning.
class BluetoothPermissions {
  BluetoothPermissions._();

  static const _needed = [Permission.bluetoothScan, Permission.bluetoothConnect];

  static Future<BlePermission> status() async {
    if (!Platform.isAndroid) return BlePermission.granted;
    try {
      final all = [for (final p in _needed) await p.status];
      return _summarize(all);
    } catch (_) {
      return BlePermission.denied;
    }
  }

  static Future<BlePermission> request() async {
    if (!Platform.isAndroid) return BlePermission.granted;
    try {
      final result = await _needed.request();
      return _summarize(result.values);
    } catch (_) {
      return BlePermission.denied;
    }
  }

  static Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (_) {}
  }

  static BlePermission _summarize(Iterable<PermissionStatus> all) {
    if (all.every((s) => s.isGranted || s.isLimited)) {
      return BlePermission.granted;
    }
    return all.any((s) => s.isPermanentlyDenied || s.isRestricted)
        ? BlePermission.blocked
        : BlePermission.denied;
  }
}
