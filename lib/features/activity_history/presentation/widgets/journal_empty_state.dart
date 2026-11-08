import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/settings/data/data_actions.dart';

/// Empty notebook: contour page with demo/import buttons.
class JournalEmptyState extends ConsumerStatefulWidget {
  const JournalEmptyState({super.key});

  @override
  ConsumerState<JournalEmptyState> createState() => _JournalEmptyStateState();
}

class _JournalEmptyStateState extends ConsumerState<JournalEmptyState> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() f) async {
    setState(() => _busy = true);
    try {
      await f();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaperBackground(
      texture: PaperTexture.contours,
      seed: 11,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        children: [
          Text(
            'JURNAL · HALAMAN 001',
            style: FN
                .label(size: 10, color: FN.signal)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'HALAMAN\nMASIH\nKOSONG.',
            style: TextStyle(
              fontFamily: FN.display,
              fontSize: 64,
              height: 0.95,
              color: FN.ink,
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 3, color: FN.ink),
          const SizedBox(height: 16),
          Text(
            'Belum ada catatan perjalanan. Tekan REKAM untuk memulai, '
            'impor riwayat lama (GPX, TCX, FIT, atau ZIP ekspor Strava), '
            'atau muat rute demo gravel untuk melihat semua fitur.',
            style: TextStyle(
              fontFamily: FN.sans,
              fontSize: 15,
              height: 1.45,
              color: FN.ink,
            ),
          ),
          const SizedBox(height: 28),
          InkButton(
            label: 'Muat rute demo',
            icon: Icons.route,
            style: InkButtonStyle.primary,
            expand: true,
            busy: _busy,
            onPressed: () => _run(() async {
              await DataActions.loadDemo(context, ref);
            }),
          ),
          const SizedBox(height: 14),
          InkButton(
            label: 'Impor riwayat',
            icon: Icons.upload_file,
            expand: true,
            onPressed: _busy
                ? null
                : () => _run(() async {
                    await DataActions.importFile(context, ref);
                  }),
          ),
        ],
      ),
    );
  }
}
