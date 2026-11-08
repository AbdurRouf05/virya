import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/core/backup/backup_service.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/activity_history/presentation/activity_detail_screen.dart';
import 'package:virya/features/gym/presentation/gym_home_screen.dart';
import 'package:virya/features/gym/presentation/gym_launcher.dart';
import 'package:virya/features/gym/presentation/gym_session_detail.dart';
import 'package:virya/features/maps/presentation/flyover_screen.dart';
import 'package:virya/features/maps/presentation/map_packs_screen.dart';
import 'package:virya/features/maps/widgets/route_map_view.dart';
import 'package:virya/features/recording/presentation/recording_screen.dart';
import 'package:virya/features/recording/presentation/recovery_prompt.dart';
import 'package:virya/features/share/presentation/share_studio_screen.dart';
import 'package:virya/features/tasks/presentation/task_host.dart';
import 'package:virya/features/tasks/presentation/widgets/task_quick_add_sheet.dart';
import 'package:virya/features/tasks/presentation/widgets/tasks_done_day.dart';
import 'package:virya/features/tasks/presentation/widgets/today_tasks_card.dart';
import 'package:virya/services/export_import/activity_exporter.dart';
import 'package:virya/services/export_import/activity_importer.dart';

/// Real wiring to the recording, share, maps, gym and IO modules.
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
  Widget activityDetail(String activityId) =>
      ActivityDetailScreen(activityId: activityId);
  @override
  Widget routeMap({
    required List<(double, double)> points,
    List<double>? values,
    String colorMode = 'plain',
    bool interactive = true,
  }) => RouteMapView(
    points: points,
    values: values,
    colorMode:
        RouteColorMode.values.asNameMap()[colorMode] ?? RouteColorMode.plain,
    interactive: interactive,
  );

  @override
  Future<void> checkRecovery(BuildContext context, WidgetRef ref) =>
      checkAndOfferRecovery(context, ref);

  @override
  Widget gymHome() => const GymHomeScreen();
  @override
  Future<void> startGym(BuildContext context, WidgetRef ref) =>
      startGymFlow(context, ref);
  @override
  Widget gymSessionDetail(String activityId) =>
      GymSessionDetail(activityId: activityId);

  @override
  Widget todayTasksCard() => const TodayTasksCard();
  @override
  Widget tasksDoneOn(DateTime day) => TasksDoneDay(day: day);
  @override
  Future<void> showQuickTask(BuildContext context) => showQuickAddTask(context);
  @override
  Widget taskHost({required Widget child}) => TaskHost(child: child);

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
