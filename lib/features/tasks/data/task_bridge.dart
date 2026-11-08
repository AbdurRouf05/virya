import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/features/tasks/domain/task_models.dart';

/// Jembatan ke sisi Android (`virya/tasks`): widget, notifikasi catat cepat,
/// ubin Quick Settings, dan pintasan ikon. Di platform lain semua no-op.
class TaskBridge {
  static const _channel = MethodChannel('virya/tasks');

  /// Dipanggil saat antrean native berubah atau ada aksi peluncuran baru.
  void listen(VoidCallback? onChanged) {
    _channel.setMethodCallHandler(
      onChanged == null ? null : (_) async => onChanged(),
    );
  }

  Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('TaskBridge.$method gagal: $e');
      return null;
    }
  }

  Future<void> pushSnapshot(List<Map<String, Object?>> tasks) =>
      _call<void>('pushSnapshot', jsonEncode(tasks));

  /// Antrean perubahan; tetap tersimpan sampai [ackInbox] dipanggil.
  Future<List<TaskInboxOp>> peekInbox() async {
    final raw = await _call<String>('peekInbox');
    if (raw == null) return const [];
    final ops = <TaskInboxOp>[];
    for (final e in jsonDecode(raw) as List<dynamic>) {
      final op = TaskInboxOp.parse(e as Map<String, dynamic>);
      if (op != null) ops.add(op);
    }
    return ops;
  }

  Future<void> ackInbox(List<String> ids) => _call<void>('ackInbox', ids);

  /// Aksi peluncuran tertunda (`quick_task`), sekali baca lalu hilang.
  Future<String?> takeLaunchAction() => _call<String>('takeLaunchAction');

  Future<bool> isQuickCaptureOn() async =>
      await _call<bool>('isQuickCaptureOn') ?? false;

  Future<void> setQuickCapture(bool on) => _call<void>('setQuickCapture', on);

  Future<bool> canPinWidget() async =>
      await _call<bool>('canPinWidget') ?? false;

  Future<void> requestPinWidget() => _call<void>('requestPinWidget');
}

final taskBridgeProvider = Provider<TaskBridge>((ref) => TaskBridge());
