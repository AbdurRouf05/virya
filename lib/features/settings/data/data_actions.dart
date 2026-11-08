import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/data/activity_finalizer.dart';
import 'package:virya/core/data/demo_data.dart';
import 'package:virya/core/database/app_database.dart';

/// User-facing data flows shared by Jurnal, Detail and Pengaturan.
class DataActions {
  DataActions._();

  static void toast(BuildContext context, String msg) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Blocking progress dialog while [task] runs.
  static Future<T> withProgress<T>(
      BuildContext context, String message, Future<T> Function() task) async {
    final nav = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.toUpperCase(),
                  style: FN.label(size: 12, color: FN.ink)),
              const SizedBox(height: 14),
              const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
    try {
      return await task();
    } finally {
      nav.pop();
    }
  }

  static Future<String?> loadDemo(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    try {
      final id = await withProgress(
          context, 'Menyiapkan rute demo…', () => seedDemoActivity(db));
      if (context.mounted) toast(context, 'Rute demo dimuat ke jurnal.');
      return id;
    } catch (e) {
      if (context.mounted) toast(context, 'Gagal memuat demo: $e');
      return null;
    }
  }

  /// Pick GPX/TCX/FIT/.gz/.zip (incl. Strava bulk export) and import.
  static Future<List<String>> importFile(
      BuildContext context, WidgetRef ref) async {
    final integ = ref.read(integrationsProvider);
    final db = ref.read(databaseProvider);
    final PlatformFile? file;
    try {
      file = await FilePicker.pickFile(
          dialogTitle: 'Pilih GPX / TCX / FIT / ZIP');
    } catch (e) {
      if (context.mounted) toast(context, 'Tidak bisa membuka pemilih file: $e');
      return const [];
    }
    final path = file?.path;
    if (path == null) return const [];
    if (!context.mounted) return const [];
    try {
      final ids = await withProgress(context,
          'Mengimpor ${file!.name}…', () => integ.importFile(db, path));
      if (context.mounted) {
        toast(
            context,
            ids.isEmpty
                ? 'Tidak ada aktivitas yang bisa diimpor.'
                : '${ids.length} aktivitas diimpor.');
      }
      return ids;
    } catch (e) {
      if (context.mounted) toast(context, 'Impor gagal: $e');
      return const [];
    }
  }

  static Future<void> exportActivity(BuildContext context, WidgetRef ref,
      String activityId, {required bool tcx}) async {
    final integ = ref.read(integrationsProvider);
    final db = ref.read(databaseProvider);
    try {
      final file = await withProgress(
          context,
          'Menyiapkan ${tcx ? 'TCX' : 'GPX'}…',
          () => tcx
              ? integ.exportTcx(db, activityId)
              : integ.exportGpx(db, activityId));
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (e) {
      if (context.mounted) toast(context, 'Ekspor gagal: $e');
    }
  }

  static Future<void> createBackup(BuildContext context, WidgetRef ref) async {
    final integ = ref.read(integrationsProvider);
    final db = ref.read(databaseProvider);
    try {
      final file = await withProgress(
          context, 'Membuat cadangan…', () => integ.createBackup(db));
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        subject: 'Cadangan Virya',
      ));
    } catch (e) {
      if (context.mounted) toast(context, 'Cadangan gagal: $e');
    }
  }

  static Future<void> restoreBackup(BuildContext context, WidgetRef ref) async {
    final integ = ref.read(integrationsProvider);
    final db = ref.read(databaseProvider);
    final PlatformFile? file;
    try {
      file = await FilePicker.pickFile(dialogTitle: 'Pilih file cadangan .zip');
    } catch (e) {
      if (context.mounted) toast(context, 'Tidak bisa membuka pemilih file: $e');
      return;
    }
    final path = file?.path;
    if (path == null || !context.mounted) return;
    final ok = await confirm(
      context,
      title: 'Pulihkan cadangan?',
      body: 'Semua data saat ini akan diganti isi "${file!.name}". '
          'Tindakan ini tidak bisa dibatalkan.',
      action: 'PULIHKAN',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await withProgress(
          context, 'Memulihkan…', () => integ.restoreBackup(db, path));
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('RESTART APLIKASI'),
          content: const Text(
              'Cadangan siap dipulihkan. Tutup lalu buka kembali aplikasi '
              'agar data baru dimuat.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c), child: const Text('OKE')),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) toast(context, 'Pemulihan gagal: $e');
    }
  }

  static Future<void> recalculateAllActivities(
      BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final acts = await db.activitiesDao.getCompletedActivities();
    if (acts.isEmpty) {
      if (context.mounted) {
        toast(context, 'Tidak ada aktivitas selesai untuk dihitung ulang.');
      }
      return;
    }
    if (!context.mounted) return;
    final ok = await confirm(
      context,
      title: 'Hitung ulang aktivitas?',
      body:
          'Akan menghitung ulang statistik, GRIT, dan sektor untuk ${acts.length} aktivitas.',
      action: 'HITUNG ULANG',
    );
    if (!ok || !context.mounted) return;

    final nav = Navigator.of(context, rootNavigator: true);
    final progressNotifier = ValueNotifier<double>(0.0);
    final countNotifier = ValueNotifier<String>('0/${acts.length}');

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: AnimatedBuilder(
            animation: Listenable.merge([progressNotifier, countNotifier]),
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MENGHITUNG ULANG…',
                    style: FN.label(size: 12, color: FN.ink)),
                const SizedBox(height: 8),
                Text(countNotifier.value,
                    style: TextStyle(
                      fontFamily: FN.mono,
                      fontSize: 11,
                      color: FN.inkSoft,
                    )),
                const SizedBox(height: 14),
                LinearProgressIndicator(value: progressNotifier.value),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final finalizer = ActivityFinalizer(db);
      for (var i = 0; i < acts.length; i++) {
        await finalizer.finalize(acts[i].id);
        progressNotifier.value = (i + 1) / acts.length;
        countNotifier.value = '${i + 1}/${acts.length}';
      }
      if (context.mounted) {
        toast(context, '${acts.length} aktivitas berhasil dihitung ulang.');
      }
    } catch (e) {
      if (context.mounted) toast(context, 'Gagal menghitung ulang: $e');
    } finally {
      nav.pop();
    }
  }

  static Future<bool> confirm(BuildContext context,
      {required String title,
      required String body,
      required String action,
      bool danger = false}) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title.toUpperCase()),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('BATAL')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(
                foregroundColor: danger ? FN.warn : FN.signal),
            child: Text(action),
          ),
        ],
      ),
    );
    return r ?? false;
  }
}
