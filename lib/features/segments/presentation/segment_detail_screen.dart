import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/segments/data/segment_providers.dart';
import 'package:virya/features/segments/domain/segment_models.dart';
import 'package:virya/features/segments/presentation/widgets/segment_effort_tile.dart';
import 'package:virya/features/settings/data/data_actions.dart';

/// Rute, rekor, dan riwayat upaya satu segmen.
class SegmentDetailScreen extends ConsumerWidget {
  final String segmentId;
  const SegmentDetailScreen({super.key, required this.segmentId});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SegmentSummary s,
  ) async {
    final ok = await DataActions.confirm(
      context,
      title: 'Hapus segmen?',
      body:
          '"${s.name}" dan riwayat upayanya akan dihapus. '
          'Aktivitasnya tetap ada.',
      action: 'HAPUS',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    await ref.read(segmentRepositoryProvider).delete(s.id);
    if (context.mounted) Navigator.of(context).maybePop();
  }

  Widget _stat(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FN.label(size: 10)),
        const SizedBox(height: 2),
        Text(value, style: FN.label(size: 17, color: FN.ink)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(segmentListProvider).valueOrNull;
    final segment = list?.where((s) => s.id == segmentId).firstOrNull;
    final efforts =
        ref.watch(segmentEffortsProvider(segmentId)).valueOrNull ??
        const <SegmentEffortRow>[];
    final fmt = ref.watch(fmtProvider);
    final integ = ref.watch(integrationsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(segment?.name ?? 'Segmen')),
      body: PaperBackground(
        child: segment == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
                children: [
                  SizedBox(
                    height: 220,
                    child: integ.routeMap(
                      points: segment.polyline,
                      interactive: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _stat(
                        'JARAK',
                        fmt.distanceFull(segment.distanceM, decimals: 2),
                      ),
                      _stat(
                        'REKOR',
                        segment.bestS == null
                            ? '-'
                            : Fmt.duration(segment.bestS!),
                      ),
                      _stat('UPAYA', '${segment.effortCount}'),
                    ],
                  ),
                  SectionHeader(
                    title: 'Riwayat upaya',
                    padding: const EdgeInsets.only(top: 24, bottom: 6),
                  ),
                  if (efforts.isEmpty)
                    Text(
                      'Belum ada upaya. Lewati segmen ini saat merekam.',
                      style: TextStyle(
                        fontFamily: FN.sans,
                        fontSize: 14,
                        color: FN.inkMuted,
                      ),
                    ),
                  for (final e in efforts)
                    SegmentEffortTile.effort(
                      e,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => integ.activityDetail(e.activityId),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  InkButton(
                    label: 'HAPUS SEGMEN',
                    icon: Icons.delete_outline,
                    style: InkButtonStyle.danger,
                    expand: true,
                    onPressed: () => _delete(context, ref, segment),
                  ),
                ],
              ),
      ),
    );
  }
}
