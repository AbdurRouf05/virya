import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/permissions/tracking_permissions.dart';
import 'package:virya/features/activity_history/data/journal_providers.dart';
import 'package:virya/features/settings/data/data_actions.dart';
import 'package:virya/features/today/application/today_controller.dart';

/// Card panduan mulai cepat untuk pengguna baru yang belum memiliki aktivitas
/// atau ingin menjelajahi fitur Virya dengan data contoh.
class TodayQuickstartCard extends ConsumerStatefulWidget {
  final VoidCallback? onStart;
  final VoidCallback? onDismiss;

  const TodayQuickstartCard({
    super.key,
    this.onStart,
    this.onDismiss,
  });

  @override
  ConsumerState<TodayQuickstartCard> createState() => _TodayQuickstartCardState();
}

class _TodayQuickstartCardState extends ConsumerState<TodayQuickstartCard> {
  bool _loadingDemo = false;

  Future<void> _loadDemo() async {
    if (_loadingDemo) return;
    setState(() => _loadingDemo = true);
    try {
      final id = await DataActions.loadDemo(context, ref);
      if (id != null) {
        ref.invalidate(todaySummaryProvider);
        ref.invalidate(completedActivitiesProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: FN.ink,
              content: Text(
                'Rute contoh Lembang (32 km) berhasil dimuat!',
                style: TextStyle(fontFamily: FN.sans, color: FN.paper),
              ),
              action: SnackBarAction(
                label: 'Buka',
                textColor: FN.signal,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ref.read(integrationsProvider).activityDetail(id),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loadingDemo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FN.cardFill,
        border: FN.frame(color: FN.ink, width: 2),
        borderRadius: FN.boxRadius,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: FN.signal,
                  borderRadius: FN.smallRadius,
                ),
                child: Text(
                  FN.caps('MULAI CEPAT'),
                  style: FN
                      .label(size: 10, color: FN.onAccent)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              if (widget.onDismiss != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      FN.caps('TUTUP [Ã—]'),
                      style: FN.label(size: 10, color: FN.inkMuted),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Selamat Datang di Virya',
            style: TextStyle(
              fontFamily: FN.sans,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FN.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aplikasi pelacak olahraga & konsistensi pribadi 100% offline. Semua data tersimpan aman di HP kamu tanpa akun dan tanpa server.',
            style: TextStyle(
              fontFamily: FN.sans,
              fontSize: 13,
              color: FN.inkSoft,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          _ActionRow(
            icon: Icons.map_outlined,
            title: 'Coba Data Contoh (Lembang 32 km)',
            subtitle:
                'Jelajahi tanjakan, profil elevasi, 3D flyover, dan heatmap tanpa perlu keluar rumah.',
            buttonLabel: _loadingDemo ? 'MEMUATâ€¦' : 'MUAT CONTOH',
            onTap: _loadingDemo ? null : _loadDemo,
            highlight: true,
          ),
          const SizedBox(height: 10),
          _ActionRow(
            icon: Icons.battery_charging_full_outlined,
            title: 'Optimasi Baterai HP',
            subtitle:
                'Cegah HP (MIUI/Infinix/Samsung) mematikan GPS saat layar mati.',
            buttonLabel: 'ATUR BATERAI',
            onTap: () async {
              await showBatteryOptimizationSheet(context);
            },
          ),
          const SizedBox(height: 10),
          _ActionRow(
            icon: Icons.upload_file_outlined,
            title: 'Impor Riwayat Strava',
            subtitle: 'Pindahkan riwayat file ZIP Strava, GPX, TCX, atau FIT kamu.',
            buttonLabel: 'IMPOR DATA',
            onTap: () async {
              final ids = await DataActions.importFile(context, ref);
              if (ids.isNotEmpty) {
                ref.invalidate(todaySummaryProvider);
                ref.invalidate(completedActivitiesProvider);
              }
            },
          ),
          if (widget.onStart != null) ...[
            const SizedBox(height: 10),
            _ActionRow(
              icon: Icons.play_arrow_outlined,
              title: 'Mulai Rekam Aktivitas',
              subtitle: 'Rekam gowes, lari, jalan, hiking, atau latihan beban gym.',
              buttonLabel: 'REKAM SEKARANG',
              onTap: widget.onStart,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onTap;
  final bool highlight;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: highlight
            ? (FN.isClean ? FN.paperLine.withValues(alpha: 0.3) : FN.paper)
            : FN.paper.withValues(alpha: 0.5),
        border: FN.frame(width: 1),
        borderRadius: FN.boxRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: highlight ? FN.signal : FN.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: FN.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: FN.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: FN.sans,
                    fontSize: 11.5,
                    color: FN.inkMuted,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: highlight ? FN.signal : FN.ink,
                      borderRadius: FN.smallRadius,
                    ),
                    child: Text(
                      FN.caps(buttonLabel),
                      style: FN
                          .label(
                            size: 10.5,
                            color: highlight ? FN.onAccent : FN.paper,
                          )
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
