import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/app/integrations.dart';
import 'package:stravo/app/integrations_live.dart';
import 'package:stravo/app/stravo_app.dart';
import 'package:stravo/core/backup/backup_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Apply a staged backup restore before the database is opened.
  try {
    await BackupService.applyPendingRestore();
  } catch (e) {
    debugPrint('applyPendingRestore failed: $e');
  }
  runApp(ProviderScope(
    overrides: [
      integrationsProvider.overrideWithValue(const LiveIntegrations()),
    ],
    child: const StravoApp(),
  ));
}
