import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/core/models/track_sample.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/segments/data/segment_providers.dart';
import 'package:virya/features/segments/domain/route_measure.dart';
import 'package:virya/features/segments/presentation/segment_detail_screen.dart';
import 'package:virya/features/segments/presentation/widgets/segment_range_picker.dart';
import 'package:virya/features/segments/presentation/widgets/segment_route_preview.dart';

/// Memotong rute aktivitas menjadi segmen bernama.
class SegmentCreateForm extends ConsumerStatefulWidget {
  final List<TrackSample> samples;
  final String sportType;

  const SegmentCreateForm({
    super.key,
    required this.samples,
    required this.sportType,
  });

  @override
  ConsumerState<SegmentCreateForm> createState() => _SegmentCreateFormState();
}

class _SegmentCreateFormState extends ConsumerState<SegmentCreateForm> {
  late final RouteMeasure _route = RouteMeasure.fromSamples(widget.samples);
  late RangeValues _range = RangeValues(
    _route.lengthM * 0.25,
    _route.lengthM * 0.75,
  );
  final _name = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final line = _route.slice(_range.start, _range.end);
    final error =
        segmentDraftError(_name.text, _range.end - _range.start) ??
        (line.length < 2 ? 'Titik GPS di bagian ini terlalu jarang.' : null);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final (id, found) = await ref
          .read(segmentRepositoryProvider)
          .create(name: _name.text, polyline: line, sportType: widget.sportType);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ditemukan $found upaya.')));
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SegmentDetailScreen(segmentId: id),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Segmen gagal disimpan.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_route.lengthM < minSegmentLengthM) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Rute ini terlalu pendek untuk dijadikan segmen.',
          style: TextStyle(fontFamily: FN.sans, fontSize: 14, color: FN.inkMuted),
        ),
      );
    }
    final fmt = ref.watch(fmtProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
      children: [
        InkBox(
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 240,
            child: SegmentRoutePreview(
              points: _route.points,
              startIndex: _route.indexAt(_range.start),
              endIndex: _route.indexAt(_range.end),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SegmentRangePicker(
          lengthM: _route.lengthM,
          values: _range,
          fmt: fmt,
          onChanged: (v) => setState(() => _range = v),
        ),
        const SizedBox(height: 12),
        Text(
          'PANJANG ${fmt.distanceFull(_range.end - _range.start, decimals: 2)}',
          style: FN.label(size: 11, color: FN.ink),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _name,
          maxLength: 40,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nama segmen'),
        ),
        if (_error != null) ...[
          Text(_error!, style: FN.label(size: 12, color: FN.warn)),
          const SizedBox(height: 12),
        ],
        InkButton(
          label: 'SIMPAN SEGMEN',
          icon: Icons.check,
          style: InkButtonStyle.primary,
          expand: true,
          busy: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}
