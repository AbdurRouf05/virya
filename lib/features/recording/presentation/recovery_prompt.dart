import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/data/activity_finalizer.dart';
import 'package:virya/features/recording/application/recording_controller.dart';
import 'package:virya/features/recording/data/crash_recovery_service.dart';
import 'package:virya/features/recording/presentation/recording_screen.dart';

enum _RecoveryChoice { resume, save, discard }

/// Checks for an interrupted (inProgress) recording and offers to resume,
/// save or discard it. Call once on the home screen's first frame.
Future<void> checkAndOfferRecovery(BuildContext context, WidgetRef ref) async {
  // A session already live in this process is not a crash.
  if (ref.read(recordingControllerProvider).isActive) return;

  final service = ref.read(crashRecoveryServiceProvider);
  final CrashRecoveryState check;
  try {
    check = await service.checkUnfinishedSession();
  } catch (_) {
    return;
  }
  final activity = check.unfinishedActivity;
  if (!check.hasUnfinishedSession || activity == null || !context.mounted) {
    return;
  }

  final when = DateFormat('d MMM, HH:mm').format(activity.startTime);
  final choice = await showDialog<_RecoveryChoice>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: FN.nightSurface,
      shape: const RoundedRectangleBorder(),
      title: Text('REKAMAN TERPUTUS',
          style: FN.label(size: 14, color: FN.signal)),
      content: Text(
        '"${activity.title}" ($when) belum selesai — kemungkinan aplikasi '
        'tertutup atau baterai habis.\n\n'
        '${check.recoveredPointsCount} titik GPS berhasil diselamatkan.',
        style: TextStyle(
            fontFamily: FN.sans, color: FN.paper, height: 1.4),
      ),
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, _RecoveryChoice.discard),
          child: Text('BUANG', style: FN.label(color: FN.warn)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, _RecoveryChoice.save),
          child: Text('SIMPAN', style: FN.label(color: FN.paper)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, _RecoveryChoice.resume),
          child: Text('LANJUTKAN', style: FN.label(color: FN.acid)),
        ),
      ],
    ),
  );
  if (choice == null || !context.mounted) return;

  switch (choice) {
    case _RecoveryChoice.resume:
      await ref
          .read(recordingControllerProvider.notifier)
          .resumeRecovered(activity);
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecordingScreen()),
        );
      }
    case _RecoveryChoice.save:
      if (check.recoveredPointsCount == 0) {
        await service.discardSession(activity.id);
        if (context.mounted) {
          _snack(context, 'Tidak ada titik GPS — sesi dibuang.');
        }
        return;
      }
      try {
        await ref.read(activityFinalizerProvider).finalize(activity.id);
      } catch (_) {
        await service.finalizeAndSave(activity);
      }
      if (context.mounted) _snack(context, 'Aktivitas disimpan.');
    case _RecoveryChoice.discard:
      final sure = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: FN.nightSurface,
          shape: const RoundedRectangleBorder(),
          title: Text('YAKIN BUANG?',
              style: FN.label(size: 14, color: FN.paper)),
          content: Text('Data rekaman ini akan dihapus permanen.',
              style: TextStyle(fontFamily: FN.sans, color: FN.paper)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('BATAL', style: FN.label(color: FN.paperLine)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('BUANG', style: FN.label(color: FN.warn)),
            ),
          ],
        ),
      );
      if (sure == true) {
        await service.discardSession(activity.id);
        if (context.mounted) _snack(context, 'Sesi dibuang.');
      } else if (context.mounted) {
        // Ask again so the session is not left dangling.
        await checkAndOfferRecovery(context, ref);
      }
  }
}

void _snack(BuildContext context, String text) {
  if (!context.mounted) return;
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(content: Text(text, style: TextStyle(fontFamily: FN.sans))),
  );
}
