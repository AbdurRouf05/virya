import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/core/widgets/today_card.dart';
import 'package:virya/features/focus/data/focus_providers.dart';
import 'package:virya/features/focus/domain/focus_logic.dart';
import 'package:virya/features/focus/domain/focus_models.dart';
import 'package:virya/features/focus/presentation/focus_screen.dart';

/// Kartu "FOKUS" di layar Hari Ini. Jarak bawah ada di dalam kartu agar tidak
/// tersisa celah saat modul ini tidak berjalan.
class TodayFocusCard extends ConsumerWidget {
  static const _maxShown = 3;

  const TodayFocusCard({super.key});

  void _open(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const FocusScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(focusSupportedProvider)) return const SizedBox.shrink();
    final limits = ref.watch(focusLimitsProvider).valueOrNull;
    final statuses = ref.watch(focusStatusesProvider).valueOrNull;
    if (limits == null || statuses == null) return const SizedBox.shrink();
    final perms = ref.watch(focusPermissionsProvider).valueOrNull;
    final shown = statuses.take(_maxShown).toList();
    final hidden = statuses.length - shown.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TodayCard(
        title: 'FOKUS',
        trailing: 'ATUR →',
        onTap: () => _open(context),
        child: limits.isEmpty
            ? const _Empty()
            : Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (perms != null && !perms.ready) ...[
                      Text(
                        'Izin Akses Penggunaan dibutuhkan',
                        style: TextStyle(
                          fontFamily: FN.sans,
                          fontSize: 13,
                          color: FN.warn,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (statuses.isEmpty) const _AllOff(),
                    for (var i = 0; i < shown.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _StatusRow(status: shown[i]),
                    ],
                    if (hidden > 0) ...[
                      const SizedBox(height: 10),
                      Text('+$hidden lainnya', style: FN.label(size: 10.5)),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'Belum ada batas waktu aplikasi.',
            style: TextStyle(
              fontFamily: FN.sans,
              fontSize: 14,
              color: FN.inkMuted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'BATASI APLIKASI',
          style: FN
              .label(size: 11, color: FN.ink)
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _AllOff extends StatelessWidget {
  const _AllOff();

  @override
  Widget build(BuildContext context) => Text(
    'Semua batas sedang dimatikan.',
    style: TextStyle(fontFamily: FN.sans, fontSize: 14, color: FN.inkMuted),
  );
}

class _StatusRow extends StatelessWidget {
  final FocusAppStatus status;
  const _StatusRow({required this.status});

  @override
  Widget build(BuildContext context) {
    final over = status.isOver;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                status.limit.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FN.sans,
                  fontSize: 14,
                  color: FN.ink,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              over
                  ? 'Waktu habis'
                  : 'sisa ${formatFocusMinutes(status.remainingMinutes)}',
              style: FN.label(size: 11, color: over ? FN.warn : FN.ink),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 4,
          color: FN.paperLine,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: status.fraction,
            child: Container(color: over ? FN.warn : FN.ink),
          ),
        ),
      ],
    );
  }
}
