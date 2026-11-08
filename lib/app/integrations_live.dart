import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/core/backup/backup_service.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/activity_history/presentation/activity_detail_screen.dart';
import 'package:virya/features/body/presentation/body_checkin_screen.dart';
import 'package:virya/features/body/presentation/body_screen.dart';
import 'package:virya/features/body/presentation/widgets/body_day_entry.dart';
import 'package:virya/features/body/presentation/widgets/today_body_card.dart';
import 'package:virya/features/focus/presentation/focus_host.dart';
import 'package:virya/features/focus/presentation/widgets/focus_day_usage.dart';
import 'package:virya/features/focus/presentation/widgets/today_focus_card.dart';
import 'package:virya/features/gym/presentation/gym_home_screen.dart';
import 'package:virya/features/gym/presentation/gym_launcher.dart';
import 'package:virya/features/gym/presentation/gym_session_detail.dart';
import 'package:virya/features/heatmap/presentation/heatmap_screen.dart';
import 'package:virya/features/maps/presentation/flyover_screen.dart';
import 'package:virya/features/maps/presentation/map_packs_screen.dart';
import 'package:virya/features/maps/widgets/heatmap_map_view.dart';
import 'package:virya/features/maps/widgets/route_map_view.dart';
import 'package:virya/features/recording/presentation/recording_screen.dart';
import 'package:virya/features/recording/presentation/recovery_prompt.dart';
import 'package:virya/features/sensors/presentation/heart_rate_sensor_screen.dart';
import 'package:virya/features/segments/presentation/segments_screen.dart';
import 'package:virya/features/segments/presentation/widgets/activity_segments_section.dart';
import 'package:virya/features/segments/presentation/widgets/segment_live_hud.dart';
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
  Widget heartRateSensors() => const HeartRateSensorScreen();
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
  Widget todayFocusCard() => const TodayFocusCard();
  @override
  Widget focusDayUsage(DateTime day) => FocusDayUsage(day: day);
  @override
  Widget focusHost({required Widget child}) => FocusHost(child: child);

  @override
  Widget bodyHome() => const BodyScreen();
  @override
  Future<void> startBodyCheckin(BuildContext context) {
    final now = DateTime.now();
    return openBodyCheckin(context, DateTime(now.year, now.month, now.day));
  }

  @override
  Widget todayBodyCard() => const TodayBodyCard();
  @override
  Widget bodyOnDay(DateTime day) => BodyDayEntry(day: day);

  @override
  Widget heatmap() => const HeatmapScreen();
  @override
  Widget heatmapView({required List<(double, double, double)> points}) =>
      HeatmapMapView(points: points);

  @override
  Widget segmentsHome() => const SegmentsScreen();
  @override
  Widget activitySegments(String activityId) =>
      ActivitySegmentsSection(activityId: activityId);
  @override
  Widget recordingSegmentHud() => const SegmentLiveHud();

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
