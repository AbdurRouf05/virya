import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/focus/data/focus_bridge.dart';
import 'package:virya/features/focus/data/focus_providers.dart';
import 'package:virya/features/focus/domain/focus_models.dart';
import 'package:virya/features/focus/presentation/widgets/focus_app_picker_sheet.dart';

/// Pilih aplikasi yang memunculkan daftar rutinitas yang belum selesai saat
/// dibuka.
class FocusGateSection extends ConsumerWidget {
  const FocusGateSection({super.key});

  Future<void> _save(WidgetRef ref, List<FocusInstalledApp> apps) async {
    await ref.read(focusBridgeProvider).setGateApps(apps);
    ref.invalidate(focusGateAppsProvider);
  }

  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    List<FocusInstalledApp> current,
  ) async {
    final app = await showFocusAppPicker(
      context,
      exclude: {for (final a in current) a.packageName},
    );
    if (app == null) return;
    await _save(ref, [...current, app]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps =
        ref.watch(focusGateAppsProvider).valueOrNull ??
        const <FocusInstalledApp>[];
    final body = TextStyle(
      fontFamily: FN.sans,
      fontSize: 14,
      color: FN.inkMuted,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Ingatkan rutinitas',
          trailing: apps.isEmpty
              ? null
              : Text('${apps.length}', style: FN.label(size: 11)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Saat aplikasi di bawah dibuka dan masih ada rutinitas hari ini '
            'yang belum dicentang, Virya menampilkan daftarnya dulu. Kamu bisa '
            'mencentang langsung, "Kerjakan sekarang", atau lanjut setelah 5 '
            'detik. Muncul paling sering sekali tiap 30 menit per aplikasi. '
            'Rutinitas dibuat di Tugas dengan pilihan TIAP HARI.',
            style: body,
          ),
        ),
        for (final a in apps)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    a.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FN.sans,
                      fontSize: 15,
                      color: FN.ink,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus ${a.label}',
                  onPressed: () => _save(ref, [
                    for (final x in apps)
                      if (x.packageName != a.packageName) x,
                  ]),
                  icon: Icon(Icons.close, color: FN.inkMuted),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: InkButton(
            label: 'Pilih aplikasi',
            icon: Icons.add,
            expand: true,
            onPressed: () => _add(context, ref, apps),
          ),
        ),
      ],
    );
  }
}
