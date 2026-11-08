import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/heatmap/application/heatmap_providers.dart';
import 'package:virya/features/heatmap/domain/heatmap_builder.dart';
import 'package:virya/features/heatmap/presentation/widgets/heatmap_filter_bar.dart';
import 'package:virya/features/heatmap/presentation/widgets/heatmap_note.dart';

/// "HEATMAP": semua jalur GPS digabung di satu peta, dihitung di perangkat.
class HeatmapScreen extends ConsumerStatefulWidget {
  const HeatmapScreen({super.key});

  @override
  ConsumerState<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends ConsumerState<HeatmapScreen> {
  HeatmapFilter _filter = HeatmapFilter.all;

  /// Hasil terakhir tetap tampil selama filter baru dihitung.
  HeatmapResult? _shown;

  void _retry() {
    ref.invalidate(heatmapTracksProvider);
    ref.invalidate(heatmapProvider(_filter));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(heatmapProvider(_filter));
    if (async.hasValue && !async.isLoading) _shown = async.value;
    final result = _shown;
    return Scaffold(
      appBar: AppBar(title: const Text('HEATMAP')),
      body: PaperBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            HeatmapFilterBar(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Text(
                _summary(async, result),
                style: FN.label(size: 11, color: FN.inkSoft),
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ref
                      .watch(integrationsProvider)
                      .heatmapView(points: result?.points ?? const []),
                  ?_overlay(async, result),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _summary(AsyncValue<HeatmapResult> async, HeatmapResult? result) {
    if (async.isLoading) return 'MENGHITUNG JALUR...';
    if (async.hasError || result == null || result.isEmpty) return ' ';
    return '${result.trackCount} AKTIVITAS · '
        'TERSERING ${result.maxCount}× LEWAT';
  }

  Widget? _overlay(AsyncValue<HeatmapResult> async, HeatmapResult? result) {
    if (async.isLoading) return null;
    if (async.hasError) {
      return HeatmapNote(
        title: 'HEATMAP GAGAL DIHITUNG',
        message: 'Data jalurmu tetap aman. Coba hitung sekali lagi.',
        actionLabel: 'COBA LAGI',
        onAction: _retry,
      );
    }
    if (result == null || !result.isEmpty) return null;
    final what = _filter == HeatmapFilter.all
        ? 'Rekam atau impor aktivitas GPS'
        : 'Rekam aktivitas ${_filter.label.toLowerCase()}';
    return HeatmapNote(
      title: 'BELUM ADA JALUR',
      message: '$what, nanti jalurnya muncul di sini.',
    );
  }
}
