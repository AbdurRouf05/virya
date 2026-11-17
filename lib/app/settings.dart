import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/database/app_database.dart';

/// AppSettings keys (shared with recording module).
class SettingKeys {
  SettingKeys._();
  static const units = 'units'; // metric|imperial
  static const ttsEnabled = 'tts_enabled';
  static const ttsSplitKm = 'tts_split_km';
  static const autoPause = 'auto_pause';
  static const phoneMount = 'phone_mount'; // handlebar|pocket
  static const vibrationCalibration = 'vibration_calibration';
  static const defaultSport = 'default_sport';
  static const keepScreenOn = 'keep_screen_on';
  static const useSimulatedGps = 'use_simulated_gps';

  /// Id style tampilan. Sengaja tidak ada di [settingDefaults]; lihat
  /// [styleIdProvider].
  static const styleId = 'style_id';

  /// Gaya tampilan: `tegas` atau `bersih` ([UiGaya.name]). Seperti
  /// [styleId], dibaca sebelum `runApp`.
  static const uiGaya = 'ui_gaya';

  /// Kecerahan gaya Bersih: `terang`, `gelap`, `sistem` ([BersihMode.name]).
  static const bersihMode = 'bersih_mode';

  /// `true` setelah pengguna menekan "Lanjut" di layar pilih gaya pertama.
  static const lookChosen = 'look_chosen';

  /// Jarak pengingat foto tubuh dalam hari, `0` berarti mati.
  static const bodyCheckinDays = 'body_checkin_days';

  /// Per-gear service reminder: "intervalKm|lastServiceKm".
  static String gearService(String gearId) => 'gear_service_$gearId';

  /// URL sumber pembaruan aplikasi (GitHub Gist raw atau endpoint JSON).
  static const updateUrl = 'update_url';

  /// Periksa pembaruan secara otomatis saat aplikasi dibuka.
  static const autoCheckUpdate = 'auto_check_update';
}

const Map<String, String> settingDefaults = {
  SettingKeys.units: 'metric',
  SettingKeys.ttsEnabled: 'true',
  SettingKeys.ttsSplitKm: '1',
  SettingKeys.autoPause: 'true',
  SettingKeys.phoneMount: 'handlebar',
  SettingKeys.vibrationCalibration: '1.0',
  SettingKeys.defaultSport: 'gravelCycling',
  SettingKeys.keepScreenOn: 'true',
  SettingKeys.useSimulatedGps: 'false',
  SettingKeys.updateUrl: '',
  SettingKeys.autoCheckUpdate: 'true',
};

/// In-memory mirror of the AppSettings table; writes go through to SQLite.
class SettingsController extends StateNotifier<Map<String, String>> {
  final AppDatabase db;
  SettingsController(this.db) : super(settingDefaults) {
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await db.select(db.appSettings).get();
      if (!mounted) return;
      state = {...state, for (final r in rows) r.key: r.value};
    } catch (_) {
      // Keep defaults if the table is unavailable.
    }
  }

  Future<void> set(String key, String value) async {
    state = {...state, key: value};
    await db.setSetting(key, value);
  }

  Future<void> setBool(String key, bool v) => set(key, v.toString());
}

final settingsProvider =
    StateNotifierProvider<SettingsController, Map<String, String>>(
      (ref) => SettingsController(ref.watch(databaseProvider)),
    );

/// Style yang dibaca dari database sebelum `runApp`, diisi di `main.dart`.
final initialStyleIdProvider = Provider<String?>((ref) => null);

/// Id style aktif. Selama pengaturan belum termuat nilainya dari
/// [initialStyleIdProvider], jadi style tidak berkedip saat aplikasi dibuka.
final styleIdProvider = Provider<String?>(
  (ref) =>
      ref.watch(settingsProvider)[SettingKeys.styleId] ??
      ref.watch(initialStyleIdProvider),
);

/// Nilai pengaturan tampilan yang dibaca sebelum `runApp` (`main.dart`).
class InitialLook {
  final String? styleId;
  final String? gaya;
  final String? bersihMode;
  final String? lookChosen;
  const InitialLook({
    this.styleId,
    this.gaya,
    this.bersihMode,
    this.lookChosen,
  });

  /// Pengguna sudah pernah memilih tampilan: sudah menekan "Lanjut" di
  /// layar pilih gaya, atau pengguna lama yang menyimpan style.
  bool get chosen => lookChosen == 'true' || styleId != null;
}

final initialLookProvider = Provider<InitialLook>((ref) => const InitialLook());

/// Gaya aktif, dengan nilai awal dari [initialLookProvider] supaya tidak
/// berkedip saat aplikasi dibuka.
final uiGayaProvider = Provider<UiGaya>(
  (ref) => UiGaya.fromId(
    ref.watch(settingsProvider)[SettingKeys.uiGaya] ??
        ref.watch(initialLookProvider).gaya,
  ),
);

final bersihModeProvider = Provider<BersihMode>(
  (ref) => BersihMode.fromId(
    ref.watch(settingsProvider)[SettingKeys.bersihMode] ??
        ref.watch(initialLookProvider).bersihMode,
  ),
);

/// `true` bila pengguna belum pernah memilih tampilan (pemasangan baru).
/// Pengguna lama yang sudah punya [SettingKeys.styleId] dianggap sudah
/// memilih Tegas.
final needsLookChoiceProvider = Provider<bool>((ref) {
  final s = ref.watch(settingsProvider);
  if (s[SettingKeys.lookChosen] == 'true' ||
      s.containsKey(SettingKeys.styleId)) {
    return false;
  }
  return !ref.watch(initialLookProvider).chosen &&
      ref.watch(initialStyleIdProvider) == null;
});

/// `true` setelah layar pilih gaya mengganti gaya secara langsung. Mengganti
/// gaya membangun ulang aplikasi; dengan ini aplikasi kembali ke layar pilih
/// gaya / Beranda tanpa memutar layar pembuka lagi.
final skipEntryProvider = StateProvider<bool>((ref) => false);

final unitsProvider = Provider<Units>(
  (ref) => ref.watch(settingsProvider)[SettingKeys.units] == 'imperial'
      ? Units.imperial
      : Units.metric,
);

final fmtProvider = Provider<Fmt>((ref) => Fmt(ref.watch(unitsProvider)));

extension SettingsMapX on Map<String, String> {
  bool flag(String key) => (this[key] ?? settingDefaults[key]) == 'true';
  double number(String key, double fallback) =>
      double.tryParse(this[key] ?? '') ?? fallback;
  /// Olahraga GPS bawaan untuk perekam (gym tidak pernah jadi bawaan).
  SportType get defaultSport => SportType.gps.firstWhere(
    (s) => s.name == this[SettingKeys.defaultSport],
    orElse: () => SportType.gravelCycling,
  );
}
