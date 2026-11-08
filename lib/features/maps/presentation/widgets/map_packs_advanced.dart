import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/offline_maps/map_pack.dart';
import 'package:virya/core/offline_maps/map_pack_repository.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_active_card.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_box.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_confirm.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_guide.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_import_button.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_online_toggle.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_pack_tile.dart';
import 'package:virya/features/maps/presentation/widgets/map_packs_section_title.dart';

/// Collapsed "Lanjutan" section: internet toggle + PMTiles packs + guide.
class MapPacksAdvanced extends ConsumerStatefulWidget {
  const MapPacksAdvanced({super.key});

  @override
  ConsumerState<MapPacksAdvanced> createState() => _MapPacksAdvancedState();
}

class _MapPacksAdvancedState extends ConsumerState<MapPacksAdvanced> {
  double? _importProgress; // null = idle
  String? _importName;

  MapPackRepository get _repo => ref.read(mapPackRepositoryProvider);

  void _refresh() {
    ref.invalidate(mapPacksStateProvider);
    ref.invalidate(mapConfigProvider);
  }

  void _toast(String msg) {
    if (mounted) mapToast(context, msg);
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
    final ok = await confirmMapDelete(context,
        title: 'HAPUS PAKET?',
        body: '${pack.fileName}\n${formatBytes(pack.sizeBytes)} akan dihapus.');
    if (!ok) return;
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
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: FN.paper.withValues(alpha: 0)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 4),
        iconColor: FN.ink,
        collapsedIconColor: FN.ink,
        title: Text('LANJUTAN', style: FN.label(size: 12, color: FN.ink)),
        subtitle: Text('Mode data internet & file .pmtiles sendiri',
            style: FN.label(size: 10)),
        children: [
          state.when(
            loading: () => Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(color: FN.ink),
            ),
            error: (e, _) =>
                Text('Gagal memuat paket peta: $e', style: FN.label(color: FN.warn)),
            data: _content,
          ),
        ],
      ),
    );
  }

  Widget _content(MapPacksState st) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MapPacksOnlineToggle(
            value: st.onlineFallback,
            onChanged: (v) async {
              await _repo.setOnlineFallback(v);
              _refresh();
            },
          ),
          const SizedBox(height: 20),
          MapPacksSectionTitle('PAKET .PMTILES', trailing: '${st.packs.length}'),
          if (st.packs.isEmpty)
            MapPacksBox(
              child: Text(
                'Opsional. Paket PMTiles (Protomaps) menggantikan peta online, '
                'dan paket .dem.pmtiles menambah terrain 3D untuk flyover.',
                style: TextStyle(fontFamily: FN.sans, color: FN.inkSoft, height: 1.4),
              ),
            )
          else
            MapPacksActiveCard(state: st),
          const SizedBox(height: 8),
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
