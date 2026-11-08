import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/integrations_live.dart';
import 'package:virya/app/virya_app.dart';
import 'package:virya/core/backup/backup_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Apply a staged backup restore before the database is opened.
  try {
    await BackupService.applyPendingRestore();
    await BackupService.cleanupPreviousRestore();
  } catch (e) {
    debugPrint('applyPendingRestore failed: $e');
  }
  runApp(ProviderScope(
    overrides: [
      integrationsProvider.overrideWithValue(const LiveIntegrations()),
    ],
    child: const ViryaApp(),
  ));
}
