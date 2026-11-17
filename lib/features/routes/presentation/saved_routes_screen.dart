import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/routes/data/route_providers.dart';
import 'package:virya/features/routes/presentation/route_flow.dart';
import 'package:virya/features/routes/presentation/widgets/saved_route_tile.dart';

/// Daftar rute tersimpan + pintu "Buat rute" dan "Gambar sendiri".
class SavedRoutesScreen extends ConsumerWidget {
  const SavedRoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(savedRoutesProvider);
    return Scaffold(
      appBar: AppBar(),
      body: PaperBackground(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const Masthead(
              kicker: 'Rencana perjalanan',
              title: 'Rute',
              subtitle: 'Buat rute otomatis, gambar sendiri, lalu ikuti saat '
                  'merekam. Rute tersimpan bisa dipakai offline.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: InkButton(
                      label: 'Buat rute',
                      icon: Icons.auto_awesome_outlined,
                      style: InkButtonStyle.primary,
                      expand: true,
                      onPressed: () => RouteFlow.openBuilder(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkButton(
                      label: 'Gambar sendiri',
                      icon: Icons.edit_road,
                      expand: true,
                      onPressed: () => RouteFlow.openEditor(context),
                    ),
                  ),
                ],
              ),
            ),
            SectionHeader(
              title: 'Rute tersimpan',
              trailing: routes.maybeWhen(
                data: (l) => Text('${l.length}',
                    style: FN.label(size: 11, color: FN.inkMuted)),
                orElse: () => null,
              ),
            ),
            ...routes.when(
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (e, _) => [_note('Rute gagal dimuat: $e')],
              data: (list) => list.isEmpty
                  ? [
                      _note('Belum ada rute. Ketuk "Buat rute" untuk '
                          'mendapat tiga pilihan dari titikmu.'),
                    ]
                  : [
                      for (final r in list)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: SavedRouteTile(
                            route: r,
                            onTap: () => RouteFlow.openDetail(context, r),
                          ),
                        ),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _note(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Text(text, style: FN.body(size: 14, color: FN.inkMuted)),
      );
}
