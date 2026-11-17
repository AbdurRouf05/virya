import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/updater/update_dialog.dart';
import 'package:virya/core/updater/update_provider.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Banner pemberitahuan jika ada rilis APK baru yang tersedia.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(updateProvider);
    if (update == null) return const SizedBox.shrink();

    final localInfoAsync = ref.watch(localAppInfoProvider);
    final currentVer = localInfoAsync.value?.versionName ?? '1.0.0';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: FN.paperDeep,
        border: Border.all(color: FN.ink, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: FN.ink,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: FN.signal,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              'UPDATE',
              style: FN.monoStyle(
                size: 9,
                weight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Versi ${update.versionName} siap diunduh',
              style: FN.label(size: 11, color: FN.ink),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => UpdateDialog.show(
              context,
              updateInfo: update,
              currentVersion: currentVer,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: FN.ink,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                'LIHAT',
                style: FN.monoStyle(
                  size: 10,
                  weight: FontWeight.bold,
                  color: FN.paper,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => ref.read(updateProvider.notifier).dismiss(),
          ),
        ],
      ),
    );
  }
}
