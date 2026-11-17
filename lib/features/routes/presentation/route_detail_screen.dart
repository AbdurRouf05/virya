import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/maps/widgets/plan_map_view.dart';
import 'package:virya/features/routes/data/route_export.dart';
import 'package:virya/features/routes/data/route_providers.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/presentation/route_flow.dart';
import 'package:virya/features/routes/presentation/widgets/route_dialogs.dart';
import 'package:virya/features/routes/presentation/widgets/route_elevation_card.dart';
import 'package:virya/features/routes/presentation/widgets/route_stats_card.dart';

/// Langkah 3: detail rute — peta, angka, ketinggian, edit/simpan/mulai.
class RouteDetailScreen extends ConsumerStatefulWidget {
  const RouteDetailScreen({super.key, required this.route, this.trait});

  /// `id` kosong berarti belum disimpan.
  final SavedRoute route;
  final String? trait;

  @override
  ConsumerState<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends ConsumerState<RouteDetailScreen> {
  late SavedRoute _r = widget.route;
  bool _dirty = false;
  bool _saving = false;

  bool get _saved => _r.id.isNotEmpty && !_dirty;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final saved = await ref.read(routeRepositoryProvider).save(_r);
      if (!mounted) return;
      setState(() {
        _r = saved;
        _dirty = false;
      });
      routeToast(context, 'Rute disimpan.');
    } catch (_) {
      if (mounted) routeToast(context, 'Rute gagal disimpan.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _rename() async {
    final name =
        await routePrompt(context, title: 'Nama rute', initial: _r.name);
    if (name == null || !mounted) return;
    setState(() => _r = _r.copyWith(name: name));
    if (_r.id.isNotEmpty && !_dirty) {
      await ref.read(routeRepositoryProvider).rename(_r.id, name);
    }
  }

  Future<void> _edit() async {
    final edited = await RouteFlow.openEditor(context, route: _r);
    if (edited == null || !mounted) return;
    setState(() {
      _r = edited;
      _dirty = true;
    });
  }

  Future<void> _start() async {
    if (_r.id.isEmpty || _dirty) await _save();
    if (!mounted) return;
    RouteFlow.startRecording(context, ref, _r);
  }

  @override
  Widget build(BuildContext context) {
    final r = _r;
    final pts = r.path.points;
    final sub = [
      r.sport.label,
      if (widget.trait != null && widget.trait!.isNotEmpty && !_dirty)
        widget.trait!.toLowerCase(),
      if (!_saved) 'belum disimpan',
    ].join(' · ');
    return Scaffold(
      appBar: AppBar(
        title: Text(FN.caps('Detail rute')),
        actions: [
          IconButton(
            tooltip: 'Ekspor GPX',
            icon: const Icon(Icons.ios_share),
            onPressed: () => shareRouteGpx(r).catchError((_) {
              if (context.mounted) routeToast(context, 'GPX gagal dibagikan.');
            }),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SizedBox(
            height: 240,
            child: PlanMapView(
              route: pts,
              marks: [
                if (pts.isNotEmpty) (pts.first, PlanMarkKind.start),
                if (pts.length > 1 && pts.last != pts.first)
                  (pts.last, PlanMarkKind.finish),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _rename,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(r.name,
                            style: FN.heading(size: 20, color: FN.ink)),
                      ),
                      Icon(Icons.edit_outlined, size: 16, color: FN.inkMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(FN.caps(sub),
                    style: FN.label(size: 11, color: FN.inkMuted)),
                const SizedBox(height: 12),
                RouteStatsCard(route: r),
                const SizedBox(height: 12),
                RouteElevationCard(path: r.path),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: InkButton(
                        label: 'Edit',
                        icon: Icons.edit_road,
                        expand: true,
                        onPressed: _edit,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkButton(
                        label: _saved ? 'Tersimpan' : 'Simpan',
                        icon: _saved ? Icons.check : Icons.bookmark_outline,
                        expand: true,
                        busy: _saving,
                        onPressed: _saved || _saving ? null : _save,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                InkButton(
                  label: 'Mulai rekam dengan rute ini',
                  icon: Icons.play_arrow,
                  style: InkButtonStyle.primary,
                  expand: true,
                  onPressed: _saving ? null : _start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
