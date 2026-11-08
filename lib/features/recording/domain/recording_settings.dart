import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/sensors/surface_classifier.dart';

/// Recording-related values from the AppSettings table (string values).
class RecordingSettings {
  final bool imperial;
  final bool ttsEnabled;
  final double ttsSplit; // km, or miles when imperial
  final bool autoPause;
  final PhoneMount mount;
  final double vibrationCalibration;
  final SportType defaultSport;
  final bool keepScreenOn;
  final bool simulated;
  final double simSpeedUp;

  const RecordingSettings({
    this.imperial = false,
    this.ttsEnabled = true,
    this.ttsSplit = 1,
    this.autoPause = true,
    this.mount = PhoneMount.handlebar,
    this.vibrationCalibration = 1.0,
    this.defaultSport = SportType.gravelCycling,
    this.keepScreenOn = false,
    this.simulated = false,
    this.simSpeedUp = 10,
  });

  static const keyUnits = 'units';
  static const keyTtsEnabled = 'tts_enabled';
  static const keyTtsSplitKm = 'tts_split_km';
  static const keyAutoPause = 'auto_pause';
  static const keyPhoneMount = 'phone_mount';
  static const keyVibrationCalibration = 'vibration_calibration';
  static const keyDefaultSport = 'default_sport';
  static const keyKeepScreenOn = 'keep_screen_on';
  static const keyUseSimulatedGps = 'use_simulated_gps';
  static const keySimSpeedUp = 'sim_speedup';

  static Future<RecordingSettings> load(AppDatabase db) async {
    Future<String?> g(String k) async {
      try {
        return await db.getSetting(k);
      } catch (_) {
        return null;
      }
    }

    bool flag(String? v, bool def) => v == null ? def : v == 'true';
    double num(String? v, double def) {
      final d = double.tryParse(v ?? '');
      return d == null || d <= 0 ? def : d;
    }

    final sportName = await g(keyDefaultSport);
    return RecordingSettings(
      imperial: await g(keyUnits) == 'imperial',
      ttsEnabled: flag(await g(keyTtsEnabled), true),
      ttsSplit: num(await g(keyTtsSplitKm), 1),
      autoPause: flag(await g(keyAutoPause), true),
      mount: PhoneMount.parse(await g(keyPhoneMount)),
      vibrationCalibration: num(await g(keyVibrationCalibration), 1.0),
      defaultSport: SportType.values.firstWhere(
        (s) => s.name == sportName,
        orElse: () => SportType.gravelCycling,
      ),
      keepScreenOn: flag(await g(keyKeepScreenOn), false),
      simulated: flag(await g(keyUseSimulatedGps), false),
      simSpeedUp: num(await g(keySimSpeedUp), 10),
    );
  }
}
