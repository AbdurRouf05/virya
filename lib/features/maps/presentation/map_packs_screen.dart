import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/core/offline_maps/map_pack.dart';
import 'package:stravo/core/offline_maps/map_pack_repository.dart';

/// Manage offline PMTiles packs (vector basemap + terrain DEM).
class MapPacksScreen extends ConsumerStatefulWidget {
  const MapPacksScreen({super.key});

  @override
  ConsumerState<MapPacksScreen> createState() => _MapPacksScreenState();
}

class _MapPacksScreenState extends ConsumerState<MapPacksScreen> {
  double? _importProgress; // null = idle
  String? _importName;

  MapPackRepository get _repo => ref.read(mapPackRepositoryProvider);

  void _refresh() {
    ref.invalidate(mapPacksStateProvider);
    ref.invalidate(mapConfigProvider);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: FN.ink,
      content: Text(msg, style: FN.label(size: 12, color: FN.paper)),
    ));
  }

  Future<void> _import() async {
    final List<PlatformFile> files;
    try {
      files = await FilePicker.pickFiles(dialogTitle: 'Pilih file .pmtiles');
    } catch (e) {
      _toast('Gagal membuka pemilih file: $e');
      return;
    }
    if (files.isEmpty) return;
    final f = files.first;
    setState(() {
      _importProgress = 0;
      _importName = f.name;
    });
    try {
      final total = f.lengthSync() ?? await f.length();
      final pack = await _repo.importStream(
        f.name,
        f.readAsByteStream(),
        totalBytes: total,
        onProgress: (p) {
          if (mounted) setState(() => _importProgress = p);
        },
      );
      _toast('Terpasang: ${pack.fileName} (${_typeLabel(pack.type)})');
    } on FormatException catch (e) {
      _toast(e.message);
    } catch (e) {
      _toast('Impor gagal: $e');
    } finally {
      if (mounted) {
        setState(() {
          _importProgress = null;
          _importName = null;
        });
      }
      _refresh();
    }
  }

  Future<void> _delete(MapPack pack) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: FN.paper,
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: FN.ink, width: 2)),
        title: Text('HAPUS PAKET?', style: FN.bigNumber(24)),
        content: Text('${pack.fileName}\n${formatBytes(pack.sizeBytes)} akan dihapus.',
            style: const TextStyle(fontFamily: FN.sans, color: FN.inkSoft)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text('BATAL', style: FN.label(color: FN.ink))),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text('HAPUS', style: FN.label(color: FN.warn))),
        ],
      ),
    );
    if (ok != true) return;
    await _repo.delete(pack);
    _refresh();
  }

  Future<void> _activate(MapPack pack, MapPacksState st) async {
    if (pack.type == MapPackType.dem) {
      await _repo.setActiveDem(st.activeDem == pack.fileName ? null : pack.fileName);
    } else {
      await _repo.setActiveBasemap(
          st.activeBasemap == pack.fileName ? null : pack.fileName);
    }
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapPacksStateProvider);
    return Scaffold(
      backgroundColor: FN.paper,
      appBar: AppBar(
        backgroundColor: FN.paper,
        foregroundColor: FN.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('PETA OFFLINE', style: FN.bigNumber(26)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: ColoredBox(color: FN.ink, child: SizedBox(height: 2, width: double.infinity)),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator(color: FN.ink)),
        error: (e, _) => Center(
            child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Gagal memuat paket peta: $e', style: FN.label(color: FN.warn)),
        )),
        data: (st) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            _activeCard(st),
            const SizedBox(height: 12),
            _onlineToggle(st),
            const SizedBox(height: 20),
            _sectionTitle('PAKET TERPASANG', '${st.packs.length}'),
            if (st.packs.isEmpty)
              _box(Text(
                'Belum ada paket. Tanpa paket, peta memakai latar kertas polos '
                '(atau OpenFreeMap bila online & diizinkan).',
                style: const TextStyle(fontFamily: FN.sans, color: FN.inkSoft, height: 1.4),
              )),
            for (final p in st.packs) _packTile(p, st),
            const SizedBox(height: 12),
            _importButton(),
            const SizedBox(height: 28),
            const _Instructions(),
          ],
        ),
      ),
    );
  }

  Widget _box(Widget child, {Color color = FN.paper}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color, border: Border.all(color: FN.ink, width: 1.5)),
        child: child,
      );

  Widget _sectionTitle(String t, [String? trailing]) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text(t, style: FN.label(size: 12, color: FN.ink)),
          const SizedBox(width: 8),
          const Expanded(child: Divider(color: FN.ink, thickness: 1)),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(trailing, style: FN.label(size: 12, color: FN.ink)),
          ],
        ]),
      );

  Widget _activeCard(MapPacksState st) {
    Widget row(String k, String? v, String empty) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(width: 92, child: Text(k, style: FN.label())),
            Expanded(
              child: Text(v ?? empty,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: FN.mono,
                      fontSize: 13,
                      color: v == null ? FN.inkMuted : FN.ink,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        );
    return _box(
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        row('BASEMAP', st.activeBasemap, '— otomatis / tidak ada'),
        row('TERRAIN', st.activeDem, '— otomatis / tidak ada (3D datar)'),
      ]),
      color: FN.paperDeep,
    );
  }

  Widget _onlineToggle(MapPacksState st) => _box(Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PETA ONLINE CADANGAN', style: FN.label(size: 12, color: FN.ink)),
            const SizedBox(height: 4),
            const Text(
              'Bila belum ada basemap offline dan perangkat online, pakai '
              'OpenFreeMap (gaya Field Notes).',
              style: TextStyle(fontFamily: FN.sans, fontSize: 12, color: FN.inkSoft, height: 1.35),
            ),
          ]),
        ),
        Switch(
          value: st.onlineFallback,
          activeThumbColor: FN.paper,
          activeTrackColor: FN.signal,
          inactiveThumbColor: FN.inkMuted,
          inactiveTrackColor: FN.paperDeep,
          onChanged: (v) async {
            await _repo.setOnlineFallback(v);
            _refresh();
          },
        ),
      ]));

  Widget _packTile(MapPack p, MapPacksState st) {
    final active = p.fileName == st.activeBasemap || p.fileName == st.activeDem;
    final h = p.header;
    final meta = [
      formatBytes(p.sizeBytes),
      if (h != null) 'z${h.minZoom}–${h.maxZoom}',
      if (h != null) h.tileType.name.toUpperCase(),
    ].join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: active ? FN.ink : FN.paper,
        border: Border.all(color: FN.ink, width: 1.5),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          color: p.type == MapPackType.dem
              ? FN.ok
              : p.type == MapPackType.basemap
                  ? FN.signal
                  : FN.inkMuted,
          child: Text(_typeLabel(p.type), style: FN.label(size: 9, color: FN.paper)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.fileName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: FN.mono,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? FN.paper : FN.ink)),
            const SizedBox(height: 2),
            Text(meta, style: FN.label(size: 10, color: active ? FN.paperLine : FN.inkMuted)),
          ]),
        ),
        if (p.type != MapPackType.unknown)
          TextButton(
            onPressed: () => _activate(p, st),
            child: Text(active ? 'AKTIF ✓' : 'AKTIFKAN',
                style: FN.label(size: 10, color: active ? FN.acid : FN.ink)),
          ),
        IconButton(
          tooltip: 'Hapus',
          icon: Icon(Icons.delete_outline, color: active ? FN.paper : FN.ink),
          onPressed: _importProgress != null ? null : () => _delete(p),
        ),
      ]),
    );
  }

  Widget _importButton() {
    final prog = _importProgress;
    if (prog != null) {
      return _box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MENYALIN ${_importName ?? ''}'.toUpperCase(),
            overflow: TextOverflow.ellipsis, style: FN.label(size: 11, color: FN.ink)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: prog > 0 ? prog : null,
          minHeight: 6,
          color: FN.signal,
          backgroundColor: FN.paperDeep,
        ),
        const SizedBox(height: 6),
        Text('${(prog * 100).toStringAsFixed(0)}%', style: FN.bigNumber(22)),
      ]));
    }
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: FN.ink,
          foregroundColor: FN.paper,
          shape: const RoundedRectangleBorder(),
        ),
        onPressed: _import,
        icon: const Icon(Icons.file_download_outlined),
        label: Text('IMPOR FILE .PMTILES', style: FN.label(size: 13, color: FN.paper)),
      ),
    );
  }
}

