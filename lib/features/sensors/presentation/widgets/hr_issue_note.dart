import 'package:flutter/material.dart';
import 'package:virya/core/sensors/heart_rate_state.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Explains why the sensor cannot be reached right now.
class HrIssueNote extends StatelessWidget {
  final HrIssue issue;
  final VoidCallback onOpenSettings;

  const HrIssueNote({
    super.key,
    required this.issue,
    required this.onOpenSettings,
  });

  String get _message => switch (issue) {
    HrIssue.none => '',
    HrIssue.unsupported => 'HP ini tidak mendukung Bluetooth hemat daya (BLE).',
    HrIssue.permissionDenied => 'Izin Bluetooth dibutuhkan untuk mencari sensor.',
    HrIssue.permissionBlocked =>
      'Izin Bluetooth ditolak permanen. Buka pengaturan aplikasi, lalu izinkan '
          'Perangkat sekitar.',
    HrIssue.adapterOff => 'Bluetooth mati. Nyalakan, lalu Virya akan menyambung lagi.',
    HrIssue.notHeartRate => 'Perangkat ini bukan sensor detak jantung.',
    HrIssue.scanFailed =>
      'Gagal mencari sensor. Coba lagi. Di Android 11 ke bawah, Lokasi harus '
          'menyala.',
  };

  @override
  Widget build(BuildContext context) {
    return InkBox(
      padding: const EdgeInsets.all(12),
      borderColor: FN.warn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_message, style: FN.label(size: 11, color: FN.ink)),
          if (issue == HrIssue.permissionBlocked) ...[
            const SizedBox(height: 10),
            InkButton(
              label: 'Buka pengaturan',
              icon: Icons.settings_outlined,
              style: InkButtonStyle.outline,
              expand: true,
              onPressed: onOpenSettings,
            ),
          ],
        ],
      ),
    );
  }
}
