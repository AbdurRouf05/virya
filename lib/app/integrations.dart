import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/paper_background.dart';
import 'package:virya/core/widgets/route_thumbnail.dart';

/// Seam to other modules' screens/services. UI code depends on this only;
/// the live implementation (`integrations_live.dart`) is injected in main.
/// Keeps the shell, history, dashboard and tests decoupled from plugins.
abstract class Integrations {
  const Integrations();

  Widget recordingScreen();
  Widget shareStudio(String activityId);
  Widget flyover(String activityId);
  Widget mapPacks();
  Widget heartRateSensors();

  /// Full detail page of one saved activity (journal module).
  Widget activityDetail(String activityId);
  Widget routeMap({
    required List<(double lat, double lon)> points,
    List<double>? values,
    String colorMode = 'plain',
    bool interactive = true,
  });

  Future<void> checkRecovery(BuildContext context, WidgetRef ref);

  /// Beranda gym (tab LATIHAN → GYM).
  Widget gymHome();

  /// "MULAI GYM": lanjutkan sesi aktif atau pilih template lalu mulai.
  Future<void> startGym(BuildContext context, WidgetRef ref);

  /// Isi detail aktivitas gym (set per gerakan) di halaman aktivitas.
  Widget gymSessionDetail(String activityId);

  /// Kartu "TUGAS HARI INI" untuk layar Hari Ini.
  Widget todayTasksCard();

  /// Tugas yang selesai pada [day], untuk detail hari di kalender.
  Widget tasksDoneOn(DateTime day);

  /// Buka lembar catat tugas cepat.
  Future<void> showQuickTask(BuildContext context);

  /// Pembungkus shell: sinkron widget & notifikasi tugas.
  Widget taskHost({required Widget child});

  /// Kartu "FOKUS" untuk layar Hari Ini.
  Widget todayFocusCard();

  /// Pemakaian aplikasi pada [day], untuk detail hari di kalender.
  Widget focusDayUsage(DateTime day);

  /// Pembungkus shell: sinkron batas & pemakaian aplikasi.
  Widget focusHost({required Widget child});

  /// Layar "PROGRES TUBUH".
  Widget bodyHome();

  /// Buka check-in foto tubuh hari ini.
  Future<void> startBodyCheckin(BuildContext context);

  /// Pengingat check-in untuk layar Hari Ini.
  Widget todayBodyCard();

  /// Check-in pada [day], untuk detail hari di kalender.
  Widget bodyOnDay(DateTime day);

  /// Layar "HEATMAP" pribadi.
  Widget heatmap();

  /// Peta dengan layer heatmap; bobot titik 0 sampai 1.
  Widget heatmapView({
    required List<(double lat, double lon, double weight)> points,
  });

  /// Layar daftar segmen.
  Widget segmentsHome();

  /// Bagian "Segmen" di detail aktivitas.
  Widget activitySegments(String activityId);

  /// HUD segmen dan ghost di layar rekam.
  Widget recordingSegmentHud();

  Future<List<String>> importFile(AppDatabase db, String path);
  Future<File> exportGpx(AppDatabase db, String activityId);
  Future<File> exportTcx(AppDatabase db, String activityId);
  Future<File> createBackup(AppDatabase db);
  Future<void> restoreBackup(AppDatabase db, String zipPath);
}

/// Used in tests and when a module is missing: sketches instead of maps,
/// "module not installed" pages instead of screens.
class PlaceholderIntegrations extends Integrations {
  const PlaceholderIntegrations();

  Widget _missing(String what) => Scaffold(
    appBar: AppBar(title: Text(what)),
    body: PaperBackground(
      texture: PaperTexture.contours,
      child: Center(
        child: Text(
          'MODUL BELUM TERPASANG',
          style: FN.label(size: 13, color: FN.ink),
        ),
      ),
    ),
  );

  @override
  Widget recordingScreen() => _missing('REKAM');
  @override
  Widget shareStudio(String activityId) => _missing('BAGIKAN');
  @override
  Widget flyover(String activityId) => _missing('FLYOVER');
  @override
  Widget mapPacks() => _missing('PETA');
  @override
  Widget heartRateSensors() => _missing('SENSOR');
  @override
  Widget activityDetail(String activityId) => _missing('AKTIVITAS');
  @override
  Widget routeMap({
    required List<(double, double)> points,
    List<double>? values,
    String colorMode = 'plain',
    bool interactive = true,
  }) => PaperBackground(
    texture: PaperTexture.contours,
    child: RouteThumbnail(
      points: points,
      strokeWidth: 2.4,
      padding: const EdgeInsets.all(20),
    ),
  );

  @override
  Future<void> checkRecovery(BuildContext context, WidgetRef ref) async {}

  @override
  Widget gymHome() => const SizedBox.shrink();
  @override
  Future<void> startGym(BuildContext context, WidgetRef ref) async {}
  @override
  Widget gymSessionDetail(String activityId) => const SizedBox.shrink();

  @override
  Widget todayTasksCard() => const SizedBox.shrink();
  @override
  Widget tasksDoneOn(DateTime day) => const SizedBox.shrink();
  @override
  Future<void> showQuickTask(BuildContext context) async {}
  @override
  Widget taskHost({required Widget child}) => child;

  @override
  Widget todayFocusCard() => const SizedBox.shrink();
  @override
  Widget focusDayUsage(DateTime day) => const SizedBox.shrink();
  @override
  Widget focusHost({required Widget child}) => child;

  @override
  Widget bodyHome() => _missing('PROGRES TUBUH');
  @override
  Future<void> startBodyCheckin(BuildContext context) async {}
  @override
  Widget todayBodyCard() => const SizedBox.shrink();
  @override
  Widget bodyOnDay(DateTime day) => const SizedBox.shrink();

  @override
  Widget heatmap() => _missing('HEATMAP');
  @override
  Widget heatmapView({required List<(double, double, double)> points}) =>
      const SizedBox.expand();

  @override
  Widget segmentsHome() => _missing('SEGMEN');
  @override
  Widget activitySegments(String activityId) => const SizedBox.shrink();
  @override
  Widget recordingSegmentHud() => const SizedBox.shrink();

  Never _unavailable() =>
      throw UnsupportedError('Modul impor/ekspor belum terpasang');
  @override
  Future<List<String>> importFile(AppDatabase db, String path) async =>
      _unavailable();
  @override
  Future<File> exportGpx(AppDatabase db, String activityId) async =>
      _unavailable();
  @override
  Future<File> exportTcx(AppDatabase db, String activityId) async =>
      _unavailable();
  @override
  Future<File> createBackup(AppDatabase db) async => _unavailable();
  @override
  Future<void> restoreBackup(AppDatabase db, String zipPath) async =>
      _unavailable();
}

final integrationsProvider = Provider<Integrations>(
  (ref) => const PlaceholderIntegrations(),
);