String _typeLabel(MapPackType t) => switch (t) {
      MapPackType.basemap => 'BASEMAP',
      MapPackType.dem => 'TERRAIN',
      MapPackType.unknown => 'TAK DIKENAL',
    };

class _Instructions extends StatelessWidget {
  const _Instructions();

  static const _basemapCmd =
      'pmtiles extract https://build.protomaps.com/20261101.pmtiles jawa.pmtiles '
      '--bbox=105.0,-8.9,114.7,-5.8 --maxzoom=15';
  static const _demCmd1 =
      'aws s3 sync --no-sign-request s3://elevation-tiles-prod/terrarium/ ./terrarium '
      '--exclude "*" --include "5/*" ... (z5–12 area Jawa)';
  static const _demCmd2 =
      'mb-util --image_format=png ./terrarium jawa.dem.mbtiles\n'
      'pmtiles convert jawa.dem.mbtiles jawa.dem.pmtiles';

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(fontFamily: FN.sans, fontSize: 13, color: FN.inkSoft, height: 1.45);
    Widget h(String t) => Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(t, style: FN.label(size: 12, color: FN.ink)),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('CARA MENDAPATKAN PAKET', style: FN.label(size: 12, color: FN.ink)),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: FN.ink, thickness: 1)),
      ]),
      const SizedBox(height: 6),
      const Text(
        'Semua peta berjalan 100% offline dari file PMTiles di ponsel. Siapkan '
        'file di komputer, salin ke ponsel (USB / kabel data / Drive), lalu tekan '
        '"IMPOR FILE .PMTILES".',
        style: body,
      ),
      h('1 · BASEMAP VEKTOR (PROTOMAPS)'),
      const Text(
        'Pasang CLI "pmtiles" (github.com/protomaps/go-pmtiles). Lihat tanggal '
        'build terbaru di maps.protomaps.com/builds, lalu potong area yang '
        'dibutuhkan (contoh: Pulau Jawa, ± 1–2 GB):',
        style: body,
      ),
      const _Code(_basemapCmd),
      const Text(
        'Ganti tanggal 20261101 dengan build terbaru. Perkecil --bbox atau '
        '--maxzoom=14 agar file lebih kecil.',
        style: body,
      ),
      h('2 · TERRAIN 3D (OPSIONAL)'),
      const Text(
        'Unduh ubin elevasi Terrarium gratis dari AWS Open Data '
        '(s3://elevation-tiles-prod/terrarium) untuk zoom ≤ 12 di area yang '
        'sama, kemudian kemas menjadi PMTiles. Nama file WAJIB berakhiran '
        '.dem.pmtiles:',
        style: body,
      ),
      const _Code(_demCmd1),
      const _Code(_demCmd2),
      const Text(
        'Tanpa terrain, flyover tetap jalan dengan kamera miring di atas peta datar. '
        'Tanpa basemap, rute digambar di atas kertas polos.',
        style: body,
      ),
      h('3 · LISENSI'),
      const Text('Data peta © kontributor OpenStreetMap (ODbL). Elevasi: Mapzen/AWS Terrain Tiles.',
          style: body),
    ]);
  }
}

class _Code extends StatelessWidget {
  const _Code(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: FN.ink,
            content: Text('Perintah disalin', style: FN.label(size: 12, color: FN.paper)),
          ));
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          color: FN.night,
          child: SelectableText(
            text,
            style: const TextStyle(fontFamily: FN.mono, fontSize: 11.5, color: FN.acid, height: 1.4),
          ),
        ),
      );
}
