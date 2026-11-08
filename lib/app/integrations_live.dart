import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/app/integrations.dart';
import 'package:stravo/core/backup/backup_service.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/features/maps/presentation/flyover_screen.dart';
import 'package:stravo/features/maps/presentation/map_packs_screen.dart';
import 'package:stravo/features/maps/widgets/route_map_view.dart';
import 'package:stravo/features/recording/presentation/recording_screen.dart';
import 'package:stravo/features/recording/presentation/recovery_prompt.dart';
import 'package:stravo/features/share/presentation/share_studio_screen.dart';
import 'package:stravo/services/export_import/activity_exporter.dart';
import 'package:stravo/services/export_import/activity_importer.dart';

/// Real wiring to the recording, share, maps and IO modules.
class LiveIntegrations extends Integrations {
  const LiveIntegrations();

  @override
  Widget recordingScreen() => const RecordingScreen();
  @override
  Widget shareStudio(String activityId) =>
      ShareStudioScreen(activityId: activityId);
  @override
  Widget flyover(String activityId) => FlyoverScreen(activityId: activityId);
  @override
  Widget mapPacks() => const MapPacksScreen();
  @override
  Widget routeMap({
    required List<(double, double)> points,
    List<double>? values,
    String colorMode = 'plain',
    bool interactive = true,
  }) =>
      RouteMapView(
        points: points,
        values: values,
        colorMode: RouteColorMode.values.asNameMap()[colorMode] ??
            RouteColorMode.plain,
        interactive: interactive,
      );

  @override
  Future<void> checkRecovery(BuildContext context, WidgetRef ref) =>
      checkAndOfferRecovery(context, ref);

  @override
  Future<List<String>> importFile(AppDatabase db, String path) =>
      ActivityImporter(db).importFile(path);
  @override
  Future<File> exportGpx(AppDatabase db, String activityId) =>
      ActivityExporter(db).exportGpx(activityId);
  @override
  Future<File> exportTcx(AppDatabase db, String activityId) =>
      ActivityExporter(db).exportTcx(activityId);
  @override
  Future<File> createBackup(AppDatabase db) => BackupService(db).createBackup();
  @override
  Future<void> restoreBackup(AppDatabase db, String zipPath) async {
    await BackupService(db).restore(zipPath);
  }
}
