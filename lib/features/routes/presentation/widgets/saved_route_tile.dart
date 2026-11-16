import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/routes/data/route_export.dart';
import 'package:virya/features/routes/data/route_providers.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/presentation/widgets/route_dialogs.dart';

enum _Action { rename, export, delete }

/// Satu baris rute tersimpan: gambar kecil, nama, jarak, naik, dan menu.
class SavedRouteTile extends ConsumerWidget {
  const SavedRouteTile({super.key, required this.route, this.onTap});

  final SavedRoute route;
  final VoidCallback? onTap;

  Future<void> _act(BuildContext context, WidgetRef ref, _Action a) async {
    final repo = ref.read(routeRepositoryProvider);
    switch (a) {
      case _Action.rename:
        final name = await routePrompt(context,
            title: 'Ganti nama rute', initial: route.name);
        if (name != null) await repo.rename(route.id, name);
      case _Action.export:
        try {
          await shareRouteGpx(route);
        } catch (_) {
          if (context.mounted) routeToast(context, 'GPX gagal dibagikan.');
        }
      case _Action.delete:
        final ok = await routeConfirm(context,
            title: 'Hapus rute?',
            message: '"${route.name}" akan dihapus dari perangkat ini.');
        if (!ok) return;
        await repo.delete(route.id);
        final active = ref.read(activeRouteProvider);
        if (active?.id == route.id) {
          ref.read(activeRouteProvider.notifier).state = null;
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = ref.watch(fmtProvider);
    final p = route.path;
    return InkBox(
      padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: RouteThumbnail(points: p.points, color: FN.signal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(route.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FN.heading(size: 15, color: FN.ink)),
                const SizedBox(height: 4),
                Text(
                  '${fmt.distanceFull(p.distanceM, decimals: 1)} · '
                  '↑ ${fmt.elevation(p.ascentM)} ${fmt.eleUnit.toLowerCase()}',
                  style: FN.body(size: 13, color: FN.inkSoft),
                ),
                const SizedBox(height: 2),
                Text(FN.caps('${route.sport.label} · ${route.shape.label}'),
                    style: FN.label(size: 10, color: FN.inkMuted)),
              ],
            ),
          ),
          PopupMenuButton<_Action>(
            tooltip: 'Menu rute',
            icon: Icon(Icons.more_vert, color: FN.inkSoft),
            onSelected: (a) => _act(context, ref, a),
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: _Action.rename, child: Text(FN.caps('Ganti nama'))),
              PopupMenuItem(
                  value: _Action.export, child: Text(FN.caps('Ekspor GPX'))),
              PopupMenuItem(
                  value: _Action.delete, child: Text(FN.caps('Hapus'))),
            ],
          ),
        ],
      ),
    );
  }
}
