import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/offline_maps/map_pack_repository.dart';
import 'package:virya/features/maps/widgets/virya_map_controller.dart';

/// Peta MapLibre dengan layer heatmap. [points] berbobot 0 sampai 1.
/// Sumber petanya sama dengan peta lain, jadi ikut paket offline.
class HeatmapMapView extends ConsumerWidget {
  const HeatmapMapView({super.key, required this.points});

  final List<(double lat, double lon, double weight)> points;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blank = ColoredBox(color: FN.paper);
    if (!mapWebViewSupported) return blank;
    return ref.watch(mapConfigProvider).maybeWhen(
      data: (c) => _WebHeatmap(
        key: ValueKey(c.toJson().toString()),
        points: points,
        config: c,
      ),
      orElse: () => blank,
    );
  }
}

class _WebHeatmap extends StatefulWidget {
  const _WebHeatmap({super.key, required this.points, required this.config});

  final List<(double, double, double)> points;
  final MapConfig config;

  @override
  State<_WebHeatmap> createState() => _WebHeatmapState();
}

class _WebHeatmapState extends State<_WebHeatmap> {
  late final ViryaMapController _map;

  @override
  void initState() {
    super.initState();
    _map = ViryaMapController.create(config: widget.config);
    _send();
  }

  void _send() {
    final flat = <double>[
      for (final (lat, lon, weight) in widget.points) ...[lat, lon, weight],
    ];
    _map.call('setHeat', [flat, true]);
  }

  @override
  void didUpdateWidget(_WebHeatmap old) {
    super.didUpdateWidget(old);
    if (!identical(old.points, widget.points)) _send();
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ViryaMapWebView(controller: _map);
}
