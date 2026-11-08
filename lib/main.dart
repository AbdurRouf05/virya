import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/integrations_live.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/virya_app.dart';
import 'package:virya/core/backup/backup_service.dart';
import 'package:virya/core/data/activity_finalizer.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/segments/data/segment_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ActivityFinalizer.afterFinalize = syncSegmentsAfterFinalize;
  // Apply a staged backup restore before the database is opened.
  try {
    await BackupService.applyPendingRestore();
  } catch (e) {
    debugPrint('applyPendingRestore failed: $e');
  }
  // Style dibaca sebelum frame pertama supaya tidak berkedip.
  final db = AppDatabase();
  String? styleId;
  try {
    styleId = await db.getSetting(SettingKeys.styleId);
  } catch (e) {
    debugPrint('Gagal membaca style: $e');
  }
  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWith((ref) {
        ref.onDispose(db.close);
        return db;
      }),
      initialStyleIdProvider.overrideWithValue(styleId),
      integrationsProvider.overrideWithValue(const LiveIntegrations()),
    ],
    child: const ViryaApp(),
  ));
}
