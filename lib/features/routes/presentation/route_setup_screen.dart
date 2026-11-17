import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/maps/widgets/plan_map_view.dart';
import 'package:virya/features/routes/application/route_builder_controller.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/presentation/route_flow.dart';
import 'package:virya/features/routes/presentation/route_options_screen.dart';
import 'package:virya/features/routes/presentation/widgets/route_distance_card.dart';
import 'package:virya/features/routes/presentation/widgets/route_options_card.dart';

/// Langkah 1 "Buat rute": titik mulai, olahraga, jarak, bentuk, pilihan.
class RouteSetupScreen extends ConsumerStatefulWidget {
  const RouteSetupScreen({super.key});

  @override
  ConsumerState<RouteSetupScreen> createState() => _RouteSetupScreenState();
}

class _RouteSetupScreenState extends ConsumerState<RouteSetupScreen> {
  /// Ketukan peta mengisi tujuan (bukan titik mulai).
  bool _pickDest = false;

  RouteBuilderController get _c => ref.read(routeBuilderProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _c.locate());
  }

  Future<void> _generate() async {
    final ok = await _c.generate();
    if (!ok || !mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const RouteOptionsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(routeBuilderProvider);
    final p = s.prefs;
    final needsDest = p.shape == RouteShape.pointToPoint;
    final canDest = p.shape != RouteShape.loop;
    final pickDest = canDest && _pickDest;
    return Scaffold(
      appBar: AppBar(title: Text(FN.caps('Buat rute'))),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            child: PlanMapView(
              center: p.start,
              marks: [
                if (p.start != null) (p.start!, PlanMarkKind.start),
                if (canDest && p.destination != null)
                  (p.destination!, PlanMarkKind.finish),
              ],
              onTap: (ll) => _c.tapMap(ll, asDestination: pickDest),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              children: [
                _startRow(s),
                const SizedBox(height: 12),
                SegmentedPick<RouteSport>(
                  options: [for (final v in RouteSport.values) (v, v.label)],
                  value: p.sport,
                  onChanged: _c.setSport,
                ),
                const SizedBox(height: 12),
                SegmentedPick<RouteShape>(
                  options: [
                    for (final v in RouteShape.values)
                      if (v != RouteShape.manual) (v, v.label),
                  ],
                  value: p.shape,
                  onChanged: (v) {
                    _c.setShape(v);
                    setState(() => _pickDest = v == RouteShape.pointToPoint &&
                        p.destination == null);
                  },
                ),
                if (canDest) ...[
                  const SizedBox(height: 10),
                  _destRow(p, needsDest, pickDest),
                ],
                if (!needsDest) ...[
                  const SizedBox(height: 12),
                  RouteDistanceCard(
                    sport: p.sport,
                    km: p.targetM / 1000,
                    onChanged: _c.setTargetKm,
                  ),
                ],
                const SizedBox(height: 12),
                RouteOptionsCard(
                  prefs: p,
                  onTerrain: _c.setTerrain,
                  onPreferNew: _c.setPreferNew,
                  onAvoidMain: _c.setAvoidMain,
                ),
                if (s.error != null) ...[
                  const SizedBox(height: 12),
                  Text(s.error!, style: FN.body(size: 13, color: FN.warn)),
                ],
                const SizedBox(height: 16),
                InkButton(
                  label: s.loading ? 'Mencari rute…' : 'Buat rute',
                  icon: Icons.auto_awesome_outlined,
                  style: InkButtonStyle.primary,
                  expand: true,
                  busy: s.loading,
                  onPressed: s.loading || p.start == null ? null : _generate,
                ),
                const SizedBox(height: 8),
                Text(
                  'Butuh internet untuk membuat rute. Rute yang disimpan '
                  'tetap bisa diikuti offline.',
                  textAlign: TextAlign.center,
                  style: FN.body(size: 12, color: FN.inkMuted),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => RouteFlow.openEditor(context),
                  icon: Icon(Icons.edit_road, color: FN.inkSoft),
                  label: Text(FN.caps('Gambar sendiri di peta'),
                      style: FN.body(size: 13, color: FN.inkSoft)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _startRow(RouteBuilderState s) {
    final start = s.prefs.start;
    final text = s.locating
        ? 'Mencari lokasimu…'
        : start == null
            ? 'Ketuk peta untuk titik mulai'
            : 'Mulai: ${start.$1.toStringAsFixed(4)}, '
                '${start.$2.toStringAsFixed(4)}';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(FN.caps('Titik mulai'),
                  style: FN.label(size: 11, color: FN.inkMuted)),
              const SizedBox(height: 2),
              Text(text, style: FN.body(size: 14, color: FN.ink)),
            ],
          ),
        ),
        InkIconButton(
          icon: Icons.my_location,
          tooltip: 'Pakai lokasi saat ini',
          size: 36,
          onPressed: s.locating ? null : () => _c.locate(force: true),
        ),
      ],
    );
  }

  Widget _destRow(RoutePrefs p, bool needed, bool picking) {
    final hint = p.destination != null
        ? 'Tujuan: ${p.destination!.$1.toStringAsFixed(4)}, '
            '${p.destination!.$2.toStringAsFixed(4)}'
        : needed
            ? 'Pilih tujuan di peta'
            : 'Tujuan otomatis (atau pilih di peta)';
    return InkBox(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(hint, style: FN.body(size: 13, color: FN.inkSoft)),
          ),
          if (p.destination != null && !needed)
            InkIconButton(
              icon: Icons.close,
              tooltip: 'Tujuan otomatis',
              size: 32,
              onPressed: _c.clearDestination,
            ),
          const SizedBox(width: 6),
          InkButton(
            label: picking ? 'Ketuk peta…' : 'Pilih tujuan',
            height: 34,
            style: picking ? InkButtonStyle.ink : InkButtonStyle.outline,
            onPressed: () => setState(() => _pickDest = !_pickDest),
          ),
        ],
      ),
    );
  }
}
