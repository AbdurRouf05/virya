import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/core/database/app_database.dart';

/// Permission flow for recording.
///
/// Location "while in use" is enough: geolocator runs a *location* foreground
/// service during recording, which keeps access when the screen is off.
class TrackingPermissions {
  TrackingPermissions._();

  static const _batteryTipKey = 'battery_tip_shown';

  /// Returns true when recording may start. Shows explanations as needed.
  static Future<bool> ensureForRecording(
    BuildContext context, {
    required AppDatabase db,
    bool simulated = false,
  }) async {
    if (!simulated) {
      final ok = await _ensureLocation(context);
      if (!ok) return false;
    }
    if (Platform.isAndroid) {
      // Android 13+: needed to show the ongoing tracking notification.
      try {
        await Permission.notification.request();
      } catch (_) {}
      if (context.mounted) await _maybeBatteryTip(context, db);
    }
    return true;
  }

  /// Location only, no dialogs about battery (GPS warm-up on screen open).
  static Future<bool> hasLocation() async {
    try {
      final p = await Geolocator.checkPermission();
      return p == LocationPermission.always ||
          p == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _ensureLocation(BuildContext context) async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      if (!context.mounted) return false;
      final open = await _confirm(
        context,
        title: 'GPS NONAKTIF',
        body: 'Aktifkan Lokasi di pengaturan ponsel agar Stravo bisa '
            'merekam rute kamu.',
        ok: 'Buka Pengaturan',
      );
      if (open) await Geolocator.openLocationSettings();
      return false;
    }

    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      final open = await _confirm(
        context,
        title: 'IZIN LOKASI DITOLAK',
        body: 'Izin lokasi sudah ditolak permanen. Buka pengaturan aplikasi '
            '→ Izin → Lokasi → "Izinkan hanya saat aplikasi digunakan".',
        ok: 'Buka Pengaturan',
      );
      if (open) await openAppSettings();
      return false;
    }

    if (!context.mounted) return false;
    final proceed = await _confirm(
      context,
      title: 'IZIN LOKASI',
      body: 'Stravo butuh lokasi presisi untuk merekam rute, jarak, dan '
          'kecepatan. Data tetap 100% di ponsel kamu — tidak pernah '
          'dikirim ke mana pun.\n\nSaat merekam, notifikasi tetap tampil '
          'agar GPS tetap jalan walau layar mati.',
      ok: 'Lanjut',
    );
    if (!proceed) return false;
    status = await Permission.locationWhenInUse.request();
    return status.isGranted || status.isLimited;
  }

  static Future<void> _maybeBatteryTip(
      BuildContext context, AppDatabase db) async {
    try {
      if (await Permission.ignoreBatteryOptimizations.isGranted) return;
      if (await db.getSetting(_batteryTipKey) == 'true') return;
      await db.setSetting(_batteryTipKey, 'true');
    } catch (_) {
      return;
    }
    if (context.mounted) await showBatteryOptimizationSheet(context);
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String ok,
  }) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FN.nightSurface,
        shape: const RoundedRectangleBorder(),
        title: Text(title, style: FN.label(size: 14, color: FN.paper)),
        content: Text(body,
            style: const TextStyle(
                fontFamily: FN.sans, color: FN.paper, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('BATAL', style: FN.label(color: FN.paperLine)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ok.toUpperCase(), style: FN.label(color: FN.signal)),
          ),
        ],
      ),
    );
    return r ?? false;
  }
}

/// Explains Android battery optimisation (aggressive OEM task killers) and
/// offers to request the "ignore battery optimizations" exemption.
Future<void> showBatteryOptimizationSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: FN.nightSurface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('JANGAN SAMPAI REKAMAN TERPUTUS',
                style: FN.label(size: 13, color: FN.signal)),
            const SizedBox(height: 10),
            const _Body(
              'Beberapa ponsel menghentikan aplikasi di latar belakang untuk '
              'menghemat baterai. Akibatnya rute bisa terpotong saat layar '
              'mati. Izinkan Stravo berjalan tanpa pembatasan baterai.',
            ),
            const SizedBox(height: 14),
            const _Tip('XIAOMI / MIUI / HyperOS',
                'Setelan → Aplikasi → Stravo → Penghemat baterai → "Tanpa '
                    'batasan". Aktifkan juga "Mulai otomatis". Di Recent Apps, '
                    'tahan kartu Stravo lalu ketuk ikon gembok.'),
            const _Tip('OPPO / REALME / ColorOS',
                'Setelan → Baterai → Stravo → izinkan "Aktivitas latar '
                    'belakang" dan "Mulai otomatis". Kunci aplikasi di Recent '
                    'Apps.'),
            const _Tip('SAMSUNG / One UI',
                'Setelan → Aplikasi → Stravo → Baterai → "Tidak dibatasi". '
                    'Pastikan Stravo tidak ada di daftar "Aplikasi tidur".'),
            const _Tip('VIVO / FUNTOUCH',
                'i Manager → Manajemen aplikasi → Konsumsi daya latar tinggi '
                    '→ aktifkan Stravo.'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: FN.signal,
                  foregroundColor: FN.ink,
                  shape: const RoundedRectangleBorder(),
                ),
                onPressed: () async {
                  try {
                    await Permission.ignoreBatteryOptimizations.request();
                  } catch (_) {}
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text('IZINKAN TANPA PEMBATASAN',
                    style: FN.label(size: 13, color: FN.ink)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('NANTI SAJA', style: FN.label(color: FN.paperLine)),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontFamily: FN.sans, fontSize: 14, color: FN.paper, height: 1.4),
      );
}

class _Tip extends StatelessWidget {
  final String brand;
  final String text;
  const _Tip(this.brand, this.text);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: FN.acid, width: 3)),
          color: FN.night,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(brand, style: FN.label(size: 10, color: FN.acid)),
            const SizedBox(height: 4),
            Text(text,
                style: const TextStyle(
                    fontFamily: FN.sans,
                    fontSize: 13,
                    color: FN.paperDeep,
                    height: 1.35)),
          ],
        ),
      );
}
