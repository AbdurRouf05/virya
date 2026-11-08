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
  Widget routeMap({
    required List<(double lat, double lon)> points,
    List<double>? values,
    String colorMode = 'plain',
    bool interactive = true,
  });

  Future<void> checkRecovery(BuildContext context, WidgetRef ref);

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
