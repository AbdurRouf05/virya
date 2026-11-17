import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/focus/data/focus_bridge.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

TextStyle _small(Color color) =>
    TextStyle(fontFamily: FN.sans, fontSize: 11.5, color: color, height: 1.4);

/// Menjelaskan izin yang belum diberikan dan membuka layar Pengaturan-nya.
class FocusPermissionPanel extends ConsumerWidget {
  final FocusPermissions permissions;
  const FocusPermissionPanel({super.key, required this.permissions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridge = ref.read(focusBridgeProvider);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: FN.frame(color: FN.ink, width: 2), borderRadius: FN.boxRadius,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            FN.caps('Izin yang dibutuhkan'),
            style: FN
                .label(size: 11, color: FN.ink)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          if (!permissions.usageAccess)
            _Row(
              step: 1,
              title: 'Akses penggunaan',
              purpose:
                  'Untuk menghitung berapa lama tiap aplikasi dipakai hari ini.',
              onOpen: bridge.openUsageSettings,
            ),
          if (!permissions.canBlock)
            _Row(
              step: permissions.usageAccess ? 1 : 2,
              title: 'Tampil di atas aplikasi lain',
              purpose:
                  'Untuk memunculkan layar "Waktu habis" di atas aplikasi yang '
                  'jatahnya habis. Tanpa izin ini Virya hanya mencatat waktu, '
                  'tidak bisa menghentikan.',
              onOpen: bridge.openOverlaySettings,
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(left: FN.stripe(FN.signal, width: 3)),
              color: FN.paperDeep,
            ),
            child: Text(
              'Aman untuk m-banking: kedua izin ini tidak memakai Aksesibilitas, '
              'jadi SeaBank, BCA, dan aplikasi bank lain tetap bisa dibuka.',
              style: _small(FN.inkSoft),
            ),
          ),
          const SizedBox(height: 12),
          _RestrictedHelp(onOpenAppInfo: bridge.openAppSettings),
        ],
      ),
    );
  }
}

/// Cara membuka izin yang terkunci "Restricted Setting" (Android 13+).
class _RestrictedHelp extends StatelessWidget {
  final VoidCallback onOpenAppInfo;
  const _RestrictedHelp({required this.onOpenAppInfo});

  @override
  Widget build(BuildContext context) {
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        text,
        style: FN
            .label(size: 9.5, color: FN.ink)
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(10),
      color: FN.paperDeep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: FN.signal),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  FN.caps('Tombol di pengaturan abu-abu?'),
                  style: FN
                      .label(size: 9.5, color: FN.ink)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Kalau tertulis "Controlled by Restricted Setting" (Dikontrol oleh '
            'Setelan Terbatas), Android 13 ke atas sedang mengunci izin untuk '
            'aplikasi yang dipasang di luar Play Store. Ini aturan Android, '
            'bukan kerusakan Virya.',
            style: _small(FN.inkSoft),
          ),
          heading(FN.caps('Cara 1 · tanpa laptop')),
          _Steps(const [
            'Tekan sekali tombol izinnya sampai muncul pesan "App was denied access", lalu tutup. Langkah ini wajib.',
            'Tekan "Buka info aplikasi" di bawah.',
            'Tekan ⋮ di pojok kanan atas, lalu pilih "Izinkan setelan terbatas". Di sebagian HP pilihan ini ada di bagian paling bawah halaman.',
            'Masukkan PIN, kembali ke sini, lalu nyalakan izinnya lagi.',
          ]),
          heading(FN.caps('Cara 2 · kalau menu itu tidak ada')),
          Text(
            'Sebagian HP (misalnya Infinix, Tecno, dan sebagian Xiaomi) '
            'menyembunyikan menu itu. Pasang ulang Virya lewat kabel USB dari '
            'laptop (ADB) di atas versi yang sekarang, datamu tetap aman. '
            'Langkah lengkapnya ada di README GitHub Virya, bagian '
            '"Cara Pasang", Langkah 4.',
            style: _small(FN.inkSoft),
          ),
          const SizedBox(height: 10),
          InkButton(
            label: 'Buka info aplikasi',
            height: 36,
            onPressed: onOpenAppInfo,
          ),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  final List<String> steps;
  const _Steps(this.steps);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < steps.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 16,
                child: Text('${i + 1}.', style: _small(FN.inkSoft)),
              ),
              Expanded(child: Text(steps[i], style: _small(FN.inkSoft))),
            ],
          ),
        ),
    ],
  );
}

/// Status penjaga yang sedang aktif: Ramah Bank (overlay) atau Aksesibilitas.
class FocusModeBanner extends ConsumerWidget {
  final FocusPermissions permissions;
  const FocusModeBanner({super.key, required this.permissions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridge = ref.read(focusBridgeProvider);
    final isBankSafe = permissions.isBankSafe;
    final color = isBankSafe ? FN.signal : FN.warn;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FN.paperDeep,
        border: Border(
          left: FN.stripe(color, width: 3),
          top: FN.side(color: FN.paperLine),
          right: FN.side(color: FN.paperLine),
          bottom: FN.side(color: FN.paperLine),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isBankSafe ? Icons.shield_outlined : Icons.lock_clock_outlined,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBankSafe
                      ? FN.caps('Mode ramah m-banking aktif')
                      : FN.caps('Mode tutup paksa (aksesibilitas)'),
                  style: FN
                      .label(size: 10, color: FN.ink)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isBankSafe
                ? 'Virya memeriksa aplikasi yang sedang terbuka setiap 3 detik '
                      'dan memunculkan layar "Waktu habis" di atasnya. Selama '
                      'penjaga berjalan ada notifikasi kecil "Fokus aktif", '
                      'jangan dimatikan. Kalau layar penghalang tidak muncul, '
                      'atur Baterai Virya ke "Tidak dibatasi".'
                : 'Saat waktu habis, aplikasi langsung ditutup ke layar utama '
                      'lalu layar "Waktu habis" muncul. Sebagian aplikasi '
                      'm-banking menolak dibuka selama Aksesibilitas aktif.',
            style: _small(FN.inkMuted),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: bridge.openAccessibilitySettings,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                isBankSafe
                    ? 'Mau lebih ketat? Pakai Aksesibilitas →'
                    : 'Matikan Aksesibilitas untuk membuka m-banking →',
                style: TextStyle(
                  fontFamily: FN.sans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isBankSafe ? FN.ink : FN.warn,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final int step;
  final String title;
  final String purpose;
  final VoidCallback onOpen;

  const _Row({
    required this.step,
    required this.title,
    required this.purpose,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$step. $title',
          style: TextStyle(fontFamily: FN.sans, fontSize: 15, color: FN.ink),
        ),
        const SizedBox(height: 2),
        Text(
          purpose,
          style: TextStyle(
            fontFamily: FN.sans,
            fontSize: 13,
            color: FN.inkMuted,
          ),
        ),
        const SizedBox(height: 8),
        InkButton(label: 'Buka pengaturan', height: 40, onPressed: onOpen),
      ],
    ),
  );
}
