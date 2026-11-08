import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_footer.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_header.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_menu.dart';

/// Halaman detail untuk aktivitas tanpa GPS (gym): judul, durasi, isi dari
/// modul gym ([content]), lalu hapus. Tanpa peta, grafik, atau ekspor GPX.
class ActivityDetailStrength extends StatelessWidget {
  final Activity activity;
  final SportType sport;
  final Gear? gear;
  final Widget content;
  final VoidCallback onEdit;
  final ValueChanged<String> onMenu;

  const ActivityDetailStrength({
    super.key,
    required this.activity,
    required this.sport,
    required this.gear,
    required this.content,
    required this.onEdit,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final act = activity;
    final start = act.startTime.toLocal();
    final end = act.endTime?.toLocal();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: FN.paper,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(Fmt.dateStamp(act.startTime)),
          actions: [ActivityDetailMenu(onSelected: onMenu, exports: false)],
        ),
        SliverToBoxAdapter(
          child: ActivityDetailHeader(
            activity: act,
            sport: sport,
            gear: gear,
            onEdit: onEdit,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              color: FN.night,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: StatBlock(
                      label: 'Durasi',
                      value: Fmt.duration(act.elapsedTimeSeconds),
                      valueColor: FN.onNight,
                      labelColor: FN.acid,
                      size: 36,
                    ),
                  ),
                  Text(
                    end == null
                        ? Fmt.time(start)
                        : '${Fmt.time(start)}–${Fmt.time(end)}',
                    style: FN.label(size: 10.5, color: FN.onNight),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SectionHeader(number: '01', title: 'Latihan'),
        ),
        SliverToBoxAdapter(child: content),
        SliverToBoxAdapter(
          child: ActivityDetailFooter(
            onDelete: () => onMenu('delete'),
            caption:
                'ID ${act.id.substring(0, 8)} · ${act.source.toUpperCase()}',
          ),
        ),
      ],
    );
  }
}
