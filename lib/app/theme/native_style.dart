import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virya/app/theme/palette.dart';

const _channel = MethodChannel('virya/style');

String? _pushedId;

@visibleForTesting
void resetNativeStyleForTest() => _pushedId = null;

/// Mengirim warna style ke sisi Android untuk widget layar utama dan layar
/// "Waktu habis", yang digambar tanpa Flutter. Aman dipanggil berulang: style
/// yang sama hanya dikirim sekali per proses.
Future<void> pushNativeStyle(Palette p) async {
  if (_pushedId == p.id) return;
  _pushedId = p.id;
  try {
    await _channel.invokeMethod<void>('apply', {
      'paper': p.paper.toARGB32(),
      'ink': p.ink.toARGB32(),
      'warn': p.warn.toARGB32(),
      'muted': p.inkMuted.toARGB32(),
      'dark': p.brightness == Brightness.dark,
    });
  } on MissingPluginException {
    // Bukan Android (mis. tes): tidak ada permukaan native yang perlu diwarnai.
  } on PlatformException {
    _pushedId = null;
  }
}
