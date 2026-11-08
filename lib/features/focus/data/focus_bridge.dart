import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

/// Jembatan ke sisi Android (`virya/focus`). Di platform lain semua no-op.
class FocusBridge {
  static const _channel = MethodChannel('virya/focus');

  Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('FocusBridge.$method gagal: $e');
      return null;
    }
  }

  Future<FocusPermissions> getPermissions() async {
    final m = await _call<Map<Object?, Object?>>('getPermissions');
    if (m == null) return FocusPermissions.none;
    return FocusPermissions(
      usageAccess: m['usageAccess'] == true,
      accessibility: m['accessibility'] == true,
    );
  }

  Future<void> openUsageSettings() => _call<void>('openUsageSettings');

  Future<void> openAccessibilitySettings() =>
      _call<void>('openAccessibilitySettings');

  /// Aplikasi yang punya ikon peluncur, tanpa Virya sendiri.
  Future<List<FocusInstalledApp>> installedApps() async {
    final raw = await _call<String>('installedApps');
    if (raw == null) return const [];
    return [
      for (final e in jsonDecode(raw) as List<dynamic>)
        FocusInstalledApp.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<void> pushLimits(List<FocusLimit> limits) => _call<void>(
    'pushLimits',
    jsonEncode([for (final l in limits) l.toNative()]),
  );

  /// Pemakaian aplikasi yang dibatasi selama [days] hari terakhir.
  Future<FocusUsageRead> readUsage(int days) async {
    final raw = await _call<String>('readUsage', days);
    if (raw == null) return FocusUsageRead.empty;
    return FocusUsageRead.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

final focusBridgeProvider = Provider<FocusBridge>((ref) => FocusBridge());
