import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/focus/data/focus_bridge.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

/// Menjelaskan izin utama yang belum diberikan dan membuka layar Pengaturan-nya.
class FocusPermissionPanel extends ConsumerWidget {
  final FocusPermissions permissions;
  const FocusPermissionPanel({super.key, required this.permissions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridge = ref.read(focusBridgeProvider);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: FN.ink, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'IZIN UTAMA DIBUTUHKAN',
            style: FN
                .label(size: 11, color: FN.ink)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          if (!permissions.usageAccess) ...[
            _Row(
              title: 'Akses penggunaan',
              purpose:
                  'Untuk membaca berapa lama aplikasi dipakai & menghitung sisa waktu.',
              onOpen: bridge.openUsageSettings,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: FN.signal, width: 3)),
                color: FN.paperDeep,
              ),
              child: Text(
                'Aman untuk m-Banking: Izin Akses Penggunaan adalah izin resmi Android yang 100% aman dan TIDAK PERNAH diblokir oleh SeaBank, BCA, atau bank lainnya.',
                style: TextStyle(
                  fontFamily: FN.sans,
                  fontSize: 11,
                  color: FN.inkSoft,
                  height: 1.35,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
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
                        'TOMBOL PENGATURAN TIDAK BISA DI-KLIK?',
                        style: FN
                            .label(size: 9.5, color: FN.ink)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Di Android 13/14+, sistem mengunci izin untuk APK ("Controlled by Restricted Setting").\n'
                  'Cara membukanya:\n'
                  '1. Klik tombol "BUKA INFO APLIKASI" di bawah.\n'
                  '2. Tekan menu titik tiga (⋮) di pojok kanan atas.\n'
                  '3. Pilih "Izinkan setelan terbatas" (Allow restricted settings).\n'
                  '4. Masukkan PIN HP, lalu kembali ke sini.',
                  style: TextStyle(
                    fontFamily: FN.sans,
                    fontSize: 11.5,
                    color: FN.inkSoft,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                InkButton(
                  label: 'Buka Info Aplikasi (Buka Titik Tiga)',
                  height: 36,
                  onPressed: bridge.openAppSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner status mode penegakan batas (Mode Ramah Bank vs Mode Tutup Paksa).
class FocusModeBanner extends ConsumerWidget {
  final FocusPermissions permissions;
  const FocusModeBanner({super.key, required this.permissions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridge = ref.read(focusBridgeProvider);
    final isBankSafe = permissions.isBankSafe;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FN.paperDeep,
        border: Border(
          left: BorderSide(
            color: isBankSafe ? FN.signal : FN.warn,
            width: 3,
          ),
          top: BorderSide(color: FN.paperLine),
          right: BorderSide(color: FN.paperLine),
          bottom: BorderSide(color: FN.paperLine),
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
                color: isBankSafe ? FN.signal : FN.warn,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBankSafe
                      ? 'MODE RAMAH M-BANKING AKTIF'
                      : 'MODE TUTUP PAKSA (AKSESIBILITAS)',
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
                ? 'Layanan Aksesibilitas nonaktif. Aplikasi perbankan (SeaBank, BCA, dll.) aman dibuka tanpa risiko diblokir. Peringatan batas waktu dikirim lewat notifikasi layar.'
                : 'Aksesibilitas aktif untuk menutup aplikasi secara otomatis saat waktu habis. Perhatian: Matikan izin ini jika hendak membuka m-Banking (SeaBank/BCA).',
            style: TextStyle(
              fontFamily: FN.sans,
              fontSize: 11,
              color: FN.inkMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: bridge.openAccessibilitySettings,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isBankSafe
                          ? 'Ingin tutup aplikasi otomatis paksa? (Buka Aksesibilitas) →'
                          : 'Matikan Aksesibilitas untuk buka m-Banking →',
                      style: TextStyle(
                        fontFamily: FN.sans,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isBankSafe ? FN.ink : FN.warn,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String title;
  final String purpose;
  final VoidCallback onOpen;

  const _Row({
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
          title,
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
