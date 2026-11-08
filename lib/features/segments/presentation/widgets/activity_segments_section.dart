import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/segments/data/segment_providers.dart';
import 'package:virya/features/segments/presentation/segment_create_screen.dart';
import 'package:virya/features/segments/presentation/segment_detail_screen.dart';
import 'package:virya/features/segments/presentation/widgets/segment_effort_tile.dart';

/// Segmen yang dilewati aktivitas ini, dan tombol membuat segmen baru.
class ActivitySegmentsSection extends ConsumerWidget {
  final String activityId;
  const ActivitySegmentsSection({super.key, required this.activityId});

  void _push(BuildContext context, Widget page) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(activitySegmentsProvider(activityId)).valueOrNull;
    final fmt = ref.watch(fmtProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in rows ?? const [])
          SegmentEffortTile(
            title: r.segmentName,
            subtitle: fmt.distanceFull(r.distanceM, decimals: 2),
            elapsedS: r.elapsedS,
            isBest: r.isBest,
            onTap: () => _push(
              context,
              SegmentDetailScreen(segmentId: r.segmentId),
            ),
          ),
        const SizedBox(height: 8),
        InkButton(
          label: 'BUAT SEGMEN DARI RUTE INI',
          icon: Icons.flag_outlined,
          expand: true,
          onPressed: () => _push(
            context,
            SegmentCreateScreen(activityId: activityId),
          ),
        ),
      ],
    );
  }
}
