import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/social/data/social_providers.dart';
import 'package:virya/features/social/data/social_repository.dart';
import 'package:virya/features/social/domain/circle_invite.dart';
import 'package:virya/features/social/presentation/widgets/circle_actions.dart';

/// Halaman pemindai kamera QR Code khusus Circle Virya.
class CircleQrScannerScreen extends ConsumerStatefulWidget {
  /// Jika true, hanya mengembalikan teks hasil scan ke [Navigator.pop].
  final bool returnRaw;

  const CircleQrScannerScreen({super.key, this.returnRaw = false});

  /// Navigasi cepat ke layar pemindai QR.
  static Future<String?> scan(BuildContext context) {
    return Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (_) => const CircleQrScannerScreen(returnRaw: true),
      ),
    );
  }

  @override
  ConsumerState<CircleQrScannerScreen> createState() =>
      _CircleQrScannerScreenState();
}

class _CircleQrScannerScreenState extends ConsumerState<CircleQrScannerScreen> {
  late final MobileScannerController _controller;
  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw == null || raw.isEmpty) continue;

      if (raw.startsWith('virya-circle:')) {
        setState(() => _isProcessing = true);
        await HapticFeedback.mediumImpact();

        if (!mounted) return;

        if (widget.returnRaw) {
          Navigator.of(context).pop(raw);
          return;
        }

        await _processCirclePayload(raw);
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        return;
      }
    }
  }

  Future<void> _processCirclePayload(String raw) async {
    final repo = ref.read(socialRepositoryProvider);

    // Cek apakah ini format Undangan (invite)
    try {
      final invite = CircleInviteCodec.decodeInvite(raw);
      await _showInviteFoundSheet(invite, raw, repo);
      return;
    } catch (_) {
      // Bukan invite, coba cek apakah format pairing request
    }

    try {
      final request = CircleInviteCodec.decodeRequest(raw);
      await _showRequestFoundSheet(request, raw, repo);
      return;
    } catch (_) {
      // Format tidak valid
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format kode QR Circle tidak dikenali.'),
          ),
        );
      }
    }
  }

  /// Menampilkan pratinjau undangan yang di-scan dan konfirmasi bergabung.
  Future<void> _showInviteFoundSheet(
    CircleInvite invite,
    String raw,
    SocialRepository repo,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetCtx) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FN.paper,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(color: FN.line(0.2)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: FN.signal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.groups_outlined, color: FN.signal),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Undangan Circle Ditemukan',
                              style: FN.label(size: 11, color: FN.inkMuted),
                            ),
                            Text(
                              invite.circleName,
                              style: FN.heading(size: 18, color: FN.ink),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkBox(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Pembuat', invite.issuerName),
                          const SizedBox(height: 6),
                          _infoRow(
                            'Kadaluarsa',
                            '${invite.expiresAt.day}/${invite.expiresAt.month}/${invite.expiresAt.year}',
                          ),
                          const SizedBox(height: 6),
                          _infoRow('Status', 'Tanda tangan digital valid'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () async {
                            try {
                              await repo.acceptInvite(raw);
                              ref.invalidate(socialCirclesProvider);
                              if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Berhasil bergabung dengan "${invite.circleName}"!',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (sheetCtx.mounted) {
                                ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal menyimpan undangan: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Gabung Circle'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Menampilkan sheet saat kode pairing teman yang di-scan untuk diundang.
  Future<void> _showRequestFoundSheet(
    PairingRequest request,
    String raw,
    SocialRepository repo,
  ) async {
    final circles = ref.read(socialCirclesProvider).valueOrNull ?? const [];
    final identity = ref.read(socialIdentityProvider).valueOrNull;

    // Filter circle yang dimiliki pengguna
    final myCircles =
        circles
            .where((c) => c.ownerIdentityId == identity?.id)
            .toList(growable: false);

    if (myCircles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kode pairing teman ditemukan, tetapi kamu belum memiliki circle untuk mengundangnya.',
            ),
          ),
        );
      }
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetCtx) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FN.paper,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(color: FN.line(0.2)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: FN.signal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person_add_alt_outlined,
                          color: FN.signal,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kode Pairing Teman Terdeteksi',
                              style: FN.label(size: 11, color: FN.inkMuted),
                            ),
                            Text(
                              'Pilih Circle untuk Mengundang:',
                              style: FN.heading(size: 16, color: FN.ink),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (final c in myCircles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkBox(
                        child: ListTile(
                          title: Text(
                            c.name,
                            style: FN.heading(size: 14, color: FN.ink),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () async {
                            Navigator.pop(sheetCtx);
                            try {
                              final inviteCode = await repo.issueInvite(
                                c.id,
                                raw,
                              );
                              if (context.mounted) {
                                await showCode(
                                  context,
                                  'Undangan "${c.name}" Siap',
                                  inviteCode,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal membuat undangan: $e'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetCtx),
                      child: const Text('Batal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: FN.label(size: 11, color: FN.inkMuted)),
        Text(value, style: FN.heading(size: 12, color: FN.ink)),
      ],
    );
  }

  void _manualInput() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            title: const Text('Tempel Kode Circle'),
            content: TextField(
              controller: controller,
              minLines: 3,
              maxLines: 6,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Tempel teks virya-circle:...',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () {
                  final text = controller.text.trim();
                  Navigator.pop(dialogCtx);
                  if (text.isNotEmpty) {
                    _processCirclePayload(text);
                  }
                },
                child: const Text('Proses'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Kamera Scanner
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            errorBuilder: (ctx, err, _) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam_off_outlined,
                        size: 48,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Izin kamera tidak aktif atau tidak tersedia: ${err.errorDetails?.message ?? err.errorCode}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _manualInput,
                        child: const Text('Input Teks Manual'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Overlay Bingkai Pemindai (Field Notes Viewfinder)
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ViewfinderOverlayPainter(
              accentColor: FN.signal,
              lineColor: Colors.white38,
            ),
          ),

          // 3. Tombol Aksi Atas
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: Icon(
                            _isTorchOn ? Icons.flash_on : Icons.flash_off,
                            color: _isTorchOn ? Colors.amber : Colors.white,
                          ),
                          onPressed: () async {
                            await _controller.toggleTorch();
                            setState(() => _isTorchOn = !_isTorchOn);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(
                            Icons.cameraswitch,
                            color: Colors.white,
                          ),
                          onPressed: () => _controller.switchCamera(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. Instruksi dan Tombol Manual Bawah
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        'Arahkan kamera ke QR Code teman atau circle',
                        style: FN.label(size: 11, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _manualInput,
                      icon: const Icon(
                        Icons.keyboard_alt_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        'Tempel Kode Teks Manual',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter untuk efek viewfinder bergaris sudut Field Notes.
class _ViewfinderOverlayPainter extends CustomPainter {
  final Color accentColor;
  final Color lineColor;

  const _ViewfinderOverlayPainter({
    required this.accentColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scanSize = size.width * 0.72;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2 - 20;
    final rect = Rect.fromLTWH(left, top, scanSize, scanSize);

    // Gelapkan area di luar kotak
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final path =
        Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
          ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
          ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, backgroundPaint);

    // Garis tepi halus
    final borderPaint =
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      borderPaint,
    );

    // Sudut aksen (Corner Brackets)
    final cornerPaint =
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round;

    const cornerLen = 24.0;
    const r = 16.0;

    // Kiri Atas
    canvas.drawLine(
      Offset(left, top + r + cornerLen),
      Offset(left, top + r),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + r, top),
      Offset(left + r + cornerLen, top),
      cornerPaint,
    );

    // Kanan Atas
    canvas.drawLine(
      Offset(rect.right, top + r + cornerLen),
      Offset(rect.right, top + r),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right - r, top),
      Offset(rect.right - r - cornerLen, top),
      cornerPaint,
    );

    // Kiri Bawah
    canvas.drawLine(
      Offset(left, rect.bottom - r - cornerLen),
      Offset(left, rect.bottom - r),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + r, rect.bottom),
      Offset(left + r + cornerLen, rect.bottom),
      cornerPaint,
    );

    // Kanan Bawah
    canvas.drawLine(
      Offset(rect.right, rect.bottom - r - cornerLen),
      Offset(rect.right, rect.bottom - r),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right - r, rect.bottom),
      Offset(rect.right - r - cornerLen, rect.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ViewfinderOverlayPainter oldDelegate) => false;
}

