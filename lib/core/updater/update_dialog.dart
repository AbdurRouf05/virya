import 'dart:async';

import 'package:flutter/material.dart';
import 'package:virya/core/updater/update_model.dart';
import 'package:virya/core/updater/update_service.dart';
import 'package:virya/core/widgets/field_kit.dart';

enum _DownloadPhase {
  idle,
  downloading,
  downloaded,
  permissionNeeded,
  installing,
  error,
}

/// Dialog informasi dan pengunduhan pembaruan aplikasi Virya.
class UpdateDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;
  final String currentVersion;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.currentVersion,
  });

  /// Menampilkan dialog pembaruan.
  static Future<void> show(
    BuildContext context, {
    required AppUpdateInfo updateInfo,
    required String currentVersion,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !updateInfo.mandatory,
      builder: (_) => UpdateDialog(
        updateInfo: updateInfo,
        currentVersion: currentVersion,
      ),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  _DownloadPhase _phase = _DownloadPhase.idle;
  UpdateDownloadProgress? _progress;
  String? _downloadedFilePath;
  String? _errorMessage;
  StreamSubscription<UpdateDownloadProgress>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _startDownload() async {
    setState(() {
      _phase = _DownloadPhase.downloading;
      _errorMessage = null;
    });

    _sub = UpdateService.downloadApk(
      widget.updateInfo.downloadUrl,
      onComplete: (filePath) async {
        if (!mounted) return;
        setState(() {
          _downloadedFilePath = filePath;
          _phase = _DownloadPhase.downloaded;
        });
        await _checkPermissionAndInstall(filePath);
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _phase = _DownloadPhase.error;
          _errorMessage = 'Gagal mengunduh: $err';
        });
      },
    ).listen((p) {
      if (!mounted) return;
      setState(() => _progress = p);
    });
  }

  Future<void> _checkPermissionAndInstall(String filePath) async {
    final canInstall = await UpdateService.canRequestPackageInstalls();
    if (!canInstall) {
      if (!mounted) return;
      setState(() => _phase = _DownloadPhase.permissionNeeded);
      return;
    }

    await _executeInstall(filePath);
  }

  Future<void> _executeInstall(String filePath) async {
    setState(() => _phase = _DownloadPhase.installing);
    try {
      await UpdateService.installApk(filePath);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _DownloadPhase.error;
        _errorMessage = 'Gagal memasang APK: $e';
      });
    }
  }

  Future<void> _grantPermissionAndInstall() async {
    await UpdateService.openInstallPermissionSettings();
    // Setelah pengguna kembali dari settings, tombol akan jadi "Coba Pasang Lagi"
    if (!mounted) return;
    setState(() => _phase = _DownloadPhase.downloaded);
  }

  @override
  Widget build(BuildContext context) {
    final isMandatory = widget.updateInfo.mandatory;

    return PopScope(
      canPop: !isMandatory && _phase != _DownloadPhase.downloading,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: FN.paper,
            border: Border.all(color: FN.ink, width: 2),
            boxShadow: [
              BoxShadow(
                color: FN.ink,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StampChip(
                    text: 'PEMBARUAN TERSEDIA',
                    selected: true,
                    fontSize: 10,
                  ),
                  if (widget.updateInfo.releaseDate != null)
                    Text(
                      widget.updateInfo.releaseDate!,
                      style: FN.monoStyle(size: 10, color: FN.inkMuted),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Judul & Perbandingan Versi
              Text('VIRYA TERBARU', style: FN.bigNumber(22)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'v${widget.currentVersion}',
                    style: FN.monoStyle(
                      size: 12,
                      color: FN.inkMuted,
                    ).copyWith(decoration: TextDecoration.lineThrough),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 14),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: FN.ink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'v${widget.updateInfo.versionName}',
                      style: FN.monoStyle(
                        size: 12,
                        weight: FontWeight.bold,
                        color: FN.paper,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Catatan Perubahan (Changelog)
              Text('CATATAN RILIS:', style: FN.label(size: 10)),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxHeight: 140),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: FN.paperDeep,
                  border: Border.all(color: FN.inkMuted.withValues(alpha: 0.4)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.updateInfo.changelog,
                    style: FN.monoStyle(size: 11, color: FN.ink),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Area status progress / pesan
              if (_phase == _DownloadPhase.downloading) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mengunduh APK…', style: FN.label(size: 10)),
                    Text(
                      '${_progress?.percent ?? 0}% '
                      '(${_progress?.receivedMb ?? "0"} MB / ${_progress?.totalMb ?? "?"} MB)',
                      style: FN.monoStyle(size: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progress?.fraction,
                  backgroundColor: FN.paperDeep,
                  valueColor: AlwaysStoppedAnimation<Color>(FN.signal),
                  minHeight: 6,
                ),
                const SizedBox(height: 16),
              ] else if (_phase == _DownloadPhase.permissionNeeded) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, size: 18, color: Colors.amber.shade900),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Izin install aplikasi tak dikenal diperlukan agar Android bisa memasang APK.',
                          style: FN.label(size: 10, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (_phase == _DownloadPhase.error) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade400),
                  ),
                  child: Text(
                    _errorMessage ?? 'Terjadi kesalahan.',
                    style: FN.monoStyle(size: 10, color: Colors.red.shade900),
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (_phase == _DownloadPhase.installing) ...[
                Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Membuka paket instalasi…',
                      style: FN.label(size: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Tombol aksi
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (_phase) {
      case _DownloadPhase.idle:
      case _DownloadPhase.error:
        return Row(
          children: [
            if (!widget.updateInfo.mandatory) ...[
              Expanded(
                child: InkButton(
                  label: 'NANTI',
                  style: InkButtonStyle.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              flex: 2,
              child: InkButton(
                label: _phase == _DownloadPhase.error
                    ? 'COBA LAGI'
                    : 'UNDUH & PASANG',
                icon: Icons.system_update_alt,
                style: InkButtonStyle.primary,
                onPressed: _startDownload,
              ),
            ),
          ],
        );

      case _DownloadPhase.downloading:
        return InkButton(
          label: 'MEMBATALKAN',
          style: InkButtonStyle.outline,
          onPressed: () {
            _sub?.cancel();
            setState(() => _phase = _DownloadPhase.idle);
          },
        );

      case _DownloadPhase.permissionNeeded:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkButton(
              label: 'IZINKAN SUMBER INI',
              icon: Icons.settings,
              style: InkButtonStyle.primary,
              onPressed: _grantPermissionAndInstall,
            ),
            const SizedBox(height: 8),
            InkButton(
              label: 'BATAL',
              style: InkButtonStyle.outline,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );

      case _DownloadPhase.downloaded:
        return Row(
          children: [
            Expanded(
              child: InkButton(
                label: 'TUTUP',
                style: InkButtonStyle.outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: InkButton(
                label: 'PASANG SEKARANG',
                icon: Icons.install_mobile,
                style: InkButtonStyle.primary,
                onPressed: () {
                  if (_downloadedFilePath != null) {
                    _checkPermissionAndInstall(_downloadedFilePath!);
                  }
                },
              ),
            ),
          ],
        );

      case _DownloadPhase.installing:
        return InkButton(
          label: 'TUTUP',
          style: InkButtonStyle.outline,
          onPressed: () => Navigator.of(context).pop(),
        );
    }
  }
}
