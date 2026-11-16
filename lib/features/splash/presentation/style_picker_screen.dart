import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/styles/styles.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/splash/presentation/widgets/gaya_choice_card.dart';

/// Layar pilih gaya, sekali saat aplikasi pertama dibuka. Menyentuh kartu
/// langsung mengganti gaya seluruh aplikasi (termasuk layar ini);
/// "Lanjut" menyimpan pilihan dan masuk ke Beranda.
class StylePickerScreen extends ConsumerWidget {
  const StylePickerScreen({super.key});

  static const _about = {
    UiGaya.tegas:
        'Garis tinta tebal dan huruf poster, seperti buku catatan '
        'lapangan.',
    UiGaya.bersih:
        'Tenang dan rapi: kartu putih, sudut membulat, angka '
        'yang mudah dibaca.',
  };

  void _pick(WidgetRef ref, UiGaya g) {
    if (g == ref.read(uiGayaProvider)) return;
    // Ganti gaya membangun ulang aplikasi; jangan putar layar pembuka lagi.
    ref.read(skipEntryProvider.notifier).state = true;
    ref.read(settingsProvider.notifier).set(SettingKeys.uiGaya, g.name);
  }

  void _mode(WidgetRef ref, BersihMode m) {
    ref.read(skipEntryProvider.notifier).state = true;
    ref.read(settingsProvider.notifier).set(SettingKeys.bersihMode, m.name);
  }

  Future<void> _done(WidgetRef ref) async {
    final s = ref.read(settingsProvider.notifier);
    await s.set(SettingKeys.uiGaya, ref.read(uiGayaProvider).name);
    await s.set(SettingKeys.lookChosen, 'true');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gaya = ref.watch(uiGayaProvider);
    final mode = ref.watch(bersihModeProvider);
    final tegas = styleById(ref.watch(styleIdProvider));
    final bersih = resolveStyle(
      styleId: null,
      gaya: UiGaya.bersih,
      mode: mode,
      platform: MediaQuery.platformBrightnessOf(context),
    );
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            children: [
              Text(FN.caps('Selamat datang'), style: FN.label(size: 11)),
              const SizedBox(height: 6),
              Text('Pilih gaya', style: FN.title(44, height: 1.0)),
              const SizedBox(height: 8),
              Text(
                'Isi aplikasinya sama, hanya tampilannya yang berbeda.',
                style: FN.body(size: 14, color: FN.inkSoft),
              ),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final g in UiGaya.values) ...[
                      if (g != UiGaya.values.first) const SizedBox(width: 12),
                      Expanded(
                        child: GayaChoiceCard(
                          gaya: g,
                          preview: g == UiGaya.tegas ? tegas : bersih,
                          about: _about[g]!,
                          selected: g == gaya,
                          onTap: () => _pick(ref, g),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (gaya == UiGaya.bersih) ...[
                const SizedBox(height: 4),
                Text(FN.caps('Kecerahan'), style: FN.label(size: 10)),
                const SizedBox(height: 6),
                SegmentedPick<BersihMode>(
                  options: [for (final m in BersihMode.values) (m, m.label)],
                  value: mode,
                  onChanged: (m) => _mode(ref, m),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Bisa diubah nanti di Pengaturan → Tampilan.',
                style: FN.label(size: 10),
              ),
              const SizedBox(height: 20),
              InkButton(
                label: FN.caps('Lanjut'),
                icon: Icons.arrow_forward,
                style: InkButtonStyle.primary,
                expand: true,
                onPressed: () => _done(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
