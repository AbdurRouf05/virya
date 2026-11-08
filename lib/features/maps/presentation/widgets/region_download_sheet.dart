import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/offline_maps/map_pack.dart' show formatBytes;
import 'package:virya/core/offline_maps/offline_region.dart';
import 'package:virya/core/offline_maps/offline_tiles.dart';
import 'package:virya/core/offline_maps/region_downloader.dart';
import 'package:virya/core/offline_maps/tile_math.dart';
import 'package:virya/features/maps/data/current_position.dart';

/// Bottom sheet: pick a radius around the current GPS position, see the
/// estimate, confirm. Pops with the [OfflineRegion] to download.
class RegionDownloadSheet extends StatefulWidget {
  const RegionDownloadSheet({super.key});

  static Future<OfflineRegion?> show(BuildContext context) =>
      showModalBottomSheet<OfflineRegion>(
        context: context,
        isScrollControlled: true,
        backgroundColor: FN.paper,
        shape: const RoundedRectangleBorder(),
        builder: (_) => const RegionDownloadSheet(),
      );

  @override
  State<RegionDownloadSheet> createState() => _RegionDownloadSheetState();
}

class _RegionDownloadSheetState extends State<RegionDownloadSheet> {
  static const _radii = [10, 25, 50, 100];
  int _radius = 25;
  (double, double)? _pos;
  String? _error;
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locate();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    try {
      final pos = await currentLatLon();
      if (mounted) setState(() => _pos = pos);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  GeoBounds? get _bounds {
    final pos = _pos;
    return pos == null ? null : boundsAround(pos.$1, pos.$2, _radius.toDouble());
  }

  int get _tiles {
    final b = _bounds;
    return b == null
        ? 0
        : countTiles(b, OfflineTiles.regionMinZoom, OfflineTiles.regionMaxZoom);
  }

  void _submit() {
    final b = _bounds;
    if (b == null) return;
    final name = _name.text.trim();
    Navigator.pop(
      context,
      OfflineRegion(
        id: const Uuid().v4(),
        name: name.isEmpty ? 'Sekitar posisi · $_radius km' : name,
        bounds: b,
        minZoom: OfflineTiles.regionMinZoom,
        maxZoom: OfflineTiles.regionMaxZoom,
        tileCount: _tiles,
        sizeBytes: 0,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles;
    final tooMany = tiles > RegionDownloader.maxTiles;
    final body = TextStyle(fontFamily: FN.sans, fontSize: 13, color: FN.inkSoft, height: 1.4);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('UNDUH WILAYAH', style: FN.bigNumber(26)),
        const SizedBox(height: 4),
        Text('Area persegi di sekitar posisi kamu sekarang, detail sampai '
            'tingkat jalan setapak.', style: body),
        const SizedBox(height: 14),
        Text('JARAK DARI POSISI', style: FN.label(size: 11, color: FN.ink)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, children: [
          for (final r in _radii)
            ChoiceChip(
              label: Text('$r km', style: FN.label(size: 12,
                  color: r == _radius ? FN.paper : FN.ink)),
              selected: r == _radius,
              showCheckmark: false,
              selectedColor: FN.ink,
              backgroundColor: FN.paper,
              shape: RoundedRectangleBorder(side: BorderSide(color: FN.ink)),
              onSelected: (_) => setState(() => _radius = r),
            ),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: _name,
          style: TextStyle(fontFamily: FN.sans, color: FN.ink),
          decoration: InputDecoration(
            labelText: 'Nama wilayah (opsional)',
            hintText: 'Sekitar posisi · $_radius km',
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        const SizedBox(height: 12),
        _estimate(tiles, tooMany, body),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: FN.ink, foregroundColor: FN.paper,
                shape: const RoundedRectangleBorder()),
            onPressed: _pos == null || tooMany ? null : _submit,
            icon: const Icon(Icons.download),
            label: Text('MULAI UNDUH', style: FN.label(size: 13, color: FN.paper)),
          ),
        ),
      ]),
    );
  }

  Widget _estimate(int tiles, bool tooMany, TextStyle body) {
    if (_error != null) {
      return Text(_error!, style: body.copyWith(color: FN.warn));
    }
    if (_pos == null) {
      return Row(children: [
        SizedBox(width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: FN.ink)),
        const SizedBox(width: 10),
        Text('Mencari posisi GPS…', style: body),
      ]);
    }
    if (tooMany) {
      return Text('Terlalu besar ($tiles ubin, maks ${RegionDownloader.maxTiles}). '
          'Pilih jarak lebih kecil.', style: body.copyWith(color: FN.warn));
    }
    return Text(
      '± $tiles ubin · perkiraan ${formatBytes(estimateBytes(tiles))}. '
      'Sebaiknya pakai Wi-Fi.',
      style: body.copyWith(color: FN.ink),
    );
  }
}
