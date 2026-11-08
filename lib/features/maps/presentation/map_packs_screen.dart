import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/offline_maps/map_pack.dart';
import 'package:virya/core/offline_maps/map_pack_repository.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_active_card.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_box.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_guide.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_import_button.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_online_toggle.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_pack_tile.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_section_title.dart';

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
      _toast('Terpasang: ${pack.fileName} (${mapPackTypeLabel(pack.type)})');
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
        shape: RoundedRectangleBorder(side: BorderSide(color: FN.ink, width: 2)),
        title: Text('HAPUS PAKET?', style: FN.bigNumber(24)),
        content: Text('${pack.fileName}\n${formatBytes(pack.sizeBytes)} akan dihapus.',
            style: TextStyle(fontFamily: FN.sans, color: FN.inkSoft)),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: ColoredBox(
              color: FN.ink, child: const SizedBox(height: 2, width: double.infinity)),
        ),
      ),
      body: state.when(
        loading: () => Center(child: CircularProgressIndicator(color: FN.ink)),
        error: (e, _) => Center(
            child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Gagal memuat paket peta: $e', style: FN.label(color: FN.warn)),
        )),
        data: _content,
      ),
    );
  }

  Widget _content(MapPacksState st) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          MapPacksActiveCard(state: st),
          const SizedBox(height: 12),
          MapPacksOnlineToggle(
            value: st.onlineFallback,
            onChanged: (v) async {
              await _repo.setOnlineFallback(v);
              _refresh();
            },
          ),
          const SizedBox(height: 20),
          MapPacksSectionTitle('PAKET TERPASANG', trailing: '${st.packs.length}'),
          if (st.packs.isEmpty)
            MapPacksBox(
              child: Text(
                'Belum ada paket. Tanpa paket, peta memakai latar kertas polos '
                '(atau OpenFreeMap bila online & diizinkan).',
                style: TextStyle(fontFamily: FN.sans, color: FN.inkSoft, height: 1.4),
              ),
            ),
          for (final p in st.packs)
            MapPacksPackTile(
              pack: p,
              active: p.fileName == st.activeBasemap || p.fileName == st.activeDem,
              onActivate: () => _activate(p, st),
              onDelete: _importProgress != null ? null : () => _delete(p),
            ),
          const SizedBox(height: 12),
          MapPacksImportButton(
            progress: _importProgress,
            fileName: _importName,
            onImport: _import,
          ),
          const SizedBox(height: 28),
          const MapPacksGuide(),
        ],
      );
}
