import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/focus/data/focus_providers.dart';
import 'package:virya/features/focus/domain/focus_models.dart';
import 'package:virya/features/focus/presentation/widgets/focus_app_picker_sheet.dart';
import 'package:virya/features/focus/presentation/widgets/focus_limit_tile.dart';
import 'package:virya/features/focus/presentation/widgets/focus_minutes_sheet.dart';
import 'package:virya/features/focus/presentation/widgets/focus_permission_panel.dart';

/// Atur batas waktu harian per aplikasi.
class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(focusRepositoryProvider);
    final app = await showFocusAppPicker(context);
    if (app == null || !context.mounted) return;
    final minutes = await showFocusMinutesSheet(context, label: app.label);
    if (minutes == null) return;
    await repo.saveLimit(
      packageName: app.packageName,
      label: app.label,
      dailyMinutes: minutes,
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    FocusLimit limit,
  ) async {
    final repo = ref.read(focusRepositoryProvider);
    final minutes = await showFocusMinutesSheet(
      context,
      label: limit.label,
      initial: limit.dailyMinutes,
    );
    if (minutes == null) return;
    await repo.saveLimit(
      packageName: limit.packageName,
      label: limit.label,
      dailyMinutes: minutes,
    );
    // saveLimit selalu menyalakan batas; ubah menit tidak boleh menyalakannya.
    if (!limit.enabled) await repo.setEnabled(limit.packageName, false);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    FocusLimit limit,
  ) async {
    final repo = ref.read(focusRepositoryProvider);
    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Hapus batas ${limit.label}?'),
        content: const Text('Riwayat pemakaiannya tetap tersimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (sure == true) await repo.removeLimit(limit.packageName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limits =
        ref.watch(focusLimitsProvider).valueOrNull ?? const <FocusLimit>[];
    final statuses =
        ref.watch(focusStatusesProvider).valueOrNull ??
        const <FocusAppStatus>[];
    final perms = ref.watch(focusPermissionsProvider).valueOrNull;
    final byPackage = {for (final s in statuses) s.limit.packageName: s};
    final body = TextStyle(
      fontFamily: FN.sans,
      fontSize: 14,
      color: FN.inkMuted,
    );
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
              const Masthead(kicker: 'Batas waktu harian', title: 'Fokus'),
              if (perms != null && !perms.ready)
                FocusPermissionPanel(permissions: perms),
              if (perms != null && perms.ready)
                FocusModeBanner(permissions: perms),
              SectionHeader(
                title: 'Aplikasi',
                trailing: limits.isEmpty
                    ? null
                    : Text('${limits.length}', style: FN.label(size: 11)),
              ),
              if (limits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Belum ada aplikasi yang dibatasi.', style: body),
                ),
              for (var i = 0; i < limits.length; i++) ...[
                if (i > 0) Container(height: 1, color: FN.paperLine),
                FocusLimitTile(
                  limit: limits[i],
                  status: byPackage[limits[i].packageName],
                  onToggle: (on) => ref
                      .read(focusRepositoryProvider)
                      .setEnabled(limits[i].packageName, on),
                  onEdit: () => _edit(context, ref, limits[i]),
                  onDelete: () => _delete(context, ref, limits[i]),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: InkButton(
                  label: 'Tambah aplikasi',
                  icon: Icons.add,
                  style: InkButtonStyle.primary,
                  expand: true,
                  onPressed: () => _add(context, ref),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Saat waktu habis, kamu bisa menambah 5 menit satu kali per hari.',
                  style: body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
