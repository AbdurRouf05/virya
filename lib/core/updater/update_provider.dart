import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/updater/update_model.dart';
import 'package:virya/core/updater/update_service.dart';

/// Provider info versi lokal aplikasi.
final localAppInfoProvider =
    FutureProvider<({String versionName, int versionCode, String packageName})>(
  (ref) => UpdateService.getLocalAppInfo(),
);

/// State notifier pembaruan aplikasi yang tersedia.
class UpdateNotifier extends StateNotifier<AppUpdateInfo?> {
  final Ref ref;
  bool _hasCheckedOnStartup = false;

  UpdateNotifier(this.ref) : super(null);

  /// Periksa pembaruan otomatis saat aplikasi dijalankan (jika diaktifkan).
  Future<void> checkOnStartup() async {
    if (_hasCheckedOnStartup) return;
    _hasCheckedOnStartup = true;

    final settings = ref.read(settingsProvider);
    final autoCheck = settings.flag(SettingKeys.autoCheckUpdate);
    if (!autoCheck) return;

    try {
      final customUrl = settings[SettingKeys.updateUrl];
      final url = (customUrl != null && customUrl.trim().isNotEmpty)
          ? customUrl.trim()
          : null;
      final info = await UpdateService.checkForUpdate(updateUrl: url);
      if (mounted) {
        state = info;
      }
    } catch (e) {
      debugPrint('UpdateNotifier: Pemeriksaan di latar belakang gagal: $e');
    }
  }

  /// Periksa pembaruan manual atas permintaan pengguna.
  Future<AppUpdateInfo?> checkManual({String? customUrl}) async {
    final settings = ref.read(settingsProvider);
    final url = customUrl ??
        (settings[SettingKeys.updateUrl]?.trim().isNotEmpty == true
            ? settings[SettingKeys.updateUrl]!.trim()
            : null);

    final info = await UpdateService.checkForUpdate(updateUrl: url);
    if (mounted) {
      state = info;
    }
    return info;
  }

  /// Tutup banner pembaruan untuk sesi ini.
  void dismiss() {
    state = null;
  }
}

final updateProvider = StateNotifierProvider<UpdateNotifier, AppUpdateInfo?>(
  (ref) => UpdateNotifier(ref),
);
