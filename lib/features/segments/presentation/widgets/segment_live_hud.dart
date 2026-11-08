import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/segments/data/live_segment_feed.dart';
import 'package:virya/features/segments/domain/live_segment_tracker.dart';
import 'package:virya/features/segments/domain/segment_cues.dart';

/// Strip segmen di layar rekam. Tingginya tetap, dan peta yang mengecil.
class SegmentLiveHud extends ConsumerWidget {
  const SegmentLiveHud({super.key});

  ({String kicker, String value, String caption, Color color}) _describe(
    LiveSegmentState s,
  ) {
    final plain = FN.onNight;
    final delta = s.ghostDeltaS;
    switch (s.phase) {
      case LiveSegmentPhase.finished:
        final time = Fmt.duration(s.finalTimeS ?? s.elapsedS);
        final isPr = s.isNewPr == true;
        return (
          kicker: isPr ? 'REKOR BARU' : 'SEGMEN SELESAI',
          value: time,
          caption: delta == null
              ? 'GHOST BARU'
              : '${ghostDeltaLabel(delta)} DARI REKOR',
          color: isPr ? FN.acid : plain,
        );
      case LiveSegmentPhase.abandoned:
        return (
          kicker: 'KELUAR DARI SEGMEN',
          value: Fmt.duration(s.elapsedS),
          caption: 'TIDAK DIHITUNG',
          color: FN.warn,
        );
      case LiveSegmentPhase.active:
        final time = Fmt.duration(s.elapsedS);
        if (delta == null) {
          return (
            kicker: 'SEGMEN AKTIF',
            value: time,
            caption: 'UPAYA PERTAMA',
            color: plain,
          );
        }
        final ahead = delta.round() <= 0;
        return (
          kicker: 'SEGMEN AKTIF',
          value: ghostDeltaLabel(delta),
          caption: 'GHOST · $time',
          color: ahead ? FN.acid : FN.warn,
        );
      case LiveSegmentPhase.approaching:
      case LiveSegmentPhase.idle:
        return (
          kicker: 'SEGMEN MENDEKAT',
          value: '${(s.distanceToStartM ?? 0).round()} M',
          caption: 'KE TITIK MULAI',
          color: plain,
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(liveSegmentFeedProvider);
    if (view == null) return const SizedBox.shrink();
    final s = view.state;
    final d = _describe(s);
    final showBar =
        s.phase == LiveSegmentPhase.active ||
        s.phase == LiveSegmentPhase.finished;
    return Container(
      height: 64,
      color: FN.nightSurface,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.kicker,
                          style: FN.label(size: 10, color: FN.onNightMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          view.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FN.sans,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: FN.onNight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        d.value,
                        style: FN.label(size: 20, color: d.color),
                      ),
                      Text(
                        d.caption,
                        style: FN.label(size: 9, color: FN.onNightMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: showBar ? s.fraction : 0,
                heightFactor: 1,
                child: ColoredBox(color: d.color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
