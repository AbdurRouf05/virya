import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/features/recording/presentation/recording_screen.dart';
import 'package:virya/features/routes/data/route_providers.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/presentation/route_detail_screen.dart';
import 'package:virya/features/routes/presentation/route_editor_screen.dart';
import 'package:virya/features/routes/presentation/route_setup_screen.dart';
import 'package:virya/features/routes/presentation/saved_routes_screen.dart';

/// Nama rute navigator untuk pintu masuk modul rute.
const routesEntryName = '/routes';

/// Navigasi antar layar rute.
abstract final class RouteFlow {
  static Future<void> openHome(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: routesEntryName),
        builder: (_) => const SavedRoutesScreen(),
      ));

  static Future<void> openBuilder(BuildContext context) =>
      Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const RouteSetupScreen()));

  static Future<void> openDetail(BuildContext context, SavedRoute r,
          {String? trait}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => RouteDetailScreen(route: r, trait: trait)));

  /// Mode edit. Dengan [route] hasilnya dikembalikan; tanpa rute (dari nol)
  /// lanjut ke layar detail.
  static Future<SavedRoute?> openEditor(BuildContext context,
          {SavedRoute? route}) =>
      Navigator.of(context).push<SavedRoute>(MaterialPageRoute(
          builder: (_) => RouteEditorScreen(route: route)));

  /// Menyetel rute aktif lalu kembali ke (atau membuka) layar rekam.
  static void startRecording(
      BuildContext context, WidgetRef ref, SavedRoute r) {
    ref.read(activeRouteProvider.notifier).state = r;
    final nav = Navigator.of(context);
    final fromRecording = ref.read(routesFromRecordingProvider);
    nav.popUntil(
        (route) => route.settings.name == routesEntryName || route.isFirst);
    if (fromRecording) {
      nav.maybePop();
      return;
    }
    if (!nav.canPop()) {
      // Tidak ada pintu rute di tumpukan: buka layar rekam di atasnya.
      _pushRecording(nav);
      return;
    }
    nav.pop();
    _pushRecording(nav);
  }

  static void _pushRecording(NavigatorState nav) => nav.push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => Theme(
              data: FieldNotesTheme.night, child: const RecordingScreen()),
        ),
      );
}
